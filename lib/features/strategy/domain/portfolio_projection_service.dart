import 'dart:math';

import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/debt_financial_terms.dart';
import '../../../shared/models/strategy_models.dart';
import 'money_math.dart';

class PortfolioProjectionService {
  const PortfolioProjectionService({
    DebtProjectionEngine projectionEngine = const DebtProjectionEngine(),
  }) : _projectionEngine = projectionEngine;

  final DebtProjectionEngine _projectionEngine;

  StrategyResult projectPortfolio({
    required List<Debt> debts,
    required StrategyRequest request,
  }) {
    final filtered = debts
        .where(
          (debt) =>
              request.includeArchived || debt.status != DebtStatus.archived,
        )
        .where((debt) => debt.status != DebtStatus.paidOff)
        .where((debt) => debt.currentBalance > 0)
        .toList();

    if (filtered.isEmpty) {
      final baselineStrategy =
          request.comparisonStrategy ?? StrategyType.avalanche;
      return StrategyResult(
        strategyType: request.strategyType,
        payoffDate: request.startDate,
        totalInterestPaid: 0,
        totalInterestSaved: 0,
        monthsToPayoff: 0,
        payoffOrder: const [],
        schedule: const [],
        baselineInterest: 0,
        baselineResult: StrategySummary(
          strategyType: baselineStrategy,
          payoffDate: request.startDate,
          totalInterestPaid: 0,
          monthsToPayoff: 0,
        ),
      );
    }

    final optimized = _projectionEngine._simulatePortfolio(
      debts: filtered,
      request: request,
    );
    final baseline = _projectionEngine._simulatePortfolio(
      debts: filtered,
      request: StrategyRequest(
        strategyType: request.comparisonStrategy ?? StrategyType.avalanche,
        monthlyBudget: request.monthlyBudget,
        extraMonthlyPayment: 0,
        startDate: request.startDate,
        lumpSum: 0,
        includeArchived: request.includeArchived,
        customPriorities: request.customPriorities,
        projectionAsOf: request.projectionAsOf,
        allowUnderMinimumBudget: request.allowUnderMinimumBudget,
      ),
    );

    return StrategyResult(
      strategyType: request.strategyType,
      payoffDate: optimized.payoffDate,
      totalInterestPaid: optimized.totalInterestPaid,
      totalInterestSaved: max(
        0,
        baseline.totalInterestPaid - optimized.totalInterestPaid,
      ),
      monthsToPayoff: optimized.monthsToPayoff,
      payoffOrder: optimized.payoffOrder,
      schedule: optimized.schedule,
      baselineInterest: baseline.totalInterestPaid,
      minimumRequiredPerCycle: optimized.minimumRequiredPerCycle,
      budgetShortfall: optimized.budgetShortfall,
      warnings: optimized.warnings.toList(growable: false),
      baselineResult: StrategySummary(
        strategyType: baseline.strategyType,
        payoffDate: baseline.payoffDate,
        totalInterestPaid: baseline.totalInterestPaid,
        monthsToPayoff: baseline.monthsToPayoff,
      ),
    );
  }
}

class DebtProjectionEngine {
  const DebtProjectionEngine();

  _ProjectionComputation _simulatePortfolio({
    required List<Debt> debts,
    required StrategyRequest request,
  }) {
    final states = debts
        .map(
          (debt) => _DebtState(
            debt: debt,
            balanceCents: MoneyMath.toCents(debt.currentBalance),
          ),
        )
        .toList();
    final schedule = <StrategyMonthResult>[];
    final payoffOrder = <Debt>[];
    final warnings = <ProjectionWarning>{};
    final mixedFrequencies = debts.map((debt) => debt.paymentFrequency).toSet();
    if (mixedFrequencies.length > 1) {
      warnings.add(ProjectionWarning.mixedPaymentFrequencies);
    }

    var cursor = DateTime(
      (request.projectionAsOf ?? request.startDate).year,
      (request.projectionAsOf ?? request.startDate).month,
      1,
    );
    var totalInterestCents = 0;
    var firstMinimumRequiredCents = 0;
    var firstShortfallCents = 0;
    var monthIndex = 0;

    while (states.any((state) => state.balanceCents > 0) && monthIndex < 600) {
      monthIndex++;
      final periodStart = cursor;
      final periodEnd = DateTime(cursor.year, cursor.month + 1, 1);
      final active = states.where((state) => state.balanceCents > 0).toList();
      final monthlyEntries = <_MonthlyDebtEntry>[];

      for (final state in active) {
        final entry = _buildMonthlyEntry(
          state: state,
          request: request,
          periodStart: periodStart,
          periodEnd: periodEnd,
        );
        monthlyEntries.add(entry);
        totalInterestCents += entry.interestCents;
        warnings.addAll(entry.warnings);
      }

      final minimumOrder = [...monthlyEntries]..sort(_minimumPriorityCompare);
      var availableCents =
          max(0, MoneyMath.toCents(request.monthlyBudget)) +
          max(0, MoneyMath.toCents(request.extraMonthlyPayment));
      if (monthIndex == 1) {
        availableCents += max(0, MoneyMath.toCents(request.lumpSum));
      }

      final minimumRequiredCents = monthlyEntries.fold<int>(
        0,
        (sum, entry) => sum + entry.minimumDueCents,
      );
      if (monthIndex == 1) {
        firstMinimumRequiredCents = minimumRequiredCents;
      }
      if (!request.allowUnderMinimumBudget &&
          availableCents < minimumRequiredCents) {
        availableCents = minimumRequiredCents;
      }
      if (availableCents < minimumRequiredCents) {
        warnings.add(ProjectionWarning.underMinimumBudget);
      }

      for (final entry in minimumOrder) {
        final applied = min(availableCents, entry.minimumDueCents).toInt();
        entry.minimumPaymentAppliedCents = applied;
        availableCents -= applied;
      }

      final extraOrder = _prioritize(entries: monthlyEntries, request: request);
      for (final entry in extraOrder) {
        if (availableCents <= 0 || entry.balanceAfterMinimumCents <= 0) {
          continue;
        }
        final applied = min(
          availableCents,
          entry.balanceAfterMinimumCents,
        ).toInt();
        entry.extraPaymentAppliedCents = applied;
        availableCents -= applied;
      }

      final snapshots = <StrategyDebtSnapshot>[];
      var totalPaidCents = 0;
      var totalFeesCents = 0;
      var monthShortfallCents = 0;

      for (final entry in monthlyEntries) {
        final endingBeforeLateFee =
            entry.balanceAfterChargesCents -
            entry.minimumPaymentAppliedCents -
            entry.extraPaymentAppliedCents;
        final shortfall = max(
          0,
          entry.minimumDueCents - entry.minimumPaymentAppliedCents,
        ).toInt();
        var lateFeeCents = 0;
        if (shortfall > 0 && _shouldApplyLateFee(entry, periodStart)) {
          lateFeeCents = entry.lateFeeCents;
          warnings.add(ProjectionWarning.lateFeesApplied);
        }
        final endingCents = max(0, endingBeforeLateFee + lateFeeCents).toInt();
        entry.state.balanceCents = endingCents;
        entry.state.overdue = OverduePolicyEvaluator.shouldCarryOverdue(
          shortfallCents: shortfall,
        );
        if (entry.state.overdue) {
          warnings.add(ProjectionWarning.overdueDebt);
        }
        if (entry.appliedPenaltyApr) {
          warnings.add(ProjectionWarning.penaltyAprApplied);
        }

        totalPaidCents +=
            entry.minimumPaymentAppliedCents + entry.extraPaymentAppliedCents;
        totalFeesCents += entry.monthlyFeeCents + lateFeeCents;
        monthShortfallCents += shortfall;

        if (endingCents <= 0 &&
            payoffOrder.every((debt) => debt.id != entry.state.debt.id)) {
          payoffOrder.add(entry.state.debt);
        }

        snapshots.add(
          StrategyDebtSnapshot(
            debtId: entry.state.debt.id,
            title: entry.state.debt.title,
            openingBalance: MoneyMath.fromCents(entry.openingBalanceCents),
            interestAccrued: MoneyMath.fromCents(entry.interestCents),
            feesAccrued: MoneyMath.fromCents(
              entry.monthlyFeeCents + lateFeeCents,
            ),
            minimumDue: MoneyMath.fromCents(entry.minimumDueCents),
            minimumPaymentApplied: MoneyMath.fromCents(
              entry.minimumPaymentAppliedCents,
            ),
            extraPaymentApplied: MoneyMath.fromCents(
              entry.extraPaymentAppliedCents,
            ),
            endingBalance: MoneyMath.fromCents(endingCents),
            activeApr: entry.activeApr,
            overdue: entry.state.overdue,
            shortfall: MoneyMath.fromCents(shortfall),
          ),
        );
      }

      if (monthIndex == 1) {
        firstShortfallCents = monthShortfallCents;
      }

      schedule.add(
        StrategyMonthResult(
          monthIndex: monthIndex,
          date: periodStart,
          totalPaid: MoneyMath.fromCents(totalPaidCents),
          totalInterest: MoneyMath.fromCents(
            monthlyEntries.fold<int>(
              0,
              (sum, entry) => sum + entry.interestCents,
            ),
          ),
          totalFees: MoneyMath.fromCents(totalFeesCents),
          remainingBalance: MoneyMath.fromCents(
            states.fold<int>(0, (sum, state) => sum + state.balanceCents),
          ),
          minimumRequired: MoneyMath.fromCents(minimumRequiredCents),
          budgetShortfall: MoneyMath.fromCents(monthShortfallCents),
          debts: snapshots,
        ),
      );

      cursor = periodEnd;
    }

    return _ProjectionComputation(
      strategyType: request.strategyType,
      payoffDate: cursor,
      totalInterestPaid: MoneyMath.fromCents(totalInterestCents),
      monthsToPayoff: schedule.length,
      payoffOrder: payoffOrder,
      schedule: schedule,
      minimumRequiredPerCycle: MoneyMath.fromCents(firstMinimumRequiredCents),
      budgetShortfall: MoneyMath.fromCents(firstShortfallCents),
      warnings: warnings,
    );
  }

  _MonthlyDebtEntry _buildMonthlyEntry({
    required _DebtState state,
    required StrategyRequest request,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final terms = state.debt.financialTerms;
    final openingBalanceCents = state.balanceCents;
    final activeApr = _activeAprForPeriod(
      state: state,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
    final interestCents = AccrualCalculator.calculateInterestCents(
      openingBalanceCents: openingBalanceCents,
      periodStart: periodStart,
      periodEnd: periodEnd,
      compounding: terms.interestCompounding,
      standardApr: state.debt.apr,
      promoApr: terms.promoApr,
      promoEndsOn: terms.promoEndsOn,
      effectiveAprOverride: state.overdue ? activeApr : null,
    );
    final monthlyFeeCents = MoneyMath.toCents(max(0, terms.monthlyFee));
    final balanceAfterChargesCents =
        openingBalanceCents + interestCents + monthlyFeeCents;
    final scheduledOccurrences = _scheduledOccurrences(
      debt: state.debt,
      periodStart: periodStart,
      periodEnd: periodEnd,
      anchor: request.startDate,
    );
    final minimumDueCents = MinimumPaymentCalculator.calculateMinimumDueCents(
      debt: state.debt,
      terms: terms,
      openingBalanceCents: openingBalanceCents,
      accruedInterestCents: interestCents,
      balanceAfterChargesCents: balanceAfterChargesCents,
      scheduledOccurrences: scheduledOccurrences,
    );
    final warningSet = <ProjectionWarning>{};
    if (terms.promoApr != null &&
        terms.promoEndsOn != null &&
        !periodStart.isAfter(terms.promoEndsOn!)) {
      warningSet.add(ProjectionWarning.promoRateApplied);
    }
    if (monthlyFeeCents > 0) {
      warningSet.add(ProjectionWarning.recurringFeesApplied);
    }
    if (state.overdue && terms.penaltyApr != null) {
      warningSet.add(ProjectionWarning.penaltyAprApplied);
    }
    return _MonthlyDebtEntry(
      state: state,
      openingBalanceCents: openingBalanceCents,
      interestCents: interestCents,
      monthlyFeeCents: monthlyFeeCents,
      minimumDueCents: minimumDueCents,
      lateFeeCents: MoneyMath.toCents(max(0, terms.lateFee)),
      balanceAfterChargesCents: balanceAfterChargesCents,
      activeApr: activeApr,
      warnings: warningSet,
      appliedPenaltyApr: state.overdue && terms.penaltyApr != null,
    );
  }

  List<_MonthlyDebtEntry> _prioritize({
    required List<_MonthlyDebtEntry> entries,
    required StrategyRequest request,
  }) {
    final prioritized = [...entries];
    switch (request.strategyType) {
      case StrategyType.snowball:
        prioritized.sort(
          (a, b) =>
              a.balanceAfterMinimumCents.compareTo(b.balanceAfterMinimumCents),
        );
      case StrategyType.avalanche:
        prioritized.sort((a, b) {
          final aprCompare = b.activeApr.compareTo(a.activeApr);
          if (aprCompare != 0) {
            return aprCompare;
          }
          return a.balanceAfterMinimumCents.compareTo(
            b.balanceAfterMinimumCents,
          );
        });
      case StrategyType.customPriority:
        prioritized.sort((a, b) {
          final aPriority =
              request.customPriorities[a.state.debt.id] ??
              a.state.debt.customPriority;
          final bPriority =
              request.customPriorities[b.state.debt.id] ??
              b.state.debt.customPriority;
          if (aPriority != bPriority) {
            return aPriority.compareTo(bPriority);
          }
          final aprCompare = b.activeApr.compareTo(a.activeApr);
          if (aprCompare != 0) {
            return aprCompare;
          }
          return a.balanceAfterMinimumCents.compareTo(
            b.balanceAfterMinimumCents,
          );
        });
    }
    return prioritized;
  }

  int _minimumPriorityCompare(_MonthlyDebtEntry a, _MonthlyDebtEntry b) {
    if (a.state.overdue != b.state.overdue) {
      return a.state.overdue ? -1 : 1;
    }
    final aDue = _dueDay(a.state.debt);
    final bDue = _dueDay(b.state.debt);
    final dueCompare = aDue.compareTo(bDue);
    if (dueCompare != 0) {
      return dueCompare;
    }
    return b.activeApr.compareTo(a.activeApr);
  }

  bool _shouldApplyLateFee(_MonthlyDebtEntry entry, DateTime periodStart) {
    if (entry.lateFeeCents <= 0) {
      return false;
    }
    final dueDay = _dueDay(entry.state.debt);
    final graceDays = max(0, entry.state.debt.financialTerms.lateFeeGraceDays);
    return dueDay + graceDays <= _daysInMonth(periodStart);
  }

  double _activeAprForPeriod({
    required _DebtState state,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final terms = state.debt.financialTerms;
    final baseApr = _aprForDate(
      debt: state.debt,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
    if (state.overdue && terms.penaltyApr != null) {
      return max(baseApr, terms.penaltyApr!);
    }
    return baseApr;
  }

  double _aprForDate({
    required Debt debt,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final terms = debt.financialTerms;
    if (terms.promoApr == null || terms.promoEndsOn == null) {
      return debt.apr;
    }
    if (terms.promoEndsOn!.isBefore(periodStart)) {
      return debt.apr;
    }
    if (!periodEnd.isAfter(terms.promoEndsOn!)) {
      return terms.promoApr!;
    }
    final totalDays = max(1, periodEnd.difference(periodStart).inDays);
    final promoDays = max(0, terms.promoEndsOn!.difference(periodStart).inDays);
    final standardDays = max(0, totalDays - promoDays);
    return ((terms.promoApr! * promoDays) + (debt.apr * standardDays)) /
        totalDays;
  }

  int _scheduledOccurrences({
    required Debt debt,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime anchor,
  }) {
    switch (debt.paymentFrequency) {
      case PaymentFrequency.monthly:
        return 1;
      case PaymentFrequency.quarterly:
        final startMonthIndex = anchor.year * 12 + anchor.month;
        final periodMonthIndex = periodStart.year * 12 + periodStart.month;
        return (periodMonthIndex - startMonthIndex) % 3 == 0 ? 1 : 0;
      case PaymentFrequency.weekly:
        return _countRecurringOccurrences(
          stepDays: 7,
          debt: debt,
          periodStart: periodStart,
          periodEnd: periodEnd,
          anchor: anchor,
        );
      case PaymentFrequency.biweekly:
        return _countRecurringOccurrences(
          stepDays: 14,
          debt: debt,
          periodStart: periodStart,
          periodEnd: periodEnd,
          anchor: anchor,
        );
    }
  }

  int _countRecurringOccurrences({
    required int stepDays,
    required Debt debt,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime anchor,
  }) {
    var cursor = DateTime(
      debt.dueDate?.year ?? anchor.year,
      debt.dueDate?.month ?? anchor.month,
      debt.dueDate?.day ?? anchor.day,
    );
    while (cursor.isAfter(periodStart)) {
      cursor = cursor.subtract(Duration(days: stepDays));
    }
    while (cursor.isBefore(periodStart)) {
      cursor = cursor.add(Duration(days: stepDays));
    }
    var count = 0;
    while (cursor.isBefore(periodEnd)) {
      count++;
      cursor = cursor.add(Duration(days: stepDays));
    }
    return max(1, count);
  }

  int _dueDay(Debt debt) {
    final due = debt.dueDate?.day;
    if (due != null) {
      return due;
    }
    final statement = debt.financialTerms.statementDayOfMonth;
    if (statement != null) {
      return min(28, statement + 21);
    }
    return 28;
  }

  int _daysInMonth(DateTime month) =>
      DateTime(month.year, month.month + 1, 0).day;
}

class MinimumPaymentCalculator {
  const MinimumPaymentCalculator._();

  static int calculateMinimumDueCents({
    required Debt debt,
    required DebtFinancialTerms terms,
    required int openingBalanceCents,
    required int accruedInterestCents,
    required int balanceAfterChargesCents,
    required int scheduledOccurrences,
  }) {
    final fixedFloor =
        MoneyMath.toCents(max(0, debt.minimumPayment)) *
        max(0, scheduledOccurrences);
    final percentDue = terms.minimumPaymentPercent == null
        ? 0
        : MoneyMath.multiply(
            openingBalanceCents,
            max(0, terms.minimumPaymentPercent!) / 100,
          );

    final due = switch (terms.minimumPaymentRule) {
      MinimumPaymentRule.fixedAmount => fixedFloor,
      MinimumPaymentRule.maxOfFixedOrPercent => max(fixedFloor, percentDue),
      MinimumPaymentRule.interestPlusPercent => max(
        fixedFloor,
        accruedInterestCents + percentDue,
      ),
    };
    return min(balanceAfterChargesCents, max(0, due)).toInt();
  }
}

class AccrualCalculator {
  const AccrualCalculator._();

  static int calculateInterestCents({
    required int openingBalanceCents,
    required DateTime periodStart,
    required DateTime periodEnd,
    required InterestCompounding compounding,
    required double standardApr,
    double? promoApr,
    DateTime? promoEndsOn,
    double? effectiveAprOverride,
  }) {
    if (openingBalanceCents <= 0 || compounding == InterestCompounding.none) {
      return 0;
    }

    final segments = _rateSegments(
      periodStart: periodStart,
      periodEnd: periodEnd,
      standardApr: standardApr,
      promoApr: promoApr,
      promoEndsOn: promoEndsOn,
      overrideApr: effectiveAprOverride,
    );
    if (segments.isEmpty) {
      return 0;
    }

    switch (compounding) {
      case InterestCompounding.none:
        return 0;
      case InterestCompounding.dailySimple:
        var total = 0;
        for (final segment in segments) {
          total += MoneyMath.roundDouble(
            openingBalanceCents * (segment.apr / 100) * (segment.days / 365),
          );
        }
        return max(0, total);
      case InterestCompounding.monthlyCompound:
        final totalDays = max(1, periodEnd.difference(periodStart).inDays);
        final weightedApr =
            segments.fold<double>(
              0,
              (sum, segment) => sum + (segment.apr * segment.days),
            ) /
            totalDays;
        return max(
          0,
          MoneyMath.roundDouble(openingBalanceCents * (weightedApr / 100 / 12)),
        );
    }
  }

  static List<_RateSegment> _rateSegments({
    required DateTime periodStart,
    required DateTime periodEnd,
    required double standardApr,
    double? promoApr,
    DateTime? promoEndsOn,
    double? overrideApr,
  }) {
    if (overrideApr != null) {
      return [
        _RateSegment(
          apr: max(0, overrideApr),
          days: max(1, periodEnd.difference(periodStart).inDays),
        ),
      ];
    }
    if (promoApr == null ||
        promoEndsOn == null ||
        promoEndsOn.isBefore(periodStart)) {
      return [
        _RateSegment(
          apr: max(0, standardApr),
          days: max(1, periodEnd.difference(periodStart).inDays),
        ),
      ];
    }
    if (!periodEnd.isAfter(promoEndsOn)) {
      return [
        _RateSegment(
          apr: max(0, promoApr),
          days: max(1, periodEnd.difference(periodStart).inDays),
        ),
      ];
    }
    final promoDays = max(0, promoEndsOn.difference(periodStart).inDays);
    final standardDays =
        max(1, periodEnd.difference(periodStart).inDays) - promoDays;
    return [
      if (promoDays > 0) _RateSegment(apr: max(0, promoApr), days: promoDays),
      if (standardDays > 0)
        _RateSegment(apr: max(0, standardApr), days: standardDays),
    ];
  }
}

class OverduePolicyEvaluator {
  const OverduePolicyEvaluator._();

  static bool shouldCarryOverdue({required int shortfallCents}) {
    return shortfallCents > 0;
  }
}

class _DebtState {
  _DebtState({required this.debt, required this.balanceCents});

  final Debt debt;
  int balanceCents;
  bool overdue = false;
}

class _MonthlyDebtEntry {
  _MonthlyDebtEntry({
    required this.state,
    required this.openingBalanceCents,
    required this.interestCents,
    required this.monthlyFeeCents,
    required this.minimumDueCents,
    required this.lateFeeCents,
    required this.balanceAfterChargesCents,
    required this.activeApr,
    required this.warnings,
    required this.appliedPenaltyApr,
  });

  final _DebtState state;
  final int openingBalanceCents;
  final int interestCents;
  final int monthlyFeeCents;
  final int minimumDueCents;
  final int lateFeeCents;
  final int balanceAfterChargesCents;
  final double activeApr;
  final Set<ProjectionWarning> warnings;
  final bool appliedPenaltyApr;
  int minimumPaymentAppliedCents = 0;
  int extraPaymentAppliedCents = 0;

  int get balanceAfterMinimumCents =>
      max(0, balanceAfterChargesCents - minimumPaymentAppliedCents);
}

class _RateSegment {
  const _RateSegment({required this.apr, required this.days});

  final double apr;
  final int days;
}

class _ProjectionComputation {
  const _ProjectionComputation({
    required this.strategyType,
    required this.payoffDate,
    required this.totalInterestPaid,
    required this.monthsToPayoff,
    required this.payoffOrder,
    required this.schedule,
    required this.minimumRequiredPerCycle,
    required this.budgetShortfall,
    required this.warnings,
  });

  final StrategyType strategyType;
  final DateTime payoffDate;
  final double totalInterestPaid;
  final int monthsToPayoff;
  final List<Debt> payoffOrder;
  final List<StrategyMonthResult> schedule;
  final double minimumRequiredPerCycle;
  final double budgetShortfall;
  final Set<ProjectionWarning> warnings;
}
