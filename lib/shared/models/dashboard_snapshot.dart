import 'debt.dart';
import 'payment.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.totalOutstandingDebt,
    required this.totalPaidSoFar,
    required this.monthlyMinimumTotal,
    required this.projectedDebtFreeDate,
    required this.interestExpected,
    required this.interestSavedVsBaseline,
    required this.upcomingDueDebts,
    required this.recentPayments,
    required this.mixedCurrency,
  });

  final double totalOutstandingDebt;
  final double totalPaidSoFar;
  final double monthlyMinimumTotal;
  final DateTime? projectedDebtFreeDate;
  final double interestExpected;
  final double interestSavedVsBaseline;
  final List<Debt> upcomingDueDebts;
  final List<Payment> recentPayments;
  final bool mixedCurrency;
}
