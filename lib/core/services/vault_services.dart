import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
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
