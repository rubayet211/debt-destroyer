import 'package:intl/intl.dart';

import '../../shared/enums/app_enums.dart';

class Formatters {
  static String currency(
    num value, {
    required String currencyCode,
    bool obscure = false,
  }) {
    if (obscure) {
      return '••••';
    }

    return NumberFormat.currency(symbol: _symbol(currencyCode)).format(value);
  }

  static String percent(double value) => '${value.toStringAsFixed(2)}%';

  static String date(DateTime? value) {
    if (value == null) {
      return 'Not set';
    }

    return DateFormat.yMMMd().format(value);
  }

  static String shortMonth(DateTime value) => DateFormat.MMM().format(value);

  static String paymentFrequency(PaymentFrequency frequency) {
    switch (frequency) {
      case PaymentFrequency.weekly:
        return 'Weekly';
      case PaymentFrequency.biweekly:
        return 'Biweekly';
      case PaymentFrequency.monthly:
        return 'Monthly';
      case PaymentFrequency.quarterly:
        return 'Quarterly';
    }
  }

  static String strategyLabel(StrategyType strategy) {
    switch (strategy) {
      case StrategyType.snowball:
        return 'Snowball';
      case StrategyType.avalanche:
        return 'Avalanche';
      case StrategyType.customPriority:
        return 'Custom priority';
    }
  }

  static String debtType(DebtType type) {
    switch (type) {
      case DebtType.creditCard:
        return 'Credit card';
      case DebtType.personalLoan:
        return 'Personal loan';
      case DebtType.studentLoan:
        return 'Student loan';
      case DebtType.carLoan:
        return 'Car loan';
      case DebtType.mortgage:
        return 'Mortgage';
      case DebtType.bnpl:
        return 'BNPL';
      case DebtType.familyLoan:
        return 'Family or friend';
      case DebtType.utilityArrears:
        return 'Utility arrears';
      case DebtType.other:
        return 'Other';
    }
  }

  static String documentClassification(DocumentClassification classification) {
    switch (classification) {
      case DocumentClassification.creditCardStatement:
        return 'Credit card statement';
      case DocumentClassification.loanStatement:
        return 'Loan statement';
      case DocumentClassification.bnplDashboard:
        return 'BNPL dashboard';
      case DocumentClassification.receipt:
        return 'Receipt';
      case DocumentClassification.genericBill:
        return 'Bill';
      case DocumentClassification.genericFinanceScreenshot:
        return 'Finance screenshot';
      case DocumentClassification.unknown:
        return 'Unknown';
    }
  }

  static String _symbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'BDT':
        return '৳';
      default:
        return '$currencyCode ';
    }
  }
}
