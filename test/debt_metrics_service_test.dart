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
}
