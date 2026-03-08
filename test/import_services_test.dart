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

      expect(candidate.currentBalance, 1240.55);
      expect(candidate.minimumPayment, 75);
      expect(candidate.aprPercentage, 19.9);
      expect(candidate.currency, 'USD');
      expect(candidate.debtType, DebtType.creditCard);
    });

    test('keeps manual fallback viable when classification is unknown', () {
      final candidate = parser.parse(
        DocumentClassification.unknown,
        'random OCR text without reliable fields',
      );

      expect(candidate.confidence, lessThan(0.5));
      expect(candidate.title, isNotEmpty);
    });
  });
}
