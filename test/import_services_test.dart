import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/scan_import/domain/import_services.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';

void main() {
  group('Import parsing', () {
    final parser = HeuristicExtractionParser();
    final validator = ParseValidationService();
    final classifier = DocumentClassifier();

    test('classifies credit card style statements', () {
      final classification = classifier.classify(
        'CREDIT CARD STATEMENT\nCurrent balance: \$1200\nMinimum payment: \$35',
      );

      expect(classification, DocumentClassification.creditCardStatement);
    });

    test('parses and sanitizes common debt fields', () {
      final candidate = validator.validate(
        parser.parse(
          DocumentClassification.creditCardStatement,
          'Acme Bank\nCurrent balance: \$1,240.55\nMinimum payment: \$75\nAPR 19.9%\nDue: 03/15/2026',
        ),
      );

      expect(candidate.summary.currentBalance, 1240.55);
      expect(candidate.summary.minimumPayment, 75);
      expect(candidate.summary.aprPercentage, 19.9);
      expect(candidate.summary.currency, 'USD');
      expect(candidate.summary.debtType, DebtType.creditCard);
    });

    test('keeps manual fallback viable when classification is unknown', () {
      final candidate = parser.parse(
        DocumentClassification.unknown,
        'random OCR text without reliable fields',
      );

      expect(candidate.summary.confidence, lessThan(0.5));
      expect(candidate.summary.title, isNotEmpty);
    });

    test('extracts multiple statement line items from tabular text', () {
      final result = validator.validate(
        parser.parse(DocumentClassification.creditCardStatement, '''
ACME BANK CREDIT CARD STATEMENT
Statement Period 02/01/2026 - 02/29/2026
02/05/2026 ONLINE PAYMENT THANK YOU 250.00
02/12/2026 AMAZON MARKETPLACE 85.42
02/15/2026 INTEREST CHARGE 12.33
Current balance: \$1,240.55
Minimum payment: \$75
'''),
      );

      expect(result.statementLineItems, hasLength(3));
      expect(
        result.statementLineItems.where((item) => item.isPaymentLike),
        hasLength(1),
      );
    });

    test('flags ambiguous statement dates without guessing silently', () {
      final result = validator.validate(
        parser.parse(DocumentClassification.creditCardStatement, '''
03/05 ONLINE PAYMENT THANK YOU 200.00
03/12 GROCERY STORE 44.50
'''),
      );

      expect(
        result.statementLineItems.any(
          (item) => item.warnings.contains('ambiguous_date'),
        ),
        true,
      );
    });

    test('does not treat generic "from" lines as statement periods', () {
      final result = validator.validate(
        parser.parse(DocumentClassification.creditCardStatement, '''
ACME CREDIT CARD STATEMENT
Payment from checking account 250.00
Current balance: \$1,240.55
Minimum payment: \$75
'''),
      );

      expect(result.summary.statementStartDate, isNull);
      expect(result.summary.statementEndDate, isNull);
      expect(result.summary.labels, isNot(contains('statement period')));
    });
  });
}
