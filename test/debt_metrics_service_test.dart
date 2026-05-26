import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/dashboard/domain/debt_metrics_service.dart';
import 'package:debt_destroyer/features/strategy/domain/portfolio_projection_service.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/debt_financial_terms.dart';
import 'package:debt_destroyer/shared/models/payment.dart';

void main() {
  test('dashboard metrics use shared portfolio projection outputs', () {
    const projectionService = PortfolioProjectionService();
    const metricsService = DebtMetricsService(projectionService);
    final debts = [
      Debt(
        id: 'visa',
        title: 'Visa',
        creditorName: 'Bank',
        type: DebtType.creditCard,
        currency: 'USD',
        originalBalance: 4000,
        currentBalance: 3000,
        apr: 19.9,
        minimumPayment: 120,
        dueDate: DateTime(2026, 3, 15),
        paymentFrequency: PaymentFrequency.monthly,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 3, 1),
        notes: '',
        tags: const [],
        status: DebtStatus.active,
        remindersEnabled: true,
        customPriority: 1,
        financialTerms: DebtFinancialTerms(monthlyFee: 8),
      ),
    ];
    final payments = [
      Payment(
        id: 'p1',
        debtId: 'visa',
        amount: 200,
        date: DateTime(2026, 3, 1),
        method: 'ACH',
        sourceType: PaymentSourceType.manual,
        notes: '',
        tags: const [],
        createdAt: DateTime(2026, 3, 1),
      ),
    ];

    final snapshot = metricsService.buildDashboard(
      debts: debts,
      recentPayments: payments,
      strategyType: StrategyType.avalanche,
    );

    expect(snapshot.projectedDebtFreeDate, isNotNull);
    expect(snapshot.interestExpected, greaterThan(0));
    expect(snapshot.monthlyMinimumTotal, 120);
  });

  test('dashboard only surfaces active debts due in the next 14 days', () {
    const metricsService = DebtMetricsService(PortfolioProjectionService());
    final now = DateTime.now();
    final dueSoon = _debt(
      id: 'soon',
      dueDate: now.add(const Duration(days: 7)),
    );
    final dueLater = _debt(
      id: 'later',
      dueDate: now.add(const Duration(days: 21)),
    );
    final paidOff = _debt(
      id: 'paid',
      dueDate: now.add(const Duration(days: 4)),
      status: DebtStatus.paidOff,
    );

    final snapshot = metricsService.buildDashboard(
      debts: [dueLater, paidOff, dueSoon],
      recentPayments: const [],
      strategyType: StrategyType.avalanche,
    );

    expect(snapshot.upcomingDueDebts.map((debt) => debt.id), ['soon']);
  });

  test('dashboard projection includes the applied extra monthly payment', () {
    const metricsService = DebtMetricsService(PortfolioProjectionService());
    final debt = _debt(id: 'card', dueDate: DateTime.now());

    final original = metricsService.buildDashboard(
      debts: [debt],
      recentPayments: const [],
      strategyType: StrategyType.avalanche,
    );
    final withExtra = metricsService.buildDashboard(
      debts: [debt],
      recentPayments: const [],
      strategyType: StrategyType.avalanche,
      extraMonthlyPayment: 100,
    );

    expect(withExtra.projectedDebtFreeDate, isNotNull);
    expect(
      withExtra.projectedDebtFreeDate!.isBefore(
        original.projectedDebtFreeDate!,
      ),
      isTrue,
    );
    expect(withExtra.interestSavedVsBaseline, greaterThan(0));
  });
}

Debt _debt({
  required String id,
  required DateTime dueDate,
  DebtStatus status = DebtStatus.active,
}) {
  return Debt(
    id: id,
    title: id,
    creditorName: 'Bank',
    type: DebtType.creditCard,
    currency: 'USD',
    originalBalance: 1000,
    currentBalance: 800,
    apr: 18,
    minimumPayment: 40,
    dueDate: dueDate,
    paymentFrequency: PaymentFrequency.monthly,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 3, 1),
    notes: '',
    tags: const [],
    status: status,
    remindersEnabled: true,
    customPriority: 1,
  );
}
