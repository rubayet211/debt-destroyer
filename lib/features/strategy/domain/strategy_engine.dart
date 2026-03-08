import 'dart:math';

import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/strategy_models.dart';

class StrategyEngine {
  const StrategyEngine();

  StrategyResult simulate({
    required List<Debt> debts,
    required StrategyRequest request,
  }) {
    final workingDebts = debts
        .where(
          (debt) =>
              request.includeArchived || debt.status != DebtStatus.archived,
        )
        .where((debt) => debt.currentBalance > 0)
        .map((debt) => _MutableDebt(debt: debt, balance: debt.currentBalance))
        .toList();

    if (workingDebts.isEmpty) {
      return StrategyResult(
        strategyType: request.strategyType,
        payoffDate: request.startDate,
        totalInterestPaid: 0,
        totalInterestSaved: 0,
        monthsToPayoff: 0,
        payoffOrder: const [],
        schedule: const [],
        baselineInterest: 0,
      );
    }

    final optimized = _runSimulation(workingDebts, request);
    final baseline = _runSimulation(
      workingDebts,
      StrategyRequest(
        strategyType: StrategyType.avalanche,
        monthlyBudget: request.monthlyBudget,
        extraMonthlyPayment: 0,
        startDate: request.startDate,
        lumpSum: 0,
        includeArchived: request.includeArchived,
        customPriorities: request.customPriorities,
      ),
    );

    return StrategyResult(
      strategyType: request.strategyType,
      payoffDate: optimized.$1,
      totalInterestPaid: optimized.$2,
      totalInterestSaved: max(0, baseline.$2 - optimized.$2),
      monthsToPayoff: optimized.$3.length,
      payoffOrder: optimized.$4,
      schedule: optimized.$3,
      baselineInterest: baseline.$2,
    );
  }

  (DateTime, double, List<StrategyMonthResult>, List<Debt>) _runSimulation(
    List<_MutableDebt> seed,
    StrategyRequest request,
  ) {
    final debts = seed.map((item) => item.copy()).toList();
    final schedule = <StrategyMonthResult>[];
    final payoffOrder = <Debt>[];
    var totalInterest = 0.0;
    var monthIndex = 0;
    var cursor = DateTime(request.startDate.year, request.startDate.month, 1);

    while (debts.any((debt) => debt.balance > 0.01) && monthIndex < 600) {
      monthIndex++;
      final active = debts.where((debt) => debt.balance > 0.01).toList();
      final monthInterest = <String, double>{};

      for (final debt in active) {
        final accrued = debt.balance * (debt.debt.apr / 100 / 12);
        debt.balance += accrued;
        monthInterest[debt.debt.id] = accrued;
        totalInterest += accrued;
      }

      final minimumTotal = active.fold<double>(
        0,
        (sum, debt) => sum + min(debt.debt.minimumPayment, debt.balance),
      );
      var available =
          max(request.monthlyBudget, minimumTotal) +
          request.extraMonthlyPayment;
      if (monthIndex == 1 && request.lumpSum > 0) {
        available += request.lumpSum;
      }

      final snapshots = <StrategyDebtSnapshot>[];
      for (final debt in active) {
        final minimum = min(debt.debt.minimumPayment, debt.balance);
        final applied = min(available, minimum);
        available -= applied;
        final before = debt.balance;
        debt.balance = max(0, debt.balance - applied);
        snapshots.add(
          StrategyDebtSnapshot(
            debtId: debt.debt.id,
            title: debt.debt.title,
            balanceBeforePayment: before,
            interestAccrued: monthInterest[debt.debt.id] ?? 0,
            paymentApplied: applied,
            balanceAfterPayment: debt.balance,
          ),
        );
      }

      for (final debt in _prioritize(active, request)) {
        if (available <= 0 || debt.balance <= 0) {
          continue;
        }
        final extra = min(available, debt.balance);
        final index = snapshots.indexWhere(
          (item) => item.debtId == debt.debt.id,
        );
        final existing = snapshots[index];
        debt.balance = max(0, debt.balance - extra);
        snapshots[index] = StrategyDebtSnapshot(
          debtId: existing.debtId,
          title: existing.title,
          balanceBeforePayment: existing.balanceBeforePayment,
          interestAccrued: existing.interestAccrued,
          paymentApplied: existing.paymentApplied + extra,
          balanceAfterPayment: debt.balance,
        );
        available -= extra;
      }

      for (final debt in active) {
        if (debt.balance <= 0.01 &&
            payoffOrder.every((item) => item.id != debt.debt.id)) {
          payoffOrder.add(debt.debt);
        }
      }

      schedule.add(
        StrategyMonthResult(
          monthIndex: monthIndex,
          date: cursor,
          totalPaid: snapshots.fold<double>(
            0,
            (sum, item) => sum + item.paymentApplied,
          ),
          totalInterest: snapshots.fold<double>(
            0,
            (sum, item) => sum + item.interestAccrued,
          ),
          remainingBalance: debts.fold<double>(
            0,
            (sum, item) => sum + item.balance,
          ),
          debts: snapshots,
        ),
      );
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    return (cursor, totalInterest, schedule, payoffOrder);
  }

  List<_MutableDebt> _prioritize(
    List<_MutableDebt> debts,
    StrategyRequest request,
  ) {
    final prioritized = [...debts];
    switch (request.strategyType) {
      case StrategyType.snowball:
        prioritized.sort((a, b) => a.balance.compareTo(b.balance));
      case StrategyType.avalanche:
        prioritized.sort((a, b) {
          final aprCompare = b.debt.apr.compareTo(a.debt.apr);
          return aprCompare != 0 ? aprCompare : a.balance.compareTo(b.balance);
        });
      case StrategyType.customPriority:
        prioritized.sort((a, b) {
          final aPriority =
              request.customPriorities[a.debt.id] ?? a.debt.customPriority;
          final bPriority =
              request.customPriorities[b.debt.id] ?? b.debt.customPriority;
          return aPriority.compareTo(bPriority);
        });
    }
    return prioritized;
  }
}

class _MutableDebt {
  _MutableDebt({required this.debt, required this.balance});

  final Debt debt;
  double balance;

  _MutableDebt copy() => _MutableDebt(debt: debt, balance: balance);
}
