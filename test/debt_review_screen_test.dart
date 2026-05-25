import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:debt_destroyer/features/scan_import/presentation/debt_review_screen.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/import_models.dart';
import 'package:debt_destroyer/shared/models/payment.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('debt review shows editable parsed fields and plan preview', (
    tester,
  ) async {
    await tester.pumpDebtReviewScreen(
      bundle: _bundle(
        confidence: 0.42,
        candidate: const ExtractionCandidate(
          creditorName: 'Acme Bank',
          currentBalance: 1280.45,
          aprPercentage: null,
          minimumPayment: 65,
          confidence: 0.42,
        ),
      ),
      existingDebts: [
        buildTestDebt(id: 'existing', currentBalance: 900, minimumPayment: 60),
      ],
    );

    expect(find.text('Review & Confirm'), findsOneWidget);
    expect(find.text('Creditor name'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Interest rate (APR)'), findsOneWidget);
    expect(find.text('Minimum payment'), findsOneWidget);
    expect(find.text('Due date'), findsOneWidget);
    expect(find.text('Needs review'), findsWidgets);
    expect(find.textContaining('Payoff plan preview'), findsOneWidget);
    expect(find.text('Save Debt'), findsOneWidget);
    expect(find.text('Edit / Rescan'), findsOneWidget);
    expect(
      find.text(
        'You can always edit this later. We recommend double-checking the numbers.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('debt review validates balance and apr before saving', (
    tester,
  ) async {
    final repos = _FakeRepositories();
    await tester.pumpDebtReviewScreen(
      bundle: _bundle(
        candidate: const ExtractionCandidate(
          creditorName: 'Acme Bank',
          currentBalance: 0,
          aprPercentage: 120,
          minimumPayment: 50,
          confidence: 0.9,
        ),
      ),
      repositories: repos,
    );

    await tester.tap(find.text('Save Debt'));
    await tester.pumpAndSettle();

    expect(find.text('Balance must be greater than 0'), findsOneWidget);
    expect(find.text('APR must be between 0 and 100'), findsOneWidget);
    expect(repos.debts.savedDebts, isEmpty);
  });

  testWidgets('debt review saves edited debt through local repositories', (
    tester,
  ) async {
    final repos = _FakeRepositories();
    await tester.pumpDebtReviewScreen(
      bundle: _bundle(
        candidate: const ExtractionCandidate(
          creditorName: 'Acme Bank',
          currentBalance: 1280,
          aprPercentage: 19.9,
          minimumPayment: 65,
          confidence: 0.9,
        ),
      ),
      repositories: repos,
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Balance'),
      '1400',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Interest rate (APR)'),
      '21.5',
    );
    await tester.tap(find.text('Save Debt'));
    await tester.pumpAndSettle();

    expect(repos.documents.savedDocuments, hasLength(1));
    expect(repos.documents.savedExtractions, hasLength(1));
    expect(repos.debts.savedDebts, hasLength(1));
    expect(repos.debts.savedDebts.single.currentBalance, 1400);
    expect(repos.debts.savedDebts.single.apr, 21.5);
  });

  testWidgets('pdf review can save multiple debts from one document', (
    tester,
  ) async {
    final repos = _FakeRepositories();
    await tester.pumpDebtReviewScreen(
      bundle: _bundle(
        sourceType: DocumentSourceType.pdf,
        mimeType: 'application/pdf',
        candidate: const ExtractionCandidate(
          creditorName: 'Acme Bank',
          currentBalance: 1280,
          aprPercentage: 19.9,
          minimumPayment: 65,
          confidence: 0.9,
        ),
      ),
      repositories: repos,
    );

    await tester.tap(find.text('Add another debt'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Creditor name'),
      'Second Bank',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Balance'),
      '700',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Interest rate (APR)'),
      '8',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Minimum payment'),
      '50',
    );
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Debt'));
    await tester.pumpAndSettle();

    expect(repos.debts.savedDebts, hasLength(2));
    expect(
      repos.debts.savedDebts.map((debt) => debt.creditorName),
      containsAll(['Acme Bank', 'Second Bank']),
    );
  });
}

extension on WidgetTester {
  Future<void> pumpDebtReviewScreen({
    required ImportReviewBundle bundle,
    List<Debt> existingDebts = const [],
    _FakeRepositories? repositories,
  }) async {
    final repos = repositories ?? _FakeRepositories();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => DebtReviewScreen(bundle: bundle),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const Scaffold(body: Text('Dashboard')),
        ),
        GoRoute(path: '/scan', builder: (_, __) => const Scaffold()),
      ],
    );

    await pumpWidget(
      ProviderScope(
        overrides: [
          debtsProvider.overrideWith((_) => Stream.value(existingDebts)),
          userPreferencesProvider.overrideWith(
            (_) => Stream.value(UserPreferences.defaults()),
          ),
          debtsRepositoryProvider.overrideWithValue(repos.debts),
          documentsRepositoryProvider.overrideWithValue(repos.documents),
          paymentsRepositoryProvider.overrideWithValue(repos.payments),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await pumpAndSettle();
  }
}

ImportReviewBundle _bundle({
  DocumentSourceType sourceType = DocumentSourceType.gallery,
  String mimeType = 'image/png',
  double confidence = 0.9,
  ExtractionCandidate candidate = const ExtractionCandidate(
    creditorName: 'Acme Bank',
    currentBalance: 1280,
    aprPercentage: 19.9,
    minimumPayment: 65,
    confidence: 0.9,
  ),
}) {
  return ImportReviewBundle(
    document: ImportedDocument(
      id: 'doc-review',
      storageRef: 'vault-review',
      sourceType: sourceType,
      mimeType: mimeType,
      createdAt: DateTime(2026, 3, 1),
      lifecycleState: DocumentLifecycleState.processed,
      linkedDebtId: null,
      rawOcrText: null,
      parseStatus: ParseStatus.success,
      parseVersion: 'v1',
      deleted: false,
      retentionExpiresAt: null,
      rawOcrExpiresAt: null,
      processedAt: DateTime(2026, 3, 1),
      linkedAt: null,
      pendingDeletionAt: null,
      purgedAt: null,
      encryptedAt: DateTime(2026, 3, 1),
      hasRawOcrText: false,
    ),
    classification: DocumentClassification.creditCardStatement,
    normalizedText: 'ACME BANK CREDIT CARD STATEMENT',
    candidate: candidate.copyWith(confidence: confidence),
    summary: StatementSummaryCandidate(
      creditorName: candidate.creditorName,
      currentBalance: candidate.currentBalance,
      aprPercentage: candidate.aprPercentage,
      minimumPayment: candidate.minimumPayment,
      dueDate: candidate.dueDate,
      currency: candidate.currency,
      confidence: confidence,
    ),
    statementLineItems: const [],
    issues: confidence < 0.65
        ? const [
            ImportIssue(
              code: 'low_confidence',
              message: 'Extraction confidence is low.',
            ),
          ]
        : const [],
    reviewMode: confidence < 0.65
        ? ImportReviewMode.manualFallback
        : ImportReviewMode.summaryOnly,
    errorMessage: null,
  );
}

class _FakeRepositories {
  final debts = _FakeDebtsRepository();
  final documents = _FakeDocumentsRepository();
  final payments = _FakePaymentsRepository();
}

class _FakeDocumentsRepository implements DocumentsRepository {
  final List<ImportedDocument> savedDocuments = [];
  final List<ParsedExtraction> savedExtractions = [];

  @override
  Future<int> countSuccessfulScansInMonth(DateTime month) async => 0;

  @override
  Future<List<ImportedDocument>> loadDocuments({String? debtId}) async =>
      const [];

  @override
  Future<void> linkDocument(String documentId, String? debtId) async {}

  @override
  Future<void> markDeleted(String documentId) async {}

  @override
  Future<void> purgeAllDocuments() async {}

  @override
  Future<void> purgeAllRawOcr() async {}

  @override
  Future<void> purgeDocument(String documentId) async {}

  @override
  Future<void> purgeExpiredDocuments(DateTime now) async {}

  @override
  Future<Uint8List?> readDocumentBytes(String documentId) async => null;

  @override
  Future<void> saveDocument(ImportedDocument document) async {
    savedDocuments.add(document);
  }

  @override
  Future<void> saveParsedExtraction(ParsedExtraction extraction) async {
    savedExtractions.add(extraction);
  }

  @override
  Future<void> trimRawOcr(String documentId) async {}

  @override
  Stream<List<ImportedDocument>> watchDocuments({String? debtId}) =>
      Stream.value(const <ImportedDocument>[]);
}

class _FakeDebtsRepository implements DebtsRepository {
  final List<Debt> savedDebts = [];

  @override
  Future<void> archiveDebt(String id) async {}

  @override
  Future<void> deleteDebt(String id) async {}

  @override
  Future<List<Debt>> loadDebts({bool includeArchived = false}) async =>
      savedDebts;

  @override
  Future<void> markPaidOff(String id) async {}

  @override
  Future<void> restoreDebt(String id) async {}

  @override
  Future<void> saveDebt(Debt debt) async {
    savedDebts.add(debt);
  }

  @override
  Stream<Debt?> watchDebt(String id) => Stream.value(null);

  @override
  Stream<List<Debt>> watchDebts({bool includeArchived = false}) =>
      Stream.value(savedDebts);
}

class _FakePaymentsRepository implements PaymentsRepository {
  @override
  Future<void> deletePayment(String id) async {}

  @override
  Future<List<Payment>> loadAllPayments() async => const [];

  @override
  Future<List<Payment>> loadPaymentsForDebt(String debtId) async => const [];

  @override
  Future<void> savePayment(Payment payment) async {}

  @override
  Stream<List<Payment>> watchAllPayments() => Stream.value(const []);

  @override
  Stream<List<Payment>> watchPaymentsForDebt(String debtId) =>
      Stream.value(const []);

  @override
  Stream<List<Payment>> watchRecentPayments({int limit = 10}) =>
      Stream.value(const []);
}
