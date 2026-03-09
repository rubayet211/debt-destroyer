import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/core/services/vault_services.dart';
import 'package:debt_destroyer/features/scan_import/domain/import_services.dart';
import 'package:debt_destroyer/shared/data/local/app_database.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/debt_financial_terms.dart';
import 'package:debt_destroyer/shared/models/import_models.dart';
import 'package:debt_destroyer/shared/models/payment.dart';

void main() {
  late AppDatabase database;
  late DriftDebtsRepository debtsRepository;
  late DriftPaymentsRepository paymentsRepository;
  late DriftDocumentsRepository documentsRepository;
  late DriftSubscriptionRepository subscriptionRepository;
  late Directory tempDir;
  late SecureDocumentVaultService vaultService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('repo_vault');
    vaultService = SecureDocumentVaultService(
      _FakeKeyService(),
      baseDirectoryLoader: () async => tempDir,
    );
    database = AppDatabase(NativeDatabase.memory());
    debtsRepository = DriftDebtsRepository(database, vaultService);
    paymentsRepository = DriftPaymentsRepository(database);
    documentsRepository = DriftDocumentsRepository(database, vaultService);
    subscriptionRepository = DriftSubscriptionRepository(database);
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  test('saving a payment recalculates debt balance', () async {
    final debt = Debt(
      id: 'd1',
      title: 'Visa',
      creditorName: 'Bank',
      type: DebtType.creditCard,
      currency: 'USD',
      originalBalance: 1000,
      currentBalance: 1000,
      apr: 20,
      minimumPayment: 60,
      dueDate: null,
      paymentFrequency: PaymentFrequency.monthly,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      notes: '',
      tags: const [],
      status: DebtStatus.active,
      remindersEnabled: false,
      customPriority: 1,
    );
    await debtsRepository.saveDebt(debt);

    await paymentsRepository.savePayment(
      Payment(
        id: 'p1',
        debtId: debt.id,
        amount: 250,
        date: DateTime(2026, 1, 20),
        method: 'ACH',
        sourceType: PaymentSourceType.manual,
        notes: '',
        tags: const [],
        createdAt: DateTime(2026, 1, 20),
      ),
    );

    final updated = await debtsRepository.loadDebts();
    expect(updated.single.currentBalance, 750);
    expect(updated.single.status, DebtStatus.active);
  });

  test('debt financial terms persist through repository mapping', () async {
    final debt = Debt(
      id: 'd-financial-terms',
      title: 'Rewards Card',
      creditorName: 'Bank',
      type: DebtType.creditCard,
      currency: 'USD',
      originalBalance: 2800,
      currentBalance: 2400,
      apr: 24.9,
      minimumPayment: 65,
      dueDate: DateTime(2026, 1, 15),
      paymentFrequency: PaymentFrequency.monthly,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      notes: '',
      tags: const [],
      status: DebtStatus.active,
      remindersEnabled: false,
      customPriority: 1,
      financialTerms: const DebtFinancialTerms(
        minimumPaymentRule: MinimumPaymentRule.maxOfFixedOrPercent,
        minimumPaymentPercent: 2,
        promoApr: 0,
        monthlyFee: 7,
        lateFee: 29,
        penaltyApr: 29.99,
      ),
    );

    await debtsRepository.saveDebt(debt);

    final loaded = await debtsRepository.loadDebts();

    expect(
      loaded.single.financialTerms.minimumPaymentRule,
      MinimumPaymentRule.maxOfFixedOrPercent,
    );
    expect(loaded.single.financialTerms.minimumPaymentPercent, 2);
    expect(loaded.single.financialTerms.monthlyFee, 7);
    expect(loaded.single.financialTerms.penaltyApr, 29.99);
  });

  test('unknown financial term enum values fall back safely', () async {
    await database
        .into(database.debtsTable)
        .insert(
          DebtsTableCompanion.insert(
            id: 'd-unknown-terms',
            title: 'Fallback terms',
            creditorName: 'Bank',
            type: DebtType.creditCard.name,
            currency: 'USD',
            originalBalance: 500,
            currentBalance: 450,
            apr: 18,
            minimumPayment: 35,
            paymentFrequency: PaymentFrequency.monthly.name,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            status: DebtStatus.active.name,
            financialTermsJson: Value(
              jsonEncode({
                'interestCompounding': 'futureCompounding',
                'minimumPaymentRule': 'futureRule',
                'monthlyFee': 3,
              }),
            ),
          ),
        );

    final loaded = await debtsRepository.loadDebts();
    final debt = loaded.singleWhere((item) => item.id == 'd-unknown-terms');

    expect(
      debt.financialTerms.interestCompounding,
      InterestCompounding.monthlyCompound,
    );
    expect(
      debt.financialTerms.minimumPaymentRule,
      MinimumPaymentRule.fixedAmount,
    );
    expect(debt.financialTerms.monthlyFee, 3);
  });

  test('paying full balance marks debt as paid off', () async {
    final debt = Debt(
      id: 'd2',
      title: 'BNPL',
      creditorName: 'Provider',
      type: DebtType.bnpl,
      currency: 'USD',
      originalBalance: 300,
      currentBalance: 300,
      apr: 0,
      minimumPayment: 50,
      dueDate: null,
      paymentFrequency: PaymentFrequency.monthly,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      notes: '',
      tags: const [],
      status: DebtStatus.active,
      remindersEnabled: false,
      customPriority: 1,
    );
    await debtsRepository.saveDebt(debt);

    await paymentsRepository.savePayment(
      Payment(
        id: 'p2',
        debtId: debt.id,
        amount: 300,
        date: DateTime(2026, 2, 1),
        method: null,
        sourceType: PaymentSourceType.manual,
        notes: '',
        tags: const [],
        createdAt: DateTime(2026, 2, 1),
      ),
    );

    final updated = await debtsRepository.loadDebts();
    expect(updated.single.currentBalance, 0);
    expect(updated.single.status, DebtStatus.paidOff);
  });

  test('deleting a debt purges linked encrypted documents', () async {
    final debt = Debt(
      id: 'd3',
      title: 'Card',
      creditorName: 'Bank',
      type: DebtType.creditCard,
      currency: 'USD',
      originalBalance: 500,
      currentBalance: 500,
      apr: 18,
      minimumPayment: 40,
      dueDate: null,
      paymentFrequency: PaymentFrequency.monthly,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      notes: '',
      tags: const [],
      status: DebtStatus.active,
      remindersEnabled: false,
      customPriority: 1,
    );
    await debtsRepository.saveDebt(debt);

    final source = File('${tempDir.path}/doc.txt')..writeAsStringSync('linked');
    final stored = await vaultService.sealImport(
      FileReference(
        path: source.path,
        sourceType: DocumentSourceType.gallery,
        mimeType: 'text/plain',
      ),
    );
    await documentsRepository.saveDocument(
      ImportedDocument(
        id: 'doc-1',
        storageRef: stored.storageRef,
        sourceType: DocumentSourceType.gallery,
        mimeType: 'text/plain',
        createdAt: DateTime(2026, 1, 2),
        lifecycleState: DocumentLifecycleState.linked,
        linkedDebtId: debt.id,
        rawOcrText: null,
        parseStatus: ParseStatus.success,
        parseVersion: 'v2',
        deleted: false,
        retentionExpiresAt: DateTime(2026, 4, 1),
        rawOcrExpiresAt: null,
        processedAt: DateTime(2026, 1, 2),
        linkedAt: DateTime(2026, 1, 2),
        pendingDeletionAt: null,
        purgedAt: null,
        encryptedAt: stored.encryptedAt,
        hasRawOcrText: false,
      ),
    );

    await debtsRepository.deleteDebt(debt.id);

    final documents = await documentsRepository.loadDocuments();
    expect(documents, isEmpty);
    expect(
      File(
        '${tempDir.path}${Platform.pathSeparator}secure_vault${Platform.pathSeparator}documents${Platform.pathSeparator}${stored.storageRef}',
      ).existsSync(),
      isFalse,
    );
  });

  test('document purge failure leaves database rows intact', () async {
    final failingDatabase = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => failingDatabase.close());
    final failingVault = _ThrowingVaultService();
    final failingDebtsRepository = DriftDebtsRepository(
      failingDatabase,
      failingVault,
    );
    final failingDocumentsRepository = DriftDocumentsRepository(
      failingDatabase,
      failingVault,
    );

    final debt = Debt(
      id: 'd4',
      title: 'Loan',
      creditorName: 'Credit Union',
      type: DebtType.personalLoan,
      currency: 'USD',
      originalBalance: 900,
      currentBalance: 900,
      apr: 12,
      minimumPayment: 75,
      dueDate: null,
      paymentFrequency: PaymentFrequency.monthly,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      notes: '',
      tags: const [],
      status: DebtStatus.active,
      remindersEnabled: false,
      customPriority: 2,
    );
    await failingDebtsRepository.saveDebt(debt);
    await failingDocumentsRepository.saveDocument(
      ImportedDocument(
        id: 'doc-failure',
        storageRef: 'missing.vault',
        sourceType: DocumentSourceType.gallery,
        mimeType: 'text/plain',
        createdAt: DateTime(2026, 1, 2),
        lifecycleState: DocumentLifecycleState.linked,
        linkedDebtId: debt.id,
        rawOcrText: 'OCR',
        parseStatus: ParseStatus.success,
        parseVersion: 'v2',
        deleted: false,
        retentionExpiresAt: DateTime(2026, 4, 1),
        rawOcrExpiresAt: DateTime(2026, 1, 3),
        processedAt: DateTime(2026, 1, 2),
        linkedAt: DateTime(2026, 1, 2),
        pendingDeletionAt: null,
        purgedAt: null,
        encryptedAt: DateTime(2026, 1, 2),
        hasRawOcrText: true,
      ),
    );
    await failingDocumentsRepository.saveParsedExtraction(
      ParsedExtraction(
        id: 'parse-failure',
        documentId: 'doc-failure',
        classification: DocumentClassification.genericFinanceScreenshot,
        confidence: 0.8,
        payloadJson: '{}',
        ambiguityNotes: '',
        createdAt: DateTime(2026, 1, 2),
      ),
    );

    await expectLater(
      failingDebtsRepository.deleteDebt(debt.id),
      throwsA(isA<StateError>()),
    );

    expect(await failingDocumentsRepository.loadDocuments(), isEmpty);
    final remainingDocuments = await failingDatabase
        .select(failingDatabase.importedDocumentsTable)
        .get();
    expect(remainingDocuments, hasLength(1));
    expect(
      remainingDocuments.single.lifecycleState,
      DocumentLifecycleState.pendingDeletion.name,
    );
    expect(
      await failingDatabase
          .select(failingDatabase.parsedExtractionsTable)
          .get(),
      hasLength(1),
    );
    expect(
      await failingDatabase.select(failingDatabase.debtsTable).get(),
      hasLength(1),
    );
  });

  test('loading subscription ignores unknown cached feature flags', () async {
    await database
        .into(database.subscriptionStateTable)
        .insert(
          SubscriptionStateTableCompanion.insert(
            key: Value(1),
            isPremium: Value(true),
            status: Value('active'),
            unlockedFeaturesJson: Value('["pdfImport","futureFlag"]'),
          ),
        );

    final subscription = await subscriptionRepository.loadSubscription();

    expect(subscription.isPremium, isTrue);
    expect(subscription.unlockedFeatures, {PremiumFeature.pdfImport});
  });

  test(
    'document lifecycle transitions from processed to linked to pending deletion',
    () async {
      final source = File('${tempDir.path}/lifecycle.txt')
        ..writeAsStringSync('lifecycle');
      final stored = await vaultService.sealImport(
        FileReference(
          path: source.path,
          sourceType: DocumentSourceType.gallery,
          mimeType: 'text/plain',
        ),
      );

      await documentsRepository.saveDocument(
        ImportedDocument(
          id: 'doc-lifecycle',
          storageRef: stored.storageRef,
          sourceType: DocumentSourceType.gallery,
          mimeType: 'text/plain',
          createdAt: DateTime(2026, 1, 2),
          lifecycleState: DocumentLifecycleState.processed,
          linkedDebtId: null,
          rawOcrText: null,
          parseStatus: ParseStatus.success,
          parseVersion: 'v2',
          deleted: false,
          retentionExpiresAt: DateTime(2026, 4, 1),
          rawOcrExpiresAt: null,
          processedAt: DateTime(2026, 1, 2),
          linkedAt: null,
          pendingDeletionAt: null,
          purgedAt: null,
          encryptedAt: stored.encryptedAt,
          hasRawOcrText: false,
        ),
      );

      await documentsRepository.linkDocument('doc-lifecycle', 'debt-1');
      var row = await (database.select(
        database.importedDocumentsTable,
      )..where((tbl) => tbl.id.equals('doc-lifecycle'))).getSingle();
      expect(row.lifecycleState, DocumentLifecycleState.linked.name);
      expect(row.linkedAt, isA<DateTime>());

      await documentsRepository.markDeleted('doc-lifecycle');
      row = await (database.select(
        database.importedDocumentsTable,
      )..where((tbl) => tbl.id.equals('doc-lifecycle'))).getSingle();
      expect(row.lifecycleState, DocumentLifecycleState.pendingDeletion.name);
      expect(row.pendingDeletionAt, isA<DateTime>());
    },
  );

  test('linkDocument preserves existing processedAt timestamp', () async {
    final source = File('${tempDir.path}/processed-preserve.txt')
      ..writeAsStringSync('preserve');
    final stored = await vaultService.sealImport(
      FileReference(
        path: source.path,
        sourceType: DocumentSourceType.gallery,
        mimeType: 'text/plain',
      ),
    );
    final processedAt = DateTime(2026, 1, 3, 8);

    await documentsRepository.saveDocument(
      ImportedDocument(
        id: 'doc-processed-preserve',
        storageRef: stored.storageRef,
        sourceType: DocumentSourceType.gallery,
        mimeType: 'text/plain',
        createdAt: DateTime(2026, 1, 2),
        lifecycleState: DocumentLifecycleState.processed,
        linkedDebtId: null,
        rawOcrText: null,
        parseStatus: ParseStatus.success,
        parseVersion: 'v2',
        deleted: false,
        retentionExpiresAt: DateTime(2026, 4, 1),
        rawOcrExpiresAt: null,
        processedAt: processedAt,
        linkedAt: null,
        pendingDeletionAt: null,
        purgedAt: null,
        encryptedAt: stored.encryptedAt,
        hasRawOcrText: false,
      ),
    );

    await documentsRepository.linkDocument('doc-processed-preserve', 'debt-2');

    final row = await (database.select(
      database.importedDocumentsTable,
    )..where((tbl) => tbl.id.equals('doc-processed-preserve'))).getSingle();
    expect(row.processedAt, processedAt);
    expect(row.lifecycleState, DocumentLifecycleState.linked.name);
  });

  test(
    'repeated purge attempts preserve original pending deletion timestamp',
    () async {
      final failingDatabase = AppDatabase(NativeDatabase.memory());
      addTearDown(() async => failingDatabase.close());
      final documents = DriftDocumentsRepository(
        failingDatabase,
        _ThrowingVaultService(),
      );
      final pendingAt = DateTime(2026, 1, 4, 10);

      await documents.saveDocument(
        ImportedDocument(
          id: 'doc-pending-preserve',
          storageRef: 'missing.vault',
          sourceType: DocumentSourceType.gallery,
          mimeType: 'text/plain',
          createdAt: DateTime(2026, 1, 2),
          lifecycleState: DocumentLifecycleState.pendingDeletion,
          linkedDebtId: null,
          rawOcrText: null,
          parseStatus: ParseStatus.failed,
          parseVersion: 'v2',
          deleted: true,
          retentionExpiresAt: DateTime(2026, 4, 1),
          rawOcrExpiresAt: null,
          processedAt: null,
          linkedAt: null,
          pendingDeletionAt: pendingAt,
          purgedAt: null,
          encryptedAt: DateTime(2026, 1, 2),
          hasRawOcrText: false,
        ),
      );

      await expectLater(
        documents.purgeDocument('doc-pending-preserve'),
        throwsA(isA<StateError>()),
      );

      final row = await (failingDatabase.select(
        failingDatabase.importedDocumentsTable,
      )..where((tbl) => tbl.id.equals('doc-pending-preserve'))).getSingle();
      expect(row.pendingDeletionAt, pendingAt);
    },
  );
}

class _FakeKeyService extends LocalVaultKeyService {
  _FakeKeyService();

  final Uint8List _key = Uint8List.fromList(
    List<int>.generate(32, (index) => index + 11),
  );

  @override
  Future<Uint8List> ensureRootKey() async => _key;

  @override
  Future<String> databasePassphrase() async => base64Encode(_key);

  @override
  Future<SecretKey> documentSecretKey() async => SecretKey(_key);
}

class _ThrowingVaultService extends SecureDocumentVaultService {
  _ThrowingVaultService() : super(_FakeKeyService());

  @override
  Future<void> purgeStoredDocument(String? storageRef) {
    throw StateError('simulated purge failure');
  }
}
