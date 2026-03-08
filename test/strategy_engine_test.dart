import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/strategy/domain/strategy_engine.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/strategy_models.dart';

void main() {
  group('StrategyEngine', () {
    const engine = StrategyEngine();

    final debts = [
      Debt(
        id: 'small-low-apr',
        title: 'Small debt',
        creditorName: 'A',
        type: DebtType.creditCard,
        currency: 'USD',
        originalBalance: 500,
        currentBalance: 500,
        apr: 8,
        minimumPayment: 50,
        dueDate: null,
        paymentFrequency: PaymentFrequency.monthly,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        notes: '',
        tags: const [],
        status: DebtStatus.active,
        remindersEnabled: false,
        customPriority: 2,
      ),
      Debt(
        id: 'large-high-apr',
        title: 'Large debt',
        creditorName: 'B',
        type: DebtType.personalLoan,
        currency: 'USD',
        originalBalance: 2000,
        currentBalance: 2000,
        apr: 24,
        minimumPayment: 100,
        dueDate: null,
        paymentFrequency: PaymentFrequency.monthly,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        notes: '',
        tags: const [],
        status: DebtStatus.active,
        remindersEnabled: false,
        customPriority: 1,
      ),
    ];

    StrategyRequest request(StrategyType type, {double extra = 0}) {
      return StrategyRequest(
        strategyType: type,
        monthlyBudget: 300,
        extraMonthlyPayment: extra,
        startDate: DateTime(2026, 1, 1),
        lumpSum: 0,
        includeArchived: false,
        customPriorities: const {'large-high-apr': 1, 'small-low-apr': 2},
      );
    }

    test('snowball prioritizes smaller balances first', () {
      final result = engine.simulate(
        debts: debts,
        request: request(StrategyType.snowball),
      );
      final firstMonth = result.schedule.first;
      final largestPayment = firstMonth.debts.reduce(
        (current, next) =>
            current.paymentApplied >= next.paymentApplied ? current : next,
      );
      expect(largestPayment.debtId, 'small-low-apr');
    });

    test('avalanche prioritizes higher APR first', () {
      final result = engine.simulate(
        debts: debts,
        request: request(StrategyType.avalanche),
      );
      final firstMonth = result.schedule.first;
      final largestPayment = firstMonth.debts.reduce(
        (current, next) =>
            current.paymentApplied >= next.paymentApplied ? current : next,
      );
      expect(largestPayment.debtId, 'large-high-apr');
    });

    test('extra payment reduces payoff time and interest', () {
      final baseline = engine.simulate(
        debts: debts,
        request: request(StrategyType.avalanche),
      );
      final accelerated = engine.simulate(
        debts: debts,
        request: request(StrategyType.avalanche, extra: 150),
      );

      expect(accelerated.monthsToPayoff, lessThan(baseline.monthsToPayoff));
      expect(
        accelerated.totalInterestPaid,
        lessThan(baseline.totalInterestPaid),
      );
    });
  });
}
