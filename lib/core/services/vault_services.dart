import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/user_preferences.dart';
import '../../features/scan_import/domain/import_services.dart';

const _defaultVaultStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

class StagedImportFile {
  const StagedImportFile({
    required this.path,
    required this.sourceType,
    required this.mimeType,
  });

  final String path;
  final DocumentSourceType sourceType;
  final String mimeType;
}

class StoredVaultDocument {
  const StoredVaultDocument({
    required this.storageRef,
    required this.encryptedAt,
  });

  final String storageRef;
  final DateTime encryptedAt;
}

class LocalVaultKeyService {
  const LocalVaultKeyService([this._storage = _defaultVaultStorage]);

  final FlutterSecureStorage _storage;

  static const _rootKeyKey = 'local_vault_root_key_v1';
  static const _migrationStageKey = 'local_vault_migration_stage';
  static const _migrationFailureKey = 'local_vault_migration_failure';
  static const _upgradeExplainerPendingKey =
      'local_vault_upgrade_explainer_pending';

  Future<Uint8List> ensureRootKey() async {
    final existing = await _storage.read(key: _rootKeyKey);
    if (existing != null && existing.isNotEmpty) {
      return Uint8List.fromList(base64Decode(existing));
    }
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    await _storage.write(key: _rootKeyKey, value: base64Encode(bytes));
    return bytes;
  }

  Future<String> databasePassphrase() async {
    final bytes = await _deriveKey('database');
    return base64Encode(bytes);
  }

  Future<SecretKey> documentSecretKey() async {
    final bytes = await _deriveKey('documents');
    return SecretKey(bytes);
  }

  Future<void> setMigrationStage(String value) {
    return _storage.write(key: _migrationStageKey, value: value);
  }

  Future<String?> getMigrationStage() {
    return _storage.read(key: _migrationStageKey);
  }

  Future<void> clearMigrationStage() {
    return _storage.delete(key: _migrationStageKey);
  }

  Future<void> setMigrationFailure(String? value) async {
    if (value == null || value.isEmpty) {
      await _storage.delete(key: _migrationFailureKey);
      return;
    }
    await _storage.write(key: _migrationFailureKey, value: value);
  }

  Future<String?> getMigrationFailure() {
    return _storage.read(key: _migrationFailureKey);
  }

  Future<void> setUpgradeExplainerPending(bool value) async {
    if (!value) {
      await _storage.delete(key: _upgradeExplainerPendingKey);
      return;
    }
    await _storage.write(key: _upgradeExplainerPendingKey, value: 'true');
  }

  Future<bool> isUpgradeExplainerPending() async {
    return (await _storage.read(key: _upgradeExplainerPendingKey)) == 'true';
  }

  Future<List<int>> _deriveKey(String context) async {
    final root = await ensureRootKey();
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final secretKey = await hkdf.deriveKey(
      secretKey: SecretKey(root),
      nonce: utf8.encode('debt-destroyer-local-vault'),
      info: utf8.encode(context),
    );
    return secretKey.extractBytes();
  }
}

class ProtectedPreferenceValues {
  const ProtectedPreferenceValues({
    required this.hideBalances,
    required this.appLockEnabled,
    required this.aiConsentEnabled,
    required this.relockTimeout,
    required this.screenshotProtectionEnabled,
    required this.privacyShieldOnAppSwitcherEnabled,
  });

  factory ProtectedPreferenceValues.defaults() {
    return const ProtectedPreferenceValues(
      hideBalances: false,
      appLockEnabled: false,
      aiConsentEnabled: false,
      relockTimeout: AppRelockTimeout.seconds30,
      screenshotProtectionEnabled: true,
      privacyShieldOnAppSwitcherEnabled: true,
    );
  }

  final bool hideBalances;
  final bool appLockEnabled;
  final bool aiConsentEnabled;
  final AppRelockTimeout relockTimeout;
  final bool screenshotProtectionEnabled;
  final bool privacyShieldOnAppSwitcherEnabled;

  ProtectedPreferenceValues copyWith({
    bool? hideBalances,
    bool? appLockEnabled,
    bool? aiConsentEnabled,
    AppRelockTimeout? relockTimeout,
    bool? screenshotProtectionEnabled,
    bool? privacyShieldOnAppSwitcherEnabled,
  }) {
    return ProtectedPreferenceValues(
      hideBalances: hideBalances ?? this.hideBalances,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      aiConsentEnabled: aiConsentEnabled ?? this.aiConsentEnabled,
      relockTimeout: relockTimeout ?? this.relockTimeout,
      screenshotProtectionEnabled:
          screenshotProtectionEnabled ?? this.screenshotProtectionEnabled,
      privacyShieldOnAppSwitcherEnabled:
          privacyShieldOnAppSwitcherEnabled ??
          this.privacyShieldOnAppSwitcherEnabled,
    );
  }
}

class ProtectedPreferencesStore {
  ProtectedPreferencesStore([this._storage = _defaultVaultStorage]);

  final FlutterSecureStorage _storage;

  static const _hideBalancesKey = 'protected_pref_hide_balances';
  static const _appLockEnabledKey = 'protected_pref_app_lock_enabled';
  static const _aiConsentEnabledKey = 'protected_pref_ai_consent_enabled';
  static const _relockTimeoutKey = 'protected_pref_relock_timeout';
  static const _screenshotProtectionKey =
      'protected_pref_screenshot_protection_enabled';
  static const _privacyShieldKey =
      'protected_pref_privacy_shield_on_app_switcher_enabled';
  static const _migrationKey = 'protected_pref_flags_migrated_v1';
  static const _extendedMigrationKey =
      'protected_pref_extended_flags_migrated_v1';
  final Map<String, String> _memoryFallback = <String, String>{};

  Future<void> migrateFromLegacy(UserPreferences preferences) async {
    if (!await _isMigrated()) {
      if (await _hasExistingProtectedValues()) {
        await _write(_migrationKey, 'true');
        await _backfillExtendedFlags(preferences);
        return;
      }
      await write(
        ProtectedPreferenceValues(
          hideBalances: preferences.hideBalances,
          appLockEnabled: preferences.appLockEnabled,
          aiConsentEnabled: preferences.aiConsentEnabled,
          relockTimeout: preferences.relockTimeout,
          screenshotProtectionEnabled: preferences.screenshotProtectionEnabled,
          privacyShieldOnAppSwitcherEnabled:
              preferences.privacyShieldOnAppSwitcherEnabled,
        ),
      );
      await _write(_migrationKey, 'true');
      await _write(_extendedMigrationKey, 'true');
      return;
    }
    await _backfillExtendedFlags(preferences);
  }

  Future<ProtectedPreferenceValues> read() async {
    return ProtectedPreferenceValues(
      hideBalances: await _readBool(_hideBalancesKey) ?? false,
      appLockEnabled: await _readBool(_appLockEnabledKey) ?? false,
      aiConsentEnabled: await _readBool(_aiConsentEnabledKey) ?? false,
      relockTimeout:
          _readRelockTimeout(await _read(_relockTimeoutKey)) ??
          AppRelockTimeout.seconds30,
      screenshotProtectionEnabled:
          await _readBool(_screenshotProtectionKey) ?? true,
      privacyShieldOnAppSwitcherEnabled:
          await _readBool(_privacyShieldKey) ?? true,
    );
  }

  Future<void> write(ProtectedPreferenceValues values) async {
    await Future.wait([
      _writeBool(_hideBalancesKey, values.hideBalances),
      _writeBool(_appLockEnabledKey, values.appLockEnabled),
      _writeBool(_aiConsentEnabledKey, values.aiConsentEnabled),
      _write(_relockTimeoutKey, values.relockTimeout.name),
      _writeBool(_screenshotProtectionKey, values.screenshotProtectionEnabled),
      _writeBool(_privacyShieldKey, values.privacyShieldOnAppSwitcherEnabled),
    ]);
  }

  Future<UserPreferences> mergeInto(UserPreferences preferences) async {
    final protected = await read();
    return preferences.copyWith(
      hideBalances: protected.hideBalances,
      appLockEnabled: protected.appLockEnabled,
      aiConsentEnabled: protected.aiConsentEnabled,
      relockTimeout: protected.relockTimeout,
      screenshotProtectionEnabled: protected.screenshotProtectionEnabled,
      privacyShieldOnAppSwitcherEnabled:
          protected.privacyShieldOnAppSwitcherEnabled,
    );
  }

  Future<bool> _isMigrated() async {
    return (await _read(_migrationKey)) == 'true';
  }

  Future<bool> _isExtendedMigrationComplete() async {
    return (await _read(_extendedMigrationKey)) == 'true';
  }

  Future<bool> _hasExistingProtectedValues() async {
    return await _read(_hideBalancesKey) != null ||
        await _read(_appLockEnabledKey) != null ||
        await _read(_aiConsentEnabledKey) != null;
  }

  Future<bool?> _readBool(String key) async {
    final value = await _read(key);
    if (value == null) {
      return null;
    }
    return value == 'true';
  }

  AppRelockTimeout? _readRelockTimeout(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    for (final value in AppRelockTimeout.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return null;
  }

  Future<void> _writeBool(String key, bool value) {
    return _write(key, value ? 'true' : 'false');
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on MissingPluginException {
      return _memoryFallback[key];
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on MissingPluginException {
      _memoryFallback[key] = value;
    }
  }

  Future<void> _backfillExtendedFlags(UserPreferences preferences) async {
    if (await _isExtendedMigrationComplete()) {
      return;
    }
    final writes = <Future<void>>[];
    if (await _read(_relockTimeoutKey) == null) {
      writes.add(_write(_relockTimeoutKey, preferences.relockTimeout.name));
    }
    if (await _read(_screenshotProtectionKey) == null) {
      writes.add(
        _writeBool(
          _screenshotProtectionKey,
          preferences.screenshotProtectionEnabled,
        ),
      );
    }
    if (await _read(_privacyShieldKey) == null) {
      writes.add(
        _writeBool(
          _privacyShieldKey,
          preferences.privacyShieldOnAppSwitcherEnabled,
        ),
      );
    }
    if (writes.isNotEmpty) {
      await Future.wait(writes);
    }
    await _write(_extendedMigrationKey, 'true');
  }
}

class AppSecuritySessionSnapshot {
  const AppSecuritySessionSnapshot({
    required this.lastUnlockedAt,
    required this.lastBackgroundedAt,
    required this.activeSession,
  });

  factory AppSecuritySessionSnapshot.empty() {
    return const AppSecuritySessionSnapshot(
      lastUnlockedAt: null,
      lastBackgroundedAt: null,
      activeSession: false,
    );
  }

  final DateTime? lastUnlockedAt;
  final DateTime? lastBackgroundedAt;
  final bool activeSession;

  AppSecuritySessionSnapshot copyWith({
    DateTime? lastUnlockedAt,
    DateTime? lastBackgroundedAt,
    bool? activeSession,
  }) {
    return AppSecuritySessionSnapshot(
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
      lastBackgroundedAt: lastBackgroundedAt ?? this.lastBackgroundedAt,
      activeSession: activeSession ?? this.activeSession,
    );
  }
}

class AppSecuritySessionStore {
  AppSecuritySessionStore([this._storage = _defaultVaultStorage]);

  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryFallback = <String, String>{};

  static const _lastUnlockedAtKey = 'app_security_last_unlocked_at';
  static const _lastBackgroundedAtKey = 'app_security_last_backgrounded_at';
  static const _activeSessionKey = 'app_security_active_session';

  Future<AppSecuritySessionSnapshot> read() async {
    return AppSecuritySessionSnapshot(
      lastUnlockedAt: _parseDate(await _read(_lastUnlockedAtKey)),
      lastBackgroundedAt: _parseDate(await _read(_lastBackgroundedAtKey)),
      activeSession: (await _read(_activeSessionKey)) == 'true',
    );
  }

  Future<void> recordUnlock(DateTime now) async {
    await Future.wait([
      _write(_lastUnlockedAtKey, now.toIso8601String()),
      _write(_activeSessionKey, 'true'),
    ]);
  }

  Future<void> recordBackground(DateTime now) async {
    await _write(_lastBackgroundedAtKey, now.toIso8601String());
  }

  Future<void> markLocked() async {
    await _write(_activeSessionKey, 'false');
  }

  Future<void> clear() async {
    await Future.wait([
      _delete(_lastUnlockedAtKey),
      _delete(_lastBackgroundedAtKey),
      _delete(_activeSessionKey),
    ]);
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on MissingPluginException {
      return _memoryFallback[key];
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on MissingPluginException {
      _memoryFallback[key] = value;
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on MissingPluginException {
      _memoryFallback.remove(key);
    }
  }
}

class DataRetentionService {
  const DataRetentionService();

  bool shouldRetainRawOcr(UserPreferences preferences) {
    return preferences.rawOcrRetentionEnabled &&
        preferences.rawOcrRetentionHours > 0;
  }

  DateTime? rawOcrExpiry(UserPreferences preferences, DateTime now) {
    if (!shouldRetainRawOcr(preferences)) {
      return null;
    }
    return now.add(Duration(hours: preferences.rawOcrRetentionHours));
  }

  DateTime? documentExpiry({
    required UserPreferences preferences,
    required ParseStatus parseStatus,
    required DateTime now,
  }) {
    if (parseStatus == ParseStatus.failed ||
        parseStatus == ParseStatus.discarded) {
      return now.add(Duration(hours: preferences.purgeFailedImportsAfterHours));
    }
    return switch (preferences.documentRetentionMode) {
      DocumentRetentionMode.days7 => now.add(const Duration(days: 7)),
      DocumentRetentionMode.days30 => now.add(const Duration(days: 30)),
      DocumentRetentionMode.manual => null,
    };
  }
}

class SecureDocumentVaultService {
  SecureDocumentVaultService(
    this._keyService, {
    Future<Directory> Function()? baseDirectoryLoader,
  }) : _baseDirectoryLoader =
           baseDirectoryLoader ?? getApplicationSupportDirectory;

  static const _formatVersion = 1;
  final LocalVaultKeyService _keyService;
  final Future<Directory> Function() _baseDirectoryLoader;
  final Cipher _cipher = AesGcm.with256bits();

  Future<StoredVaultDocument> sealImport(FileReference input) async {
    final sourceFile = File(input.path);
    final bytes = await sourceFile.readAsBytes();
    return sealBytes(bytes);
  }

  Future<StoredVaultDocument> sealBytes(Uint8List bytes) async {
    final secretKey = await _keyService.documentSecretKey();
    final secretBox = await _cipher.encrypt(
      bytes,
      secretKey: secretKey,
      nonce: _randomNonce(),
    );
    final storageRef = '${const Uuid().v4()}.vault';
    final targetFile = File(p.join((await _vaultDirectory()).path, storageRef));
    final encoded = BytesBuilder(copy: false)
      ..addByte(_formatVersion)
      ..addByte(secretBox.nonce.length)
      ..add(secretBox.nonce)
      ..addByte(secretBox.mac.bytes.length)
      ..add(secretBox.mac.bytes)
      ..add(secretBox.cipherText);
    await targetFile.writeAsBytes(encoded.toBytes(), flush: true);
    return StoredVaultDocument(
      storageRef: storageRef,
      encryptedAt: DateTime.now(),
    );
  }

  Future<Uint8List?> readDocumentBytes(String? storageRef) async {
    if (storageRef == null || storageRef.isEmpty) {
      return null;
    }
    final file = File(p.join((await _vaultDirectory()).path, storageRef));
    if (!await file.exists()) {
      return null;
    }
    final bytes = await file.readAsBytes();
    if (bytes.length < 4) {
      return null;
    }
    final nonceLength = bytes[1];
    final nonceStart = 2;
    final nonceEnd = nonceStart + nonceLength;
    final macLength = bytes[nonceEnd];
    final macStart = nonceEnd + 1;
    final macEnd = macStart + macLength;
    final cipherText = bytes.sublist(macEnd);
    final box = SecretBox(
      cipherText,
      nonce: bytes.sublist(nonceStart, nonceEnd),
      mac: Mac(bytes.sublist(macStart, macEnd)),
    );
    final clear = await _cipher.decrypt(
      box,
      secretKey: await _keyService.documentSecretKey(),
    );
    return Uint8List.fromList(clear);
  }

  Future<void> purgeStoredDocument(String? storageRef) async {
    if (storageRef == null || storageRef.isEmpty) {
      return;
    }
    final file = File(p.join((await _vaultDirectory()).path, storageRef));
    if (!await file.exists()) {
      return;
    }
    final length = await file.length();
    if (length > 0) {
      await file.writeAsBytes(List<int>.filled(length, 0), flush: true);
    }
    await file.delete();
  }

  Future<void> purgeLegacyPlaintext(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (!await file.exists()) {
      return;
    }
    final length = await file.length();
    if (length > 0) {
      await file.writeAsBytes(List<int>.filled(length, 0), flush: true);
    }
    await file.delete();
  }

  Future<Directory> _vaultDirectory() async {
    final base = await _baseDirectoryLoader();
    final dir = Directory(p.join(base.path, 'secure_vault', 'documents'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  List<int> _randomNonce() {
    final random = Random.secure();
    return List<int>.generate(12, (_) => random.nextInt(256));
  }
}
