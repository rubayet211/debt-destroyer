import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/core/services/vault_services.dart';
import 'package:debt_destroyer/features/scan_import/domain/import_services.dart';
import 'package:debt_destroyer/shared/data/local/app_database.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/import_models.dart';
import 'package:debt_destroyer/shared/models/payment.dart';

void main() {
  late AppDatabase database;
  late DriftDebtsRepository debtsRepository;
  late DriftPaymentsRepository paymentsRepository;
  late DriftDocumentsRepository documentsRepository;
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
        linkedDebtId: debt.id,
        rawOcrText: null,
        parseStatus: ParseStatus.success,
        parseVersion: 'v2',
        deleted: false,
        retentionExpiresAt: DateTime(2026, 4, 1),
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
