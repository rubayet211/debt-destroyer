import 'package:flutter/material.dart';

enum ThemePreference { system, light, dark }

extension ThemePreferenceX on ThemePreference {
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}

enum DebtType {
  creditCard,
  personalLoan,
  studentLoan,
  carLoan,
  mortgage,
  bnpl,
  familyLoan,
  utilityArrears,
  other,
}

enum PaymentFrequency { weekly, biweekly, monthly, quarterly }

enum DebtStatus { active, paidOff, archived }

enum DocumentSourceType { camera, gallery, screenshot, pdf, receipt, bill }

enum ParseStatus { pending, success, failed, discarded }

enum StrategyType { snowball, avalanche, customPriority }

enum PremiumFeature {
  unlimitedScans,
  pdfImport,
  advancedReports,
  csvExport,
  scenarioSaving,
  advancedStrategyComparison,
  premiumThemes,
}

enum ImportActionType { createDebt, addPayment, importStatementItems }

enum DocumentClassification {
  creditCardStatement,
  loanStatement,
  bnplDashboard,
  receipt,
  genericBill,
  genericFinanceScreenshot,
  unknown,
}

enum PaymentSourceType { manual, scan, imported }

enum ImportProcessingState { idle, loading, success, error }
