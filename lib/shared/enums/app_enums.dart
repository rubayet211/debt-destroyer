import 'package:flutter/material.dart';

enum ThemePreference { system, light, dark }

enum DocumentRetentionMode { days7, days30, manual }

enum DocumentLifecycleState {
  imported,
  processed,
  linked,
  pendingDeletion,
  purged,
}

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

enum InterestCompounding { none, dailySimple, monthlyCompound }

enum MinimumPaymentRule {
  fixedAmount,
  maxOfFixedOrPercent,
  interestPlusPercent,
}

enum DocumentSourceType { camera, gallery, screenshot, pdf, receipt, bill }

enum ParseStatus { pending, success, failed, discarded }

enum StrategyType { snowball, avalanche, customPriority }

enum ProjectionWarning {
  underMinimumBudget,
  overdueDebt,
  promoRateApplied,
  recurringFeesApplied,
  lateFeesApplied,
  penaltyAprApplied,
  mixedPaymentFrequencies,
}

enum PremiumFeature {
  unlimitedScans,
  pdfImport,
  advancedReports,
  csvExport,
  scenarioSaving,
  advancedStrategyComparison,
  premiumThemes,
}

PremiumFeature? premiumFeatureByNameOrNull(String name) {
  for (final feature in PremiumFeature.values) {
    if (feature.name == name) {
      return feature;
    }
  }
  return null;
}

Set<PremiumFeature> decodePremiumFeatures(Iterable<Object?> values) {
  final features = <PremiumFeature>{};
  for (final value in values) {
    if (value == null) {
      continue;
    }
    final feature = premiumFeatureByNameOrNull(value.toString());
    if (feature != null) {
      features.add(feature);
    }
  }
  return features;
}

enum ImportActionType { createDebt, addPayment, importStatementItems }

enum StatementLineItemType { payment, charge, fee, interest, other }

enum ImportReviewMode { summaryOnly, statementItems, manualFallback }

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
