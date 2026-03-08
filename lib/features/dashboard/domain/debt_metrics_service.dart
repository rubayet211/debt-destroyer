import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/dashboard_snapshot.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/payment.dart';
import '../../../shared/models/strategy_models.dart';
import '../../strategy/domain/strategy_engine.dart';

class DebtMetricsService {
  const DebtMetricsService(this._strategyEngine);

  final StrategyEngine _strategyEngine;

  DashboardSnapshot buildDashboard({
    required List<Debt> debts,
    required List<Payment> recentPayments,
    required StrategyType strategyType,
  }) {
    final activeDebts = debts.where((debt) => debt.isActive).toList();
    final totalOutstanding = activeDebts.fold<double>(
      0,
      (sum, debt) => sum + debt.currentBalance,
    );
    final totalPaid = debts.fold<double>(
      0,
      (sum, debt) => sum + (debt.originalBalance - debt.currentBalance),
    );
    final minimumTotal = activeDebts.fold<double>(
      0,
      (sum, debt) => sum + debt.minimumPayment,
    );
    final currencies = activeDebts.map((debt) => debt.currency).toSet();

    final result = _strategyEngine.simulate(
      debts: activeDebts,
      request: StrategyRequest(
        strategyType: strategyType,
        monthlyBudget: minimumTotal,
        extraMonthlyPayment: 0,
        startDate: DateTime.now(),
        lumpSum: 0,
        includeArchived: false,
        customPriorities: {
          for (final debt in activeDebts) debt.id: debt.customPriority,
        },
      ),
    );

    return DashboardSnapshot(
      totalOutstandingDebt: totalOutstanding,
      totalPaidSoFar: totalPaid,
      monthlyMinimumTotal: minimumTotal,
      projectedDebtFreeDate: result.payoffDate,
      interestExpected: result.totalInterestPaid,
      interestSavedVsBaseline: result.totalInterestSaved,
      upcomingDueDebts: _upcomingDue(activeDebts).take(3).toList(),
      recentPayments: recentPayments.take(5).toList(),
      mixedCurrency: currencies.length > 1,
    );
  }

  List<Debt> _upcomingDue(List<Debt> debts) {
    final now = DateTime.now();
    final withDueDates = debts.where((debt) => debt.dueDate != null).toList();
    withDueDates.sort((a, b) {
      final aDiff = a.dueDate!.difference(now).inDays.abs();
      final bDiff = b.dueDate!.difference(now).inDays.abs();
      return aDiff.compareTo(bDiff);
    });
    return withDueDates;
  }
}
