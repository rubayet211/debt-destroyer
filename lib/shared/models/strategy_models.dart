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
  });

  final StrategyType strategyType;
  final double monthlyBudget;
  final double extraMonthlyPayment;
  final DateTime startDate;
  final double lumpSum;
  final bool includeArchived;
  final Map<String, int> customPriorities;
}

class StrategyDebtSnapshot {
  const StrategyDebtSnapshot({
    required this.debtId,
    required this.title,
    required this.balanceBeforePayment,
    required this.interestAccrued,
    required this.paymentApplied,
    required this.balanceAfterPayment,
  });

  final String debtId;
  final String title;
  final double balanceBeforePayment;
  final double interestAccrued;
  final double paymentApplied;
  final double balanceAfterPayment;
}

class StrategyMonthResult {
  const StrategyMonthResult({
    required this.monthIndex,
    required this.date,
    required this.totalPaid,
    required this.totalInterest,
    required this.remainingBalance,
    required this.debts,
  });

  final int monthIndex;
  final DateTime date;
  final double totalPaid;
  final double totalInterest;
  final double remainingBalance;
  final List<StrategyDebtSnapshot> debts;
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
  });

  final StrategyType strategyType;
  final DateTime payoffDate;
  final double totalInterestPaid;
  final double totalInterestSaved;
  final int monthsToPayoff;
  final List<Debt> payoffOrder;
  final List<StrategyMonthResult> schedule;
  final double baselineInterest;
}
