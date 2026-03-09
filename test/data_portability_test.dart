import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/core/services/portability_services.dart';
import 'package:debt_destroyer/core/services/vault_services.dart';
import 'package:debt_destroyer/features/scan_import/domain/import_services.dart';
import 'package:debt_destroyer/shared/data/local/app_database.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/import_models.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase database;
  late SecureDocumentVaultService vaultService;
  late DriftPreferencesRepository preferencesRepository;
  late DriftDocumentsRepository documentsRepository;
  late ProtectedPreferencesStore protectedPreferencesStore;
  late DataPortabilityService portabilityService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('backup_restore_test');
    database = AppDatabase(NativeDatabase.memory());
    vaultService = SecureDocumentVaultService(
      _FakeKeyService(),
      baseDirectoryLoader: () async => tempDir,
    );
    protectedPreferencesStore = ProtectedPreferencesStore();
    preferencesRepository = DriftPreferencesRepository(
      database,
      protectedPreferencesStore,
    );
    documentsRepository = DriftDocumentsRepository(database, vaultService);
    portabilityService = DataPortabilityService(
      database: database,
      preferencesRepository: preferencesRepository,
      documentsRepository: documentsRepository,
      vaultService: vaultService,
      protectedPreferencesStore: protectedPreferencesStore,
      temporaryDirectoryLoader: () async => tempDir,
    );
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  test('creates, validates, and restores an encrypted full backup', () async {
    final originalStorageRef = await seedPortableData(
      database: database,
      preferencesRepository: preferencesRepository,
      documentsRepository: documentsRepository,
      vaultService: vaultService,
      tempDir: tempDir,
    );

    final backupFile = await portabilityService.createFullBackup('passphrase');
    final validation = await portabilityService.inspectBackup(
      backupFile,
      'passphrase',
    );

    expect(validation.isValid, isTrue);
    expect(validation.preview?.debtCount, 1);
    expect(validation.preview?.paymentCount, 1);
    expect(validation.preview?.documentCount, 1);

    await database.delete(database.debtsTable).go();
    await database.delete(database.paymentsTable).go();

    final restored = await portabilityService.restoreBackup(
      backupFile,
      'passphrase',
    );

    expect(restored.debtCount, 1);
    expect(restored.paymentCount, 1);
    expect(restored.documentCount, 1);

    final debts = await database.select(database.debtsTable).get();
    final payments = await database.select(database.paymentsTable).get();
    final documents = await database
        .select(database.importedDocumentsTable)
        .get();
    final scenarios = await database.select(database.scenariosTable).get();
    final events = await database.select(database.reminderEventsTable).get();

    expect(debts, hasLength(1));
    expect(payments, hasLength(1));
    expect(documents, hasLength(1));
    expect(scenarios, hasLength(1));
    expect(events, hasLength(1));
    expect(documents.single.storageRef, isNot(originalStorageRef));

    final restoredBytes = await documentsRepository.readDocumentBytes('doc-1');
    expect(utf8.decode(restoredBytes!), 'statement attachment');

    final restoredPrefs = await preferencesRepository.loadPreferences();
    expect(restoredPrefs.currencyCode, 'EUR');
    expect(restoredPrefs.hideBalances, isTrue);
    expect(restoredPrefs.appLockEnabled, isTrue);
  });

  test('wrong passphrase fails safely', () async {
    await seedPortableData(
      database: database,
      preferencesRepository: preferencesRepository,
      documentsRepository: documentsRepository,
      vaultService: vaultService,
      tempDir: tempDir,
    );
    final backupFile = await portabilityService.createFullBackup('passphrase');

    final validation = await portabilityService.inspectBackup(
      backupFile,
      'wrong-passphrase',
    );

    expect(validation.isValid, isFalse);
    expect(validation.errors.single, contains('Check the passphrase'));
  });

  test('unsupported future backup version is rejected', () async {
    await seedPortableData(
      database: database,
      preferencesRepository: preferencesRepository,
      documentsRepository: documentsRepository,
      vaultService: vaultService,
      tempDir: tempDir,
    );
    final backupFile = await portabilityService.createFullBackup('passphrase');
    final wrapper =
        jsonDecode(await backupFile.readAsString()) as Map<String, dynamic>;
    wrapper['version'] = 99;
    await backupFile.writeAsString(jsonEncode(wrapper));

    final validation = await portabilityService.inspectBackup(
      backupFile,
      'passphrase',
    );

    expect(validation.isValid, isFalse);
    expect(validation.errors.single, contains('newer than this app supports'));
  });

  test(
    'restore does not wipe current data when backup validation fails',
    () async {
      await database
          .into(database.debtsTable)
          .insert(
            DebtsTableCompanion.insert(
              id: 'existing-debt',
              title: 'Existing debt',
              creditorName: 'Bank',
              type: DebtType.creditCard.name,
              currency: 'USD',
              originalBalance: 400,
              currentBalance: 350,
              apr: 18,
              minimumPayment: 40,
              paymentFrequency: PaymentFrequency.monthly.name,
              createdAt: DateTime(2026, 3, 10),
              updatedAt: DateTime(2026, 3, 10),
              status: DebtStatus.active.name,
            ),
          );
      final invalid = File('${tempDir.path}/invalid.ddbackup')
        ..writeAsStringSync('not a backup');

      await expectLater(
        portabilityService.restoreBackup(invalid, 'passphrase'),
        throwsA(isA<FormatException>()),
      );

      final debts = await database.select(database.debtsTable).get();
      expect(debts.single.id, 'existing-debt');
    },
  );
}

Future<String> seedPortableData({
  required AppDatabase database,
  required DriftPreferencesRepository preferencesRepository,
  required DriftDocumentsRepository documentsRepository,
  required SecureDocumentVaultService vaultService,
  required Directory tempDir,
}) async {
  await preferencesRepository.savePreferences(
    UserPreferences.defaults().copyWith(
      currencyCode: 'EUR',
      hideBalances: true,
      appLockEnabled: true,
      notificationsEnabled: true,
    ),
  );
  await database
      .into(database.debtsTable)
      .insert(
        DebtsTableCompanion.insert(
          id: 'debt-1',
          title: 'Visa',
          creditorName: 'Bank',
          type: DebtType.creditCard.name,
          currency: 'EUR',
          originalBalance: 1200,
          currentBalance: 950,
          apr: 19.9,
          minimumPayment: 55,
          dueDate: Value(DateTime(2026, 3, 15)),
          paymentFrequency: PaymentFrequency.monthly.name,
          createdAt: DateTime(2026, 3, 1),
          updatedAt: DateTime(2026, 3, 10),
          status: DebtStatus.active.name,
          remindersEnabled: const Value(true),
        ),
      );
  await database
      .into(database.paymentsTable)
      .insert(
        PaymentsTableCompanion.insert(
          id: 'payment-1',
          debtId: 'debt-1',
          amount: 250,
          date: DateTime(2026, 3, 9),
          sourceType: PaymentSourceType.manual.name,
          notes: const Value('March payment'),
          tagsJson: Value(database.encodeStringList(const ['monthly'])),
          createdAt: DateTime(2026, 3, 9),
        ),
      );
  final sourceFile = File('${tempDir.path}/statement.txt')
    ..writeAsStringSync('statement attachment');
  final stored = await vaultService.sealImport(
    FileReference(
      path: sourceFile.path,
      sourceType: DocumentSourceType.pdf,
      mimeType: 'text/plain',
    ),
  );
  await documentsRepository.saveDocument(
    ImportedDocument(
      id: 'doc-1',
      storageRef: stored.storageRef,
      sourceType: DocumentSourceType.pdf,
      mimeType: 'text/plain',
      createdAt: DateTime(2026, 3, 9),
      lifecycleState: DocumentLifecycleState.linked,
      linkedDebtId: 'debt-1',
      rawOcrText: 'OCR',
      parseStatus: ParseStatus.success,
      parseVersion: 'v3',
      deleted: false,
      retentionExpiresAt: DateTime(2026, 4, 9),
      rawOcrExpiresAt: DateTime(2026, 3, 12),
      processedAt: DateTime(2026, 3, 9),
      linkedAt: DateTime(2026, 3, 9),
      pendingDeletionAt: null,
      purgedAt: null,
      encryptedAt: stored.encryptedAt,
      hasRawOcrText: true,
    ),
  );
  await documentsRepository.saveParsedExtraction(
    ParsedExtraction(
      id: 'parse-1',
      documentId: 'doc-1',
      classification: DocumentClassification.creditCardStatement,
      confidence: 0.9,
      payloadJson: '{"issuer":"Bank"}',
      ambiguityNotes: '',
      createdAt: DateTime(2026, 3, 9),
    ),
  );
  await database
      .into(database.scenariosTable)
      .insert(
        ScenariosTableCompanion.insert(
          id: 'scenario-1',
          strategyType: StrategyType.avalanche.name,
          extraPayment: 100,
          budget: 300,
          createdAt: DateTime(2026, 3, 10),
          label: 'Aggressive',
          baselineInterest: 220,
          optimizedInterest: 150,
          monthsToPayoff: 8,
        ),
      );
  await database
      .into(database.reminderEventsTable)
      .insert(
        ReminderEventsTableCompanion.insert(
          id: 'milestone|debt-1|progress25',
          debtId: const Value('debt-1'),
          kind: MilestoneKind.progress25.name,
          createdAt: DateTime(2026, 3, 10),
        ),
      );
  return stored.storageRef;
}

class _FakeKeyService extends LocalVaultKeyService {
  _FakeKeyService() : super();

  @override
  Future<SecretKey> documentSecretKey() async {
    return SecretKey(List<int>.filled(32, 7));
  }
}
