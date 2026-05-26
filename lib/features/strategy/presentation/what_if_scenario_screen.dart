import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/parsers.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/monetization_widgets.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/strategy_models.dart';
import '../../../shared/models/subscription_state.dart';
import '../../../shared/models/user_preferences.dart';
import '../../../shared/providers/app_providers.dart';

class WhatIfScenarioScreen extends ConsumerStatefulWidget {
  const WhatIfScenarioScreen({super.key});

  @override
  ConsumerState<WhatIfScenarioScreen> createState() =>
      _WhatIfScenarioScreenState();
}

class _WhatIfScenarioScreenState extends ConsumerState<WhatIfScenarioScreen> {
  static const _presetExtras = [100.0, 200.0, 500.0];

  final _customExtraController = TextEditingController(text: '100');
  double _selectedExtra = 100;

  @override
  void dispose() {
    _customExtraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(debtsProvider).valueOrNull ?? const <Debt>[];
    final preferences =
        ref.watch(userPreferencesProvider).valueOrNull ??
        UserPreferences.defaults();
    final scenarios = ref.watch(scenariosProvider).valueOrNull ?? const [];
    final subscription =
        ref.watch(subscriptionStateProvider).valueOrNull ??
        SubscriptionState.free();
    final activeDebts = debts.where((debt) => debt.isActive).toList();
    final currency = preferences.currencyCode;

    return AppPage(
      title: 'What If',
      actions: [
        IconButton(
          tooltip: 'Compare strategies',
          onPressed: () => context.push('/strategy/compare'),
          icon: const Icon(Icons.compare_arrows_rounded),
        ),
      ],
      child: activeDebts.isEmpty
          ? const EmptyStateView(
              title: 'Add debts to try scenarios',
              message:
                  'The What If planner needs at least one active debt before it can estimate payoff changes.',
              icon: Icons.auto_graph_outlined,
            )
          : _PlannerContent(
              debts: activeDebts,
              preferences: preferences,
              scenarios: scenarios,
              subscription: subscription,
              selectedExtra: _selectedExtra,
              currency: currency,
              customExtraController: _customExtraController,
              onPresetSelected: _selectPreset,
              onCustomChanged: _selectCustom,
              onSaveFavorite: _saveFavorite,
              onApplyScenario: _applyScenario,
            ),
    );
  }

  void _selectPreset(double value) {
    setState(() {
      _selectedExtra = value;
      _customExtraController.text = value.toStringAsFixed(0);
    });
  }

  void _selectCustom(String value) {
    setState(() => _selectedExtra = max(0, Parsers.parseMoney(value)));
  }

  Future<void> _saveFavorite({
    required StrategyType strategy,
    required double budget,
    required double extraPayment,
    required StrategyResult original,
    required StrategyResult scenario,
    required SubscriptionState subscription,
  }) async {
    final hasAccess = ref
        .read(premiumServiceProvider)
        .guard(subscription, PremiumFeature.scenarioSaving);
    if (!hasAccess) {
      if (mounted) {
        await showPremiumUpsellSheet(
          context,
          title: 'Scenario saving is part of Premium',
          message:
              'Premium saves your favorite payoff experiments so you can revisit the ones that change your timeline.',
        );
      }
      return;
    }

    await ref
        .read(scenariosRepositoryProvider)
        .saveScenario(
          Scenario(
            id: const Uuid().v4(),
            strategyType: strategy,
            extraPayment: extraPayment,
            budget: budget,
            createdAt: DateTime.now(),
            label:
                '+${Formatters.currency(extraPayment, currencyCode: 'USD')} scenario',
            baselineInterest: original.totalInterestPaid,
            optimizedInterest: scenario.totalInterestPaid,
            monthsToPayoff: scenario.monthsToPayoff,
          ),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Scenario saved')));
    }
  }

  Future<void> _applyScenario({
    required UserPreferences preferences,
    required double extraPayment,
  }) async {
    await ref
        .read(preferencesRepositoryProvider)
        .savePreferences(
          preferences.copyWith(planExtraMonthlyPayment: extraPayment),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scenario applied to your plan')),
      );
    }
  }
}

class _PlannerContent extends ConsumerWidget {
  const _PlannerContent({
    required this.debts,
    required this.preferences,
    required this.scenarios,
    required this.subscription,
    required this.selectedExtra,
    required this.currency,
    required this.customExtraController,
    required this.onPresetSelected,
    required this.onCustomChanged,
    required this.onSaveFavorite,
    required this.onApplyScenario,
  });

  final List<Debt> debts;
  final UserPreferences preferences;
  final List<Scenario> scenarios;
  final SubscriptionState subscription;
  final double selectedExtra;
  final String currency;
  final TextEditingController customExtraController;
  final ValueChanged<double> onPresetSelected;
  final ValueChanged<String> onCustomChanged;
  final Future<void> Function({
    required StrategyType strategy,
    required double budget,
    required double extraPayment,
    required StrategyResult original,
    required StrategyResult scenario,
    required SubscriptionState subscription,
  })
  onSaveFavorite;
  final Future<void> Function({
    required UserPreferences preferences,
    required double extraPayment,
  })
  onApplyScenario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minimumBudget = debts.fold<double>(
      0,
      (sum, debt) => sum + debt.minimumPayment,
    );
    final engine = ref.watch(strategyEngineProvider);
    final customPriorities = {
      for (final debt in debts) debt.id: debt.customPriority,
    };
    final startDate = DateTime.now();
    final original = engine.simulate(
      debts: debts,
      request: StrategyRequest(
        strategyType: preferences.defaultStrategy,
        monthlyBudget: minimumBudget,
        extraMonthlyPayment: preferences.planExtraMonthlyPayment,
        startDate: startDate,
        lumpSum: 0,
        includeArchived: false,
        customPriorities: customPriorities,
      ),
    );
    final scenario = engine.simulate(
      debts: debts,
      request: StrategyRequest(
        strategyType: preferences.defaultStrategy,
        monthlyBudget: minimumBudget,
        extraMonthlyPayment: selectedExtra,
        startDate: startDate,
        lumpSum: 0,
        includeArchived: false,
        customPriorities: customPriorities,
      ),
    );
    final interestSaved = max(
      0,
      original.totalInterestPaid - scenario.totalInterestPaid,
    ).toDouble();
    final monthsSaved = max(
      0,
      original.monthsToPayoff - scenario.monthsToPayoff,
    );

    return ListView(
      children: [
        _HeroSummary(
          scenario: scenario,
          interestSaved: interestSaved,
          monthsSaved: monthsSaved,
          currency: currency,
        ),
        const SizedBox(height: AppSpacing.lg),
        _ExtraPaymentPicker(
          selectedExtra: selectedExtra,
          currency: currency,
          controller: customExtraController,
          onPresetSelected: onPresetSelected,
          onCustomChanged: onCustomChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        _ComparisonGrid(
          original: original,
          scenario: scenario,
          currency: currency,
          interestSaved: interestSaved,
          monthsSaved: monthsSaved,
        ),
        const SizedBox(height: AppSpacing.lg),
        _ApplyCard(
          strategy: preferences.defaultStrategy,
          currentExtra: preferences.planExtraMonthlyPayment,
          selectedExtra: selectedExtra,
          currency: currency,
          onSaveFavorite: () => onSaveFavorite(
            strategy: preferences.defaultStrategy,
            budget: minimumBudget,
            extraPayment: selectedExtra,
            original: original,
            scenario: scenario,
            subscription: subscription,
          ),
          onApplyScenario: () => onApplyScenario(
            preferences: preferences,
            extraPayment: selectedExtra,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SavedScenariosSection(scenarios: scenarios, currency: currency),
      ],
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({
    required this.scenario,
    required this.interestSaved,
    required this.monthsSaved,
    required this.currency,
  });

  final StrategyResult scenario;
  final double interestSaved;
  final int monthsSaved;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primaryContainer,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What If Planner',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'New debt-free date',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.date(scenario.payoffDate),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Total interest saved',
                  value: Formatters.currency(
                    interestSaved,
                    currencyCode: currency,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeroMetric(
                  label: 'Months saved',
                  value: '$monthsSaved',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ExtraPaymentPicker extends StatelessWidget {
  const _ExtraPaymentPicker({
    required this.selectedExtra,
    required this.currency,
    required this.controller,
    required this.onPresetSelected,
    required this.onCustomChanged,
  });

  final double selectedExtra;
  final String currency;
  final TextEditingController controller;
  final ValueChanged<double> onPresetSelected;
  final ValueChanged<String> onCustomChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Try an extra payment',
            subtitle: 'Run a scenario without changing your actual plan.',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final value in _WhatIfScenarioScreenState._presetExtras)
                ChoiceChip(
                  label: Text(
                    '+${Formatters.currency(value, currencyCode: currency).replaceAll('.00', '')}',
                  ),
                  selected: selectedExtra == value,
                  onSelected: (_) => onPresetSelected(value),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Custom extra monthly payment',
              prefixIcon: Icon(Icons.add_card_outlined),
            ),
            onChanged: onCustomChanged,
          ),
        ],
      ),
    );
  }
}

class _ComparisonGrid extends StatelessWidget {
  const _ComparisonGrid({
    required this.original,
    required this.scenario,
    required this.currency,
    required this.interestSaved,
    required this.monthsSaved,
  });

  final StrategyResult original;
  final StrategyResult scenario;
  final String currency;
  final double interestSaved;
  final int monthsSaved;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _PlanCard(
            title: 'Original plan',
            result: original,
            currency: currency,
            accent: AppColors.primaryContainer,
          ),
          _PlanCard(
            title: 'New scenario',
            result: scenario,
            currency: currency,
            accent: AppColors.secondary,
            footer:
                '${Formatters.currency(interestSaved, currencyCode: currency)} interest saved • $monthsSaved months saved',
          ),
        ];
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              cards.first,
              const SizedBox(height: AppSpacing.sm),
              cards.last,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: cards.first),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: cards.last),
          ],
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.result,
    required this.currency,
    required this.accent,
    this.footer,
  });

  final String title;
  final StrategyResult result;
  final String currency;
  final Color accent;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.flag_outlined, color: accent, size: 19),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricLine(
            label: 'Debt-free date',
            value: Formatters.date(result.payoffDate),
          ),
          _MetricLine(
            label: 'Interest paid',
            value: Formatters.currency(
              result.totalInterestPaid,
              currencyCode: currency,
            ),
          ),
          _MetricLine(label: 'Months', value: '${result.monthsToPayoff}'),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(footer!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _ApplyCard extends StatelessWidget {
  const _ApplyCard({
    required this.strategy,
    required this.currentExtra,
    required this.selectedExtra,
    required this.currency,
    required this.onSaveFavorite,
    required this.onApplyScenario,
  });

  final StrategyType strategy;
  final double currentExtra;
  final double selectedExtra;
  final String currency;
  final VoidCallback onSaveFavorite;
  final VoidCallback onApplyScenario;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current strategy',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.strategyLabel(strategy),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Applying this scenario sets your real plan extra payment to ${Formatters.currency(selectedExtra, currencyCode: currency)} per month.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (currentExtra != selectedExtra) ...[
            const SizedBox(height: AppSpacing.sm),
            AppStatusBadge(
              label:
                  'Currently ${Formatters.currency(currentExtra, currencyCode: currency)} extra',
              icon: Icons.info_outline_rounded,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSaveFavorite,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save favorite'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onApplyScenario,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Apply to my plan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedScenariosSection extends StatelessWidget {
  const _SavedScenariosSection({
    required this.scenarios,
    required this.currency,
  });

  final List<Scenario> scenarios;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (scenarios.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Saved favorites'),
        const SizedBox(height: AppSpacing.sm),
        ...scenarios
            .take(3)
            .map(
              (scenario) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  radius: AppRadius.lg,
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_border_rounded),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scenario.label,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${scenario.monthsToPayoff} months • ${Formatters.currency(scenario.extraPayment, currencyCode: currency)} extra',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
