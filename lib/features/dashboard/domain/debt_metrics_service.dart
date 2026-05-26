import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/dashboard_snapshot.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/payment.dart';
import '../../../shared/models/strategy_models.dart';
import '../../strategy/domain/portfolio_projection_service.dart';

class DebtMetricsService {
  const DebtMetricsService(this._projectionService);

  final PortfolioProjectionService _projectionService;

  DashboardSnapshot buildDashboard({
    required List<Debt> debts,
    required List<Payment> recentPayments,
    required StrategyType strategyType,
    double extraMonthlyPayment = 0,
    double oneTimeExtraPayment = 0,
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

    final result = _projectionService.projectPortfolio(
      debts: activeDebts,
      request: StrategyRequest(
        strategyType: strategyType,
        monthlyBudget: minimumTotal,
        extraMonthlyPayment: extraMonthlyPayment,
        startDate: DateTime.now(),
        lumpSum: oneTimeExtraPayment,
        includeArchived: false,
        customPriorities: {
          for (final debt in activeDebts) debt.id: debt.customPriority,
        },
        pausedDebtIds: {
          for (final debt in activeDebts)
            if (debt.planPaused) debt.id,
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
    final today = DateTime(now.year, now.month, now.day);
    final horizon = today.add(const Duration(days: 14));
    final withDueDates = debts.where((debt) {
      final dueDate = debt.dueDate;
      if (dueDate == null) {
        return false;
      }
      final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
      return !dueDay.isBefore(today) && !dueDay.isAfter(horizon);
    }).toList();
    withDueDates.sort((a, b) {
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return withDueDates;
  }
}
