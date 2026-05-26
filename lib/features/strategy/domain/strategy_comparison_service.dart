import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/strategy_models.dart';
import 'strategy_engine.dart';

class StrategyComparisonService {
  const StrategyComparisonService({
    StrategyEngine engine = const StrategyEngine(),
  }) : _engine = engine;

  final StrategyEngine _engine;

  StrategyComparison compare({
    required List<Debt> debts,
    required double monthlyBudget,
    required DateTime startDate,
  }) {
    final activeDebts = debts
        .where((debt) => debt.isActive && debt.currentBalance > 0)
        .toList();
    final minimumBudget = activeDebts.fold<double>(
      0,
      (sum, debt) => sum + debt.minimumPayment,
    );
    final effectiveBudget = monthlyBudget > 0 ? monthlyBudget : minimumBudget;
    final customPriorities = {
      for (final debt in activeDebts) debt.id: debt.customPriority,
    };
    final summaries = StrategyType.values
        .map(
          (strategy) => _buildSummary(
            strategy: strategy,
            debts: activeDebts,
            monthlyBudget: effectiveBudget,
            startDate: startDate,
            customPriorities: customPriorities,
          ),
        )
        .toList(growable: false);
    final recommendation = _recommend(activeDebts);

    return StrategyComparison(
      summaries: summaries,
      recommendedStrategy: recommendation.strategy,
      recommendationReason: recommendation.reason,
      minimumBudget: minimumBudget,
    );
  }

  StrategyComparisonSummary _buildSummary({
    required StrategyType strategy,
    required List<Debt> debts,
    required double monthlyBudget,
    required DateTime startDate,
    required Map<String, int> customPriorities,
  }) {
    final result = _engine.simulate(
      debts: debts,
      request: StrategyRequest(
        strategyType: strategy,
        monthlyBudget: monthlyBudget,
        extraMonthlyPayment: 0,
        startDate: startDate,
        lumpSum: 0,
        includeArchived: false,
        customPriorities: customPriorities,
        allowUnderMinimumBudget: false,
        pausedDebtIds: {
          for (final debt in debts)
            if (debt.planPaused) debt.id,
        },
      ),
    );
    final totalAmountPaid = result.schedule.fold<double>(
      0,
      (sum, month) => sum + month.totalPaid,
    );

    return StrategyComparisonSummary(
      strategyType: strategy,
      result: result,
      totalInterestPaid: result.totalInterestPaid,
      monthsToPayoff: result.monthsToPayoff,
      totalAmountPaid: totalAmountPaid,
    );
  }

  _Recommendation _recommend(List<Debt> debts) {
    if (debts.isEmpty) {
      return const _Recommendation(
        StrategyType.avalanche,
        'Add active debts to get a recommendation.',
      );
    }

    final totalBalance = debts.fold<double>(
      0,
      (sum, debt) => sum + debt.currentBalance,
    );
    final smallDebtCount = debts
        .where((debt) => debt.currentBalance <= totalBalance * 0.08)
        .length;
    if (smallDebtCount >= 3) {
      return const _Recommendation(
        StrategyType.snowball,
        'Snowball may fit you because several small debts can become quick wins.',
      );
    }

    final aprs = debts.map((debt) => debt.apr).toList()..sort();
    final highestApr = aprs.last;
    final peerApr = aprs.length == 1 ? highestApr : aprs[aprs.length - 2];
    if (highestApr >= 18 && highestApr - peerApr >= 8) {
      return const _Recommendation(
        StrategyType.avalanche,
        'Avalanche may fit you because one debt has one of your highest rates.',
      );
    }

    return const _Recommendation(
      StrategyType.avalanche,
      'Avalanche is the default suggestion because it usually lowers interest.',
    );
  }
}

class StrategyComparison {
  const StrategyComparison({
    required this.summaries,
    required this.recommendedStrategy,
    required this.recommendationReason,
    required this.minimumBudget,
  });

  final List<StrategyComparisonSummary> summaries;
  final StrategyType recommendedStrategy;
  final String recommendationReason;
  final double minimumBudget;

  StrategyComparisonSummary summaryFor(StrategyType strategyType) {
    return summaries.firstWhere(
      (summary) => summary.strategyType == strategyType,
    );
  }
}

class StrategyComparisonSummary {
  const StrategyComparisonSummary({
    required this.strategyType,
    required this.result,
    required this.totalInterestPaid,
    required this.monthsToPayoff,
    required this.totalAmountPaid,
  });

  final StrategyType strategyType;
  final StrategyResult result;
  final double totalInterestPaid;
  final int monthsToPayoff;
  final double totalAmountPaid;
}

class _Recommendation {
  const _Recommendation(this.strategy, this.reason);

  final StrategyType strategy;
  final String reason;
}
