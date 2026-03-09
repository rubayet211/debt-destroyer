import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/scan_import/presentation/scan_screens.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/import_models.dart';
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
}
