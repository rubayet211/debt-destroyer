import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/strategy/domain/strategy_comparison_service.dart';
import 'package:debt_destroyer/features/strategy/domain/strategy_engine.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';

import 'test_helpers.dart';

void main() {
  group('StrategyComparisonService', () {
    const service = StrategyComparisonService(engine: StrategyEngine());

    test('builds summaries for snowball avalanche and custom strategies', () {
      final debts = [
        buildTestDebt(
          id: 'small',
          title: 'Store card',
          currentBalance: 450,
          apr: 8,
          minimumPayment: 40,
          customPriority: 2,
        ),
        buildTestDebt(
          id: 'expensive',
          title: 'Rewards card',
          currentBalance: 2200,
          apr: 27.5,
          minimumPayment: 85,
          customPriority: 1,
        ),
      ];

      final comparison = service.compare(
        debts: debts,
        monthlyBudget: 240,
        startDate: DateTime(2026, 1, 1),
      );

      expect(
        comparison.summaries.map((summary) => summary.strategyType),
        containsAll(StrategyType.values),
      );
      expect(comparison.summaries, hasLength(3));
      expect(comparison.minimumBudget, 125);
      expect(
        comparison.summaryFor(StrategyType.avalanche).totalAmountPaid,
        greaterThan(2650),
      );
      expect(
        comparison.summaryFor(StrategyType.avalanche).totalAmountPaid,
        closeTo(
          comparison.summaryFor(StrategyType.avalanche).totalInterestPaid +
              2650,
          0.01,
        ),
      );
    });

    test(
      'recommends snowball when several small debts can create quick wins',
      () {
        final comparison = service.compare(
          debts: [
            buildTestDebt(id: 'one', currentBalance: 120, minimumPayment: 25),
            buildTestDebt(id: 'two', currentBalance: 180, minimumPayment: 25),
            buildTestDebt(id: 'three', currentBalance: 260, minimumPayment: 30),
            buildTestDebt(
              id: 'large',
              currentBalance: 4800,
              apr: 11,
              minimumPayment: 120,
            ),
          ],
          monthlyBudget: 260,
          startDate: DateTime(2026, 1, 1),
        );

        expect(comparison.recommendedStrategy, StrategyType.snowball);
        expect(comparison.recommendationReason, contains('quick wins'));
      },
    );

    test('recommends avalanche when high interest stands out', () {
      final comparison = service.compare(
        debts: [
          buildTestDebt(
            id: 'card',
            currentBalance: 3600,
            apr: 29.99,
            minimumPayment: 130,
          ),
          buildTestDebt(
            id: 'loan',
            currentBalance: 4200,
            apr: 7.5,
            minimumPayment: 120,
          ),
        ],
        monthlyBudget: 320,
        startDate: DateTime(2026, 1, 1),
      );

      expect(comparison.recommendedStrategy, StrategyType.avalanche);
      expect(comparison.recommendationReason, contains('highest rates'));
    });
  });
}
