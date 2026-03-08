import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/core/logging/app_logger.dart';
import 'package:debt_destroyer/core/services/data_protection_service.dart';
import 'package:debt_destroyer/core/services/vault_services.dart';
import 'package:debt_destroyer/features/scan_import/domain/import_services.dart';
import 'package:debt_destroyer/shared/data/local/app_database.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureDocumentVaultService', () {
    test('encrypts, decrypts, and purges imported files', () async {
      final tempDir = await Directory.systemTemp.createTemp('vault_test');
      addTearDown(() async => tempDir.delete(recursive: true));

      final sourceFile = File('${tempDir.path}/source.txt')
        ..writeAsStringSync('sensitive statement payload');
      final vault = SecureDocumentVaultService(
        _FakeKeyService(),
        baseDirectoryLoader: () async => tempDir,
      );

      final stored = await vault.sealImport(
        const FileReference(
          path: '',
          sourceType: DocumentSourceType.gallery,
          mimeType: 'text/plain',
        ).copyWith(path: sourceFile.path),
      );

      final decrypted = await vault.readDocumentBytes(stored.storageRef);
      expect(utf8.decode(decrypted!), 'sensitive statement payload');

      await vault.purgeStoredDocument(stored.storageRef);
      expect(
        File(
          '${tempDir.path}${Platform.pathSeparator}secure_vault${Platform.pathSeparator}documents${Platform.pathSeparator}${stored.storageRef}',
        ).existsSync(),
        isFalse,
      );
    });
  });

  group('DataProtectionBootstrapService', () {
    test(
      'migrates legacy plaintext document files into the encrypted vault',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'protect_bootstrap',
        );
        addTearDown(() async => tempDir.delete(recursive: true));
        final legacy = File('${tempDir.path}/legacy.txt')
          ..writeAsStringSync('legacy payload');

        final database = AppDatabase(NativeDatabase.memory());
        addTearDown(() async => database.close());

        await database
            .into(database.importedDocumentsTable)
            .insert(
              ImportedDocumentsTableCompanion.insert(
                id: 'doc-1',
                localPath: Value(legacy.path),
                sourceType: DocumentSourceType.gallery.name,
                mimeType: 'text/plain',
                createdAt: DateTime(2026, 3, 9),
                parseStatus: ParseStatus.success.name,
                parseVersion: 'v1',
                rawOcrText: const Value('OCR BODY'),
              ),
            );

        final service = DataProtectionBootstrapService(
          database: database,
          keyService: _FakeKeyService(),
          documentVaultService: SecureDocumentVaultService(
            _FakeKeyService(),
            baseDirectoryLoader: () async => tempDir,
          ),
          retentionService: const DataRetentionService(),
        );

        final state = await service.initialize();
        final row = await database
            .select(database.importedDocumentsTable)
            .getSingle();

        expect(state.ready, isTrue);
        expect(row.storageRef, isA<String>());
        expect(row.localPath, isEmpty);
        expect(row.rawOcrText, equals(null));
        expect(row.hasRawOcrText, isFalse);
        expect(legacy.existsSync(), isFalse);
      },
    );

    test('purges expired encrypted documents during bootstrap', () async {
      final tempDir = await Directory.systemTemp.createTemp('protect_expired');
      addTearDown(() async => tempDir.delete(recursive: true));
      final source = File('${tempDir.path}/expired.txt')
        ..writeAsStringSync('expired payload');
      final keyService = _FakeKeyService();
      final vault = SecureDocumentVaultService(
        keyService,
        baseDirectoryLoader: () async => tempDir,
      );
      final stored = await vault.sealImport(
        const FileReference(
          path: '',
          sourceType: DocumentSourceType.gallery,
          mimeType: 'text/plain',
        ).copyWith(path: source.path),
      );

      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(() async => database.close());
      await database
          .into(database.importedDocumentsTable)
          .insert(
            ImportedDocumentsTableCompanion.insert(
              id: 'doc-expired',
              localPath: const Value(''),
              storageRef: Value(stored.storageRef),
              sourceType: DocumentSourceType.gallery.name,
              mimeType: 'text/plain',
              createdAt: DateTime(2026, 3, 9),
              parseStatus: ParseStatus.success.name,
              parseVersion: 'v2',
              retentionExpiresAt: Value(
                DateTime.now().subtract(const Duration(days: 1)),
              ),
              encryptedAt: Value(stored.encryptedAt),
            ),
          );

      final service = DataProtectionBootstrapService(
        database: database,
        keyService: keyService,
        documentVaultService: vault,
        retentionService: const DataRetentionService(),
      );

      await service.initialize();
      final rows = await database.select(database.importedDocumentsTable).get();
      expect(rows, isEmpty);
    });

    test('trims expired OCR text without deleting retained document', () async {
      final tempDir = await Directory.systemTemp.createTemp('protect_ocr');
      addTearDown(() async => tempDir.delete(recursive: true));
      final source = File('${tempDir.path}/ocr.txt')
        ..writeAsStringSync('ocr payload');
      final keyService = _FakeKeyService();
      final vault = SecureDocumentVaultService(
        keyService,
        baseDirectoryLoader: () async => tempDir,
      );
      final stored = await vault.sealImport(
        const FileReference(
          path: '',
          sourceType: DocumentSourceType.gallery,
          mimeType: 'text/plain',
        ).copyWith(path: source.path),
      );

      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(() async => database.close());
      await database
          .into(database.importedDocumentsTable)
          .insert(
            ImportedDocumentsTableCompanion.insert(
              id: 'doc-ocr-expired',
              localPath: const Value(''),
              storageRef: Value(stored.storageRef),
              sourceType: DocumentSourceType.gallery.name,
              mimeType: 'text/plain',
              createdAt: DateTime(2026, 3, 9),
              rawOcrText: const Value('OCR BODY'),
              parseStatus: ParseStatus.success.name,
              parseVersion: 'v2',
              retentionExpiresAt: Value(
                DateTime.now().add(const Duration(days: 7)),
              ),
              rawOcrExpiresAt: Value(
                DateTime.now().subtract(const Duration(hours: 1)),
              ),
              encryptedAt: Value(stored.encryptedAt),
              hasRawOcrText: const Value(true),
            ),
          );

      final service = DataProtectionBootstrapService(
        database: database,
        keyService: keyService,
        documentVaultService: vault,
        retentionService: const DataRetentionService(),
      );

      await service.initialize();
      final row = await database
          .select(database.importedDocumentsTable)
          .getSingle();
      expect(row.storageRef, isNotNull);
      expect(row.rawOcrText, isNull);
      expect(row.hasRawOcrText, isFalse);
      expect(row.rawOcrExpiresAt, isNull);
    });

    test('backfills OCR expiry for retained OCR during migration', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'protect_ocr_migration',
      );
      addTearDown(() async => tempDir.delete(recursive: true));
      final legacy = File('${tempDir.path}/legacy-ocr.txt')
        ..writeAsStringSync('legacy payload');

      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(() async => database.close());
      await database
          .into(database.appPreferencesTable)
          .insert(
            AppPreferencesTableCompanion.insert(
              rawOcrRetentionEnabled: const Value(true),
              rawOcrRetentionHours: const Value(12),
            ),
          );
      await database
          .into(database.importedDocumentsTable)
          .insert(
            ImportedDocumentsTableCompanion.insert(
              id: 'doc-ocr-legacy',
              localPath: Value(legacy.path),
              sourceType: DocumentSourceType.gallery.name,
              mimeType: 'text/plain',
              createdAt: DateTime(2026, 3, 9),
              rawOcrText: const Value('OCR BODY'),
              parseStatus: ParseStatus.success.name,
              parseVersion: 'v1',
            ),
          );

      final service = DataProtectionBootstrapService(
        database: database,
        keyService: _FakeKeyService(),
        documentVaultService: SecureDocumentVaultService(
          _FakeKeyService(),
          baseDirectoryLoader: () async => tempDir,
        ),
        retentionService: const DataRetentionService(),
      );

      await service.initialize();
      final row = await database
          .select(database.importedDocumentsTable)
          .getSingle();
      expect(row.rawOcrText, 'OCR BODY');
      expect(row.hasRawOcrText, isTrue);
      expect(row.rawOcrExpiresAt, isNotNull);
      expect(row.retentionExpiresAt, isNotNull);
      expect(row.rawOcrExpiresAt!.isBefore(row.retentionExpiresAt!), isTrue);
    });
  });

  test('logger redacts sensitive terms', () {
    final sanitized = AppLogger.instance.sanitizeForTest(
      'token balance ocr note',
    );
    expect(sanitized, '[redacted] [redacted] [redacted] [redacted]');
  });

  test('retention defaults minimize OCR and expire failed imports quickly', () {
    const service = DataRetentionService();
    final prefs = UserPreferences.defaults();
    final now = DateTime(2026, 3, 9);

    expect(service.shouldRetainRawOcr(prefs), isFalse);
    expect(
      service.documentExpiry(
        preferences: prefs,
        parseStatus: ParseStatus.failed,
        now: now,
      ),
      now.add(const Duration(hours: 24)),
    );
  });
}

class _FakeKeyService extends LocalVaultKeyService {
  _FakeKeyService();

  final Uint8List _key = Uint8List.fromList(
    List<int>.generate(32, (index) => index + 1),
  );
  bool _explainer = false;

  @override
  Future<Uint8List> ensureRootKey() async => _key;

  @override
  Future<String> databasePassphrase() async => base64Encode(_key);

  @override
  Future<SecretKey> documentSecretKey() async => SecretKey(_key);

  @override
  Future<void> setMigrationFailure(String? value) async {}

  @override
  Future<void> setMigrationStage(String value) async {}

  @override
  Future<void> clearMigrationStage() async {}

  @override
  Future<void> setUpgradeExplainerPending(bool value) async {
    _explainer = value;
  }

  @override
  Future<bool> isUpgradeExplainerPending() async => _explainer;
}

extension on FileReference {
  FileReference copyWith({String? path}) {
    return FileReference(
      path: path ?? this.path,
      sourceType: sourceType,
      mimeType: mimeType,
    );
  }
}
