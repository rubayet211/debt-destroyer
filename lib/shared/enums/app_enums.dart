import 'package:flutter/material.dart';

enum ThemePreference { system, light, dark }

enum DocumentRetentionMode { days7, days30, manual }

enum AppRelockTimeout { immediate, seconds30, minutes5 }

extension AppRelockTimeoutX on AppRelockTimeout {
  Duration get duration {
    return switch (this) {
      AppRelockTimeout.immediate => Duration.zero,
      AppRelockTimeout.seconds30 => const Duration(seconds: 30),
      AppRelockTimeout.minutes5 => const Duration(minutes: 5),
    };
  }
}

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

enum ReminderKind {
  dueLead,
  dueToday,
  overdueDay1,
  overdueDay3,
  overdueDay7,
  weeklySummary,
  milestone,
}

enum MilestoneKind {
  progress25,
  progress50,
  progress75,
  paidOff,
  bootstrapSeeded,
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

enum AuthOutcome {
  success,
  cancelled,
  unavailable,
  temporaryLockout,
  permanentLockout,
  error,
}
