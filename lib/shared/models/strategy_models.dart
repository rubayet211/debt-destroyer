import '../enums/app_enums.dart';
import 'debt.dart';

class Scenario {
  const Scenario({
    required this.id,
    required this.strategyType,
    required this.extraPayment,
    required this.budget,
    required this.createdAt,
    required this.label,
    required this.baselineInterest,
    required this.optimizedInterest,
    required this.monthsToPayoff,
  });

  final String id;
  final StrategyType strategyType;
  final double extraPayment;
  final double budget;
  final DateTime createdAt;
  final String label;
  final double baselineInterest;
  final double optimizedInterest;
  final int monthsToPayoff;
}

class StrategyRequest {
  const StrategyRequest({
    required this.strategyType,
    required this.monthlyBudget,
    required this.extraMonthlyPayment,
    required this.startDate,
    required this.lumpSum,
    required this.includeArchived,
    required this.customPriorities,
    this.projectionAsOf,
    this.comparisonStrategy,
    this.allowUnderMinimumBudget = true,
  });

  final StrategyType strategyType;
  final double monthlyBudget;
  final double extraMonthlyPayment;
  final DateTime startDate;
  final double lumpSum;
  final bool includeArchived;
  final Map<String, int> customPriorities;
  final DateTime? projectionAsOf;
  final StrategyType? comparisonStrategy;
  final bool allowUnderMinimumBudget;
}

class StrategyDebtSnapshot {
  const StrategyDebtSnapshot({
    required this.debtId,
    required this.title,
    required this.openingBalance,
    required this.interestAccrued,
    required this.feesAccrued,
    required this.minimumDue,
    required this.minimumPaymentApplied,
    required this.extraPaymentApplied,
    required this.endingBalance,
    required this.activeApr,
    required this.overdue,
    required this.shortfall,
  });

  final String debtId;
  final String title;
  final double openingBalance;
  final double interestAccrued;
  final double feesAccrued;
  final double minimumDue;
  final double minimumPaymentApplied;
  final double extraPaymentApplied;
  final double endingBalance;
  final double activeApr;
  final bool overdue;
  final double shortfall;

  double get balanceBeforePayment =>
      openingBalance + interestAccrued + feesAccrued;

  double get paymentApplied => minimumPaymentApplied + extraPaymentApplied;

  double get balanceAfterPayment => endingBalance;
}

class StrategyMonthResult {
  const StrategyMonthResult({
    required this.monthIndex,
    required this.date,
    required this.totalPaid,
    required this.totalInterest,
    required this.totalFees,
    required this.remainingBalance,
    required this.minimumRequired,
    required this.budgetShortfall,
    required this.debts,
  });

  final int monthIndex;
  final DateTime date;
  final double totalPaid;
  final double totalInterest;
  final double totalFees;
  final double remainingBalance;
  final double minimumRequired;
  final double budgetShortfall;
  final List<StrategyDebtSnapshot> debts;
}

class StrategySummary {
  const StrategySummary({
    required this.strategyType,
    required this.payoffDate,
    required this.totalInterestPaid,
    required this.monthsToPayoff,
  });

  final StrategyType strategyType;
  final DateTime payoffDate;
  final double totalInterestPaid;
  final int monthsToPayoff;
}

class StrategyResult {
  const StrategyResult({
    required this.strategyType,
    required this.payoffDate,
    required this.totalInterestPaid,
    required this.totalInterestSaved,
    required this.monthsToPayoff,
    required this.payoffOrder,
    required this.schedule,
    required this.baselineInterest,
    this.minimumRequiredPerCycle = 0,
    this.budgetShortfall = 0,
    this.warnings = const [],
    this.baselineResult,
  });

  final StrategyType strategyType;
  final DateTime payoffDate;
  final double totalInterestPaid;
  final double totalInterestSaved;
  final int monthsToPayoff;
  final List<Debt> payoffOrder;
  final List<StrategyMonthResult> schedule;
  final double baselineInterest;
  final double minimumRequiredPerCycle;
  final double budgetShortfall;
  final List<ProjectionWarning> warnings;
  final StrategySummary? baselineResult;
}
