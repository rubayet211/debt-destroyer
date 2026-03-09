import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/scan_import/presentation/scan_screens.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/import_models.dart';
import 'package:debt_destroyer/shared/models/payment.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

void main() {
  testWidgets(
    'review screen renders statement summary and selectable line items',
    (tester) async {
      final bundle = ImportReviewBundle(
        document: ImportedDocument(
          id: 'doc-1',
          storageRef: 'vault-1',
          sourceType: DocumentSourceType.pdf,
          mimeType: 'application/pdf',
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
        normalizedText:
            'ACME BANK CREDIT CARD STATEMENT\n02/05/2026 ONLINE PAYMENT THANK YOU 250.00',
        candidate: const ExtractionCandidate(
          title: 'Acme Statement',
          creditorName: 'Acme Bank',
          debtType: DebtType.creditCard,
          currentBalance: 1240.55,
          minimumPayment: 75,
          currency: 'USD',
          confidence: 0.88,
        ),
        summary: const StatementSummaryCandidate(
          title: 'Acme Statement',
          creditorName: 'Acme Bank',
          debtType: DebtType.creditCard,
          currentBalance: 1240.55,
          minimumPayment: 75,
          currency: 'USD',
          confidence: 0.88,
        ),
        statementLineItems: [
          StatementLineItemCandidate(
            id: 'item-1',
            description: 'ONLINE PAYMENT THANK YOU',
            amount: 250,
            type: StatementLineItemType.payment,
            confidence: 0.82,
            date: DateTime(2026, 2, 5),
          ),
          StatementLineItemCandidate(
            id: 'item-2',
            description: 'INTEREST CHARGE',
            amount: -12.33,
            type: StatementLineItemType.interest,
            confidence: 0.64,
            date: DateTime(2026, 2, 15),
          ),
        ],
        issues: const [
          ImportIssue(
            code: 'statement_items_need_review',
            message:
                'Statement line items were detected, but some rows need review.',
          ),
        ],
        reviewMode: ImportReviewMode.statementItems,
        errorMessage: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            debtsProvider.overrideWith((_) => Stream.value(const <Debt>[])),
          ],
          child: MaterialApp(home: ParsedReviewConfirmScreen(bundle: bundle)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Import statement payments'), findsOneWidget);
      expect(find.textContaining('Statement line items'), findsOneWidget);
      expect(
        find.textContaining('Review mode: statementItems'),
        findsOneWidget,
      );
    },
  );

  testWidgets('review screen blocks add payment when resolved amount is zero', (
    tester,
  ) async {
    final documentsRepository = _TestDocumentsRepository();
    final paymentsRepository = _TestPaymentsRepository();
    final debt = Debt(
      id: 'debt-1',
      title: 'Visa',
      creditorName: 'Acme Bank',
      type: DebtType.creditCard,
      currency: 'USD',
      originalBalance: 1000,
      currentBalance: 800,
      apr: 18.9,
      minimumPayment: 40,
      dueDate: DateTime(2026, 3, 15),
      paymentFrequency: PaymentFrequency.monthly,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 3, 1),
      notes: '',
      tags: const [],
      status: DebtStatus.active,
      remindersEnabled: true,
      customPriority: 1,
    );
    final bundle = ImportReviewBundle(
      document: ImportedDocument(
        id: 'doc-2',
        storageRef: 'vault-2',
        sourceType: DocumentSourceType.gallery,
        mimeType: 'image/png',
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
      normalizedText: 'ACME CREDIT CARD STATEMENT',
      candidate: const ExtractionCandidate(
        title: 'Acme Statement',
        creditorName: 'Acme Bank',
        debtType: DebtType.creditCard,
        currency: 'USD',
        confidence: 0.7,
      ),
      summary: const StatementSummaryCandidate(
        title: 'Acme Statement',
        creditorName: 'Acme Bank',
        debtType: DebtType.creditCard,
        currency: 'USD',
        confidence: 0.7,
      ),
      statementLineItems: const [],
      issues: const [],
      reviewMode: ImportReviewMode.summaryOnly,
      errorMessage: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          debtsProvider.overrideWith((_) => Stream.value([debt])),
          documentsRepositoryProvider.overrideWithValue(documentsRepository),
          paymentsRepositoryProvider.overrideWithValue(paymentsRepository),
          userPreferencesProvider.overrideWith(
            (_) => Stream.value(UserPreferences.defaults()),
          ),
          paymentsByDebtProvider(
            debt.id,
          ).overrideWith((_) => Stream.value(const <Payment>[])),
        ],
        child: MaterialApp(home: ParsedReviewConfirmScreen(bundle: bundle)),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<ImportActionType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add payment').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visa').last);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(
      find.text('Enter a payment amount or select a payment-like line item.'),
      findsOneWidget,
    );
    expect(paymentsRepository.savedPayments, isEmpty);
  });

  testWidgets('review screen surfaces parse failure and manual fallback copy', (
    tester,
  ) async {
    final bundle = ImportReviewBundle(
      document: ImportedDocument(
        id: 'doc-failure',
        storageRef: 'vault-failure',
        sourceType: DocumentSourceType.gallery,
        mimeType: 'image/png',
        createdAt: DateTime(2026, 3, 1),
        lifecycleState: DocumentLifecycleState.processed,
        linkedDebtId: null,
        rawOcrText: null,
        parseStatus: ParseStatus.failed,
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
      classification: DocumentClassification.unknown,
      normalizedText: 'blurry screenshot with weak OCR',
      candidate: const ExtractionCandidate(
        title: 'Imported debt',
        debtType: DebtType.other,
        confidence: 0.22,
      ),
      summary: const StatementSummaryCandidate(
        title: 'Imported debt',
        debtType: DebtType.other,
        confidence: 0.22,
      ),
      statementLineItems: const [],
      issues: const [
        ImportIssue(
          code: 'manual_fallback_required',
          message:
              'The parser was uncertain. Review fields manually before saving.',
        ),
      ],
      reviewMode: ImportReviewMode.manualFallback,
      errorMessage:
          'Parsing was only partially successful. Manual correction is required.',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          debtsProvider.overrideWith((_) => Stream.value(const <Debt>[])),
        ],
        child: MaterialApp(home: ParsedReviewConfirmScreen(bundle: bundle)),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text(
        'Parsing was only partially successful. Manual correction is required.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'The parser was uncertain. Review fields manually before saving.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Review mode: manualFallback'), findsOneWidget);
  });
}

class _TestDocumentsRepository implements DocumentsRepository {
  final List<ImportedDocument> savedDocuments = [];

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
  Future<void> saveParsedExtraction(ParsedExtraction extraction) async {}

  @override
  Future<void> trimRawOcr(String documentId) async {}

  @override
  Stream<List<ImportedDocument>> watchDocuments({String? debtId}) =>
      Stream.value(const <ImportedDocument>[]);
}

class _TestPaymentsRepository implements PaymentsRepository {
  final List<Payment> savedPayments = [];

  @override
  Future<void> deletePayment(String id) async {}

  @override
  Future<List<Payment>> loadAllPayments() async => const [];

  @override
  Future<List<Payment>> loadPaymentsForDebt(String debtId) async => const [];

  @override
  Future<void> savePayment(Payment payment) async {
    savedPayments.add(payment);
  }

  @override
  Stream<List<Payment>> watchAllPayments() => Stream.value(const <Payment>[]);

  @override
  Stream<List<Payment>> watchPaymentsForDebt(String debtId) =>
      Stream.value(const <Payment>[]);

  @override
  Stream<List<Payment>> watchRecentPayments({int limit = 10}) =>
      Stream.value(const <Payment>[]);
}
