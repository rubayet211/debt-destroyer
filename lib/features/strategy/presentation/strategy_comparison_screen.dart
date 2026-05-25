import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/user_preferences.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/strategy_comparison_service.dart';

class StrategyComparisonScreen extends ConsumerStatefulWidget {
  const StrategyComparisonScreen({super.key});

  @override
  ConsumerState<StrategyComparisonScreen> createState() =>
      _StrategyComparisonScreenState();
}

class _StrategyComparisonScreenState
    extends ConsumerState<StrategyComparisonScreen> {
  StrategyType _selectedStrategy = StrategyType.avalanche;
  bool _initializedSelection = false;

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtsProvider);
    final preferencesAsync = ref.watch(userPreferencesProvider);

    return AppPage(
      title: 'Strategy comparison',
      child: debtsAsync.when(
        loading: () => const LoadingPane(message: 'Loading your debts...'),
        error: (error, _) => AppErrorState(message: error.toString()),
        data: (debts) {
          final preferences = preferencesAsync.valueOrNull;
          if (!_initializedSelection && preferences != null) {
            _selectedStrategy = preferences.defaultStrategy;
            _initializedSelection = true;
          }

          final activeDebts = debts.where((debt) => debt.isActive).toList();
          if (activeDebts.isEmpty) {
            return const EmptyStateView(
              title: 'Add debts to compare strategies',
              message:
                  'Once you add active debts, this screen can estimate payoff options.',
              icon: Icons.compare_arrows_rounded,
            );
          }

          final comparison = const StrategyComparisonService().compare(
            debts: activeDebts,
            monthlyBudget: _minimumBudget(activeDebts),
            startDate: DateTime.now(),
          );
          final currencyCode = preferences?.currencyCode ?? 'USD';
          final selectedSummary = comparison.summaryFor(_selectedStrategy);

          return ListView(
            children: [
              SectionHeader(
                title: 'Choose a payoff path',
                subtitle:
                    'Compare simple estimates from your current active debts.',
                trailing: AppStatusBadge(
                  label: '${activeDebts.length} debts',
                  icon: Icons.lock_outline_rounded,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _RecommendationCard(
                comparison: comparison,
                onSelect: (strategy) =>
                    setState(() => _selectedStrategy = strategy),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Side-by-side estimate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comparison.summaries
                      .map(
                        (summary) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: SizedBox(
                            width: 250,
                            child: _ComparisonEstimateCard(
                              summary: summary,
                              currencyCode: currencyCode,
                              selected:
                                  summary.strategyType == _selectedStrategy,
                              recommended:
                                  summary.strategyType ==
                                  comparison.recommendedStrategy,
                              onSelect: () => setState(
                                () => _selectedStrategy = summary.strategyType,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...comparison.summaries.map(
                (summary) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _StrategyDetailCard(
                    summary: summary,
                    selected: summary.strategyType == _selectedStrategy,
                    currencyCode: currencyCode,
                    onSelected: () => setState(
                      () => _selectedStrategy = summary.strategyType,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: preferencesAsync.isLoading
                    ? null
                    : () => _applyStrategy(
                        context,
                        preferences ?? UserPreferences.defaults(),
                      ),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text('Apply ${_shortStrategyLabel(_selectedStrategy)}'),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Selected estimate: ${Formatters.currency(selectedSummary.totalAmountPaid, currencyCode: currencyCode)} over ${selectedSummary.monthsToPayoff} months.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'These are estimates based on the information you provided. Actual results may vary.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _applyStrategy(
    BuildContext context,
    UserPreferences preferences,
  ) async {
    await ref
        .read(preferencesRepositoryProvider)
        .savePreferences(
          preferences.copyWith(defaultStrategy: _selectedStrategy),
        );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_shortStrategyLabel(_selectedStrategy)} applied to your plan',
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.comparison, required this.onSelect});

  final StrategyComparison comparison;
  final ValueChanged<StrategyType> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      color: scheme.secondaryContainer.withValues(alpha: 0.5),
      borderColor: scheme.secondary.withValues(alpha: 0.24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: scheme.onSecondaryContainer),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended for me',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_strategyTitle(comparison.recommendedStrategy)}: ${comparison.recommendationReason}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => onSelect(comparison.recommendedStrategy),
                    icon: const Icon(Icons.touch_app_outlined),
                    label: const Text('Use recommendation'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonEstimateCard extends StatelessWidget {
  const _ComparisonEstimateCard({
    required this.summary,
    required this.currencyCode,
    required this.selected,
    required this.recommended,
    required this.onSelect,
  });

  final StrategyComparisonSummary summary;
  final String currencyCode;
  final bool selected;
  final bool recommended;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = selected ? scheme.primary : scheme.secondary;
    final maxMonths = max(1, summary.monthsToPayoff + 6);
    return AppCard(
      onTap: onSelect,
      borderColor: selected ? scheme.primary : null,
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.08) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _strategyTitle(summary.strategyType),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: 'Select ${_strategyTitle(summary.strategyType)}',
                onPressed: onSelect,
                icon: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (recommended)
            const AppStatusBadge(
              label: 'Recommended',
              icon: Icons.verified_outlined,
            ),
          const SizedBox(height: AppSpacing.md),
          _MetricLine(
            label: 'Total interest paid',
            value: Formatters.currency(
              summary.totalInterestPaid,
              currencyCode: currencyCode,
            ),
          ),
          _MetricLine(
            label: 'Months until debt-free',
            value: '${summary.monthsToPayoff}',
          ),
          _MetricLine(
            label: 'Total amount paid',
            value: Formatters.currency(
              summary.totalAmountPaid,
              currencyCode: currencyCode,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: (summary.monthsToPayoff / maxMonths).clamp(0.08, 1),
            color: accent,
          ),
        ],
      ),
    );
  }
}

class _StrategyDetailCard extends StatelessWidget {
  const _StrategyDetailCard({
    required this.summary,
    required this.selected,
    required this.currencyCode,
    required this.onSelected,
  });

  final StrategyComparisonSummary summary;
  final bool selected;
  final String currencyCode;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final content = _strategyContent(summary.strategyType);
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      borderColor: selected ? scheme.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(content.icon, color: scheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _strategyTitle(summary.strategyType),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      content.howItWorks,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Select ${_strategyTitle(summary.strategyType)}',
                onPressed: onSelected,
                icon: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Best for: ${content.bestFor}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
            title: const Text('Learn more'),
            children: [
              _BulletList(title: 'Pros', items: content.pros),
              const SizedBox(height: AppSpacing.sm),
              _BulletList(title: 'Cons', items: content.cons),
              const SizedBox(height: AppSpacing.sm),
              _MetricLine(
                label: 'Estimated interest',
                value: Formatters.currency(
                  summary.totalInterestPaid,
                  currencyCode: currencyCode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

double _minimumBudget(List<Debt> debts) {
  return debts.fold<double>(0, (sum, debt) => sum + debt.minimumPayment);
}

String _strategyTitle(StrategyType strategy) {
  return switch (strategy) {
    StrategyType.snowball => 'Debt Snowball',
    StrategyType.avalanche => 'Debt Avalanche',
    StrategyType.customPriority => 'Custom',
  };
}

String _shortStrategyLabel(StrategyType strategy) {
  return switch (strategy) {
    StrategyType.snowball => 'Snowball',
    StrategyType.avalanche => 'Avalanche',
    StrategyType.customPriority => 'Custom',
  };
}

_StrategyContent _strategyContent(StrategyType strategy) {
  return switch (strategy) {
    StrategyType.snowball => const _StrategyContent(
      icon: Icons.ac_unit_rounded,
      howItWorks:
          'Pay minimums on every debt, then send extra money to the lowest balance first.',
      bestFor: 'Best for staying motivated with quick wins.',
      pros: [
        'Quick wins can make progress feel real.',
        'Simpler to follow when you have several small debts.',
      ],
      cons: [
        'May cost more interest than targeting high-rate debts first.',
        'Large expensive debts may wait longer.',
      ],
    ),
    StrategyType.avalanche => const _StrategyContent(
      icon: Icons.trending_down_rounded,
      howItWorks:
          'Pay minimums on every debt, then send extra money to the highest interest rate first.',
      bestFor: 'Best for saving the most money on interest.',
      pros: [
        'Usually lowers total interest paid.',
        'Targets the debts growing fastest.',
      ],
      cons: [
        'First payoff can take longer.',
        'May feel slower if the highest-rate debt has a large balance.',
      ],
    ),
    StrategyType.customPriority => const _StrategyContent(
      icon: Icons.tune_rounded,
      howItWorks:
          'Pay debts in the priority order you set on each debt profile.',
      bestFor: 'Best when you have personal reasons for a specific order.',
      pros: [
        'Matches your own priorities and deadlines.',
        'Useful for family loans, collections, or special terms.',
      ],
      cons: [
        'May not save the most interest.',
        'Needs priorities to stay up to date.',
      ],
    ),
  };
}

class _StrategyContent {
  const _StrategyContent({
    required this.icon,
    required this.howItWorks,
    required this.bestFor,
    required this.pros,
    required this.cons,
  });

  final IconData icon;
  final String howItWorks;
  final String bestFor;
  final List<String> pros;
  final List<String> cons;
}
