import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/strategy/domain/strategy_engine.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/debt_financial_terms.dart';
import 'package:debt_destroyer/shared/models/strategy_models.dart';

void main() {
  group('StrategyEngine', () {
    const engine = StrategyEngine();

    StrategyRequest request(
      StrategyType type, {
      double budget = 300,
      double extra = 0,
      double lumpSum = 0,
      DateTime? startDate,
      bool allowUnderMinimumBudget = true,
      Map<String, int> priorities = const {},
    }) {
      return StrategyRequest(
        strategyType: type,
        monthlyBudget: budget,
        extraMonthlyPayment: extra,
        startDate: startDate ?? DateTime(2026, 1, 1),
        lumpSum: lumpSum,
        includeArchived: false,
        customPriorities: priorities,
        allowUnderMinimumBudget: allowUnderMinimumBudget,
      );
    }

    test('snowball prioritizes smaller balances first', () {
      final debts = [
        _debt(
          id: 'small',
          currentBalance: 500,
          apr: 8,
          minimumPayment: 50,
          customPriority: 2,
        ),
        _debt(
          id: 'large',
          currentBalance: 2000,
          apr: 24,
          minimumPayment: 100,
          type: DebtType.personalLoan,
          customPriority: 1,
        ),
      ];

      final result = engine.simulate(
        debts: debts,
        request: request(StrategyType.snowball),
      );

      expect(result.payoffOrder.first.id, 'small');
      expect(
        result.schedule.first.debts
            .firstWhere((it) => it.debtId == 'small')
            .extraPaymentApplied,
        greaterThan(0),
      );
    });

    test('avalanche prioritizes higher apr first', () {
      final debts = [
        _debt(id: 'small', currentBalance: 500, apr: 8, minimumPayment: 50),
        _debt(
          id: 'large',
          currentBalance: 2000,
          apr: 24,
          minimumPayment: 100,
          type: DebtType.personalLoan,
        ),
      ];

      final result = engine.simulate(
        debts: debts,
        request: request(StrategyType.avalanche),
      );

      final largestPayment = result.schedule.first.debts.reduce(
        (current, next) =>
            current.paymentApplied >= next.paymentApplied ? current : next,
      );
      expect(largestPayment.debtId, 'large');
    });

    test(
      'promo apr window reduces early interest then falls back to standard apr',
      () {
        final debt = _debt(
          id: 'promo',
          currentBalance: 2400,
          apr: 21.9,
          minimumPayment: 120,
          financialTerms: DebtFinancialTerms(
            promoApr: 0,
            promoEndsOn: DateTime(2026, 3, 15),
          ),
        );

        final result = engine.simulate(
          debts: [debt],
          request: request(StrategyType.avalanche, budget: 180),
        );

        expect(result.warnings, contains(ProjectionWarning.promoRateApplied));
        expect(result.schedule.first.totalInterest, 0);
        expect(result.schedule[3].totalInterest, greaterThan(0));
      },
    );

    test('interest plus percent minimum payment rule raises minimum due', () {
      final debt = _debt(
        id: 'rule',
        currentBalance: 4000,
        apr: 19.9,
        minimumPayment: 35,
        financialTerms: const DebtFinancialTerms(
          minimumPaymentRule: MinimumPaymentRule.interestPlusPercent,
          minimumPaymentPercent: 2,
        ),
      );

      final result = engine.simulate(
        debts: [debt],
        request: request(StrategyType.avalanche, budget: 150),
      );

      expect(result.minimumRequiredPerCycle, greaterThan(100));
      expect(
        result.schedule.first.debts.single.minimumDue,
        result.minimumRequiredPerCycle,
      );
    });

    test('late fee and penalty apr apply when budget is below minimums', () {
      final debt = _debt(
        id: 'late',
        currentBalance: 1200,
        apr: 18,
        minimumPayment: 150,
        dueDate: DateTime(2026, 1, 5),
        financialTerms: const DebtFinancialTerms(
          lateFee: 25,
          penaltyApr: 29.99,
        ),
      );

      final result = engine.simulate(
        debts: [debt],
        request: request(
          StrategyType.avalanche,
          budget: 50,
          allowUnderMinimumBudget: true,
        ),
      );

      expect(result.warnings, contains(ProjectionWarning.underMinimumBudget));
      expect(result.warnings, contains(ProjectionWarning.lateFeesApplied));
      expect(result.warnings, contains(ProjectionWarning.penaltyAprApplied));
      expect(result.schedule.first.debts.single.shortfall, greaterThan(0));
      expect(result.schedule[1].debts.single.activeApr, greaterThan(18));
    });

    test('monthly recurring fee is included in schedule and warnings', () {
      final debt = _debt(
        id: 'fee',
        currentBalance: 900,
        apr: 0,
        minimumPayment: 90,
        financialTerms: const DebtFinancialTerms(monthlyFee: 12),
      );

      final result = engine.simulate(
        debts: [debt],
        request: request(StrategyType.avalanche, budget: 120),
      );

      expect(result.warnings, contains(ProjectionWarning.recurringFeesApplied));
      expect(result.schedule.first.totalFees, greaterThan(0));
    });

    test('lump sum and extra payment reduce payoff time and interest', () {
      final debts = [
        _debt(id: 'a', currentBalance: 3500, apr: 22.5, minimumPayment: 110),
        _debt(
          id: 'b',
          currentBalance: 1800,
          apr: 11.2,
          minimumPayment: 65,
          type: DebtType.personalLoan,
        ),
      ];

      final baseline = engine.simulate(
        debts: debts,
        request: request(StrategyType.avalanche, budget: 250),
      );
      final accelerated = engine.simulate(
        debts: debts,
        request: request(
          StrategyType.avalanche,
          budget: 250,
          extra: 150,
          lumpSum: 500,
        ),
      );

      expect(accelerated.monthsToPayoff, lessThan(baseline.monthsToPayoff));
      expect(
        accelerated.totalInterestPaid,
        lessThan(baseline.totalInterestPaid),
      );
    });

    test('near-zero balance and minimum above balance pay off cleanly', () {
      final debt = _debt(
        id: 'tiny',
        currentBalance: 12.34,
        apr: 0,
        minimumPayment: 50,
      );

      final result = engine.simulate(
        debts: [debt],
        request: request(StrategyType.avalanche, budget: 50),
      );

      expect(result.monthsToPayoff, 1);
      expect(result.schedule.single.debts.single.endingBalance, 0);
    });

    test(
      'weekly and quarterly frequencies are normalized into monthly buckets',
      () {
        final debts = [
          _debt(
            id: 'weekly',
            currentBalance: 1000,
            apr: 10,
            minimumPayment: 40,
            paymentFrequency: PaymentFrequency.weekly,
          ),
          _debt(
            id: 'quarterly',
            currentBalance: 600,
            apr: 6,
            minimumPayment: 75,
            paymentFrequency: PaymentFrequency.quarterly,
            type: DebtType.personalLoan,
          ),
        ];

        final result = engine.simulate(
          debts: debts,
          request: request(
            StrategyType.customPriority,
            priorities: const {'weekly': 1, 'quarterly': 2},
          ),
        );

        expect(
          result.warnings,
          contains(ProjectionWarning.mixedPaymentFrequencies),
        );
        expect(result.schedule.first.minimumRequired, greaterThan(75));
      },
    );

    test('archived and paid off debts are excluded by default', () {
      final result = engine.simulate(
        debts: [
          _debt(id: 'active', currentBalance: 500, apr: 10, minimumPayment: 50),
          _debt(
            id: 'archived',
            currentBalance: 700,
            apr: 10,
            minimumPayment: 50,
            status: DebtStatus.archived,
          ),
          _debt(
            id: 'paid',
            currentBalance: 0,
            apr: 10,
            minimumPayment: 50,
            status: DebtStatus.paidOff,
          ),
        ],
        request: request(StrategyType.avalanche, budget: 100),
      );

      expect(result.schedule.first.debts, hasLength(1));
      expect(result.schedule.first.debts.single.debtId, 'active');
    });
  });
}

Debt _debt({
  required String id,
  required double currentBalance,
  required double apr,
  required double minimumPayment,
  DebtType type = DebtType.creditCard,
  PaymentFrequency paymentFrequency = PaymentFrequency.monthly,
  DebtStatus status = DebtStatus.active,
  int customPriority = 1,
  DateTime? dueDate,
  DebtFinancialTerms financialTerms = const DebtFinancialTerms(),
}) {
  return Debt(
    id: id,
    title: id,
    creditorName: '$id bank',
    type: type,
    currency: 'USD',
    originalBalance: currentBalance,
    currentBalance: currentBalance,
    apr: apr,
    minimumPayment: minimumPayment,
    dueDate: dueDate,
    paymentFrequency: paymentFrequency,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    notes: '',
    tags: const [],
    status: status,
    remindersEnabled: false,
    customPriority: customPriority,
    financialTerms: financialTerms,
  );
}
