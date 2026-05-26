import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/parsers.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/strategy_models.dart';
import '../../../shared/models/user_preferences.dart';
import '../../../shared/providers/app_providers.dart';

Future<void> showAdjustPlanSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const AdjustPlanSheet(),
  );
}

class AdjustPlanSheet extends ConsumerStatefulWidget {
  const AdjustPlanSheet({super.key});

  @override
  ConsumerState<AdjustPlanSheet> createState() => _AdjustPlanSheetState();
}

class _AdjustPlanSheetState extends ConsumerState<AdjustPlanSheet> {
  final _monthlyExtraController = TextEditingController();
  final _oneTimeExtraController = TextEditingController();
  final _pausedDebtIds = <String>{};
  StrategyType _strategy = StrategyType.avalanche;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _monthlyExtraController.dispose();
    _oneTimeExtraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtsProvider);
    final prefsAsync = ref.watch(userPreferencesProvider);

    if (debtsAsync is AsyncError<List<Debt>>) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppErrorState(message: debtsAsync.error.toString()),
      );
    }
    if (prefsAsync is AsyncError<UserPreferences>) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppErrorState(message: prefsAsync.error.toString()),
      );
    }
    if (debtsAsync is! AsyncData<List<Debt>> ||
        prefsAsync is! AsyncData<UserPreferences>) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: LoadingPane(message: 'Loading your plan...'),
      );
    }

    final debts = debtsAsync.value.where((debt) => debt.isActive).toList();
    final preferences = prefsAsync.value;
    _initialize(preferences, debts);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (context, controller) {
          if (debts.isEmpty) {
            return ListView(
              controller: controller,
              children: const [
                _SheetHandle(),
                EmptyStateView(
                  title: 'No active debts',
                  message:
                      'Add a debt before adjusting your payoff plan settings.',
                  icon: Icons.tune_rounded,
                ),
              ],
            );
          }

          final preview = _buildPreview(debts, preferences);
          return ListView(
            controller: controller,
            children: [
              const _SheetHandle(),
              _Header(preview: preview, currency: preferences.currencyCode),
              const SizedBox(height: AppSpacing.lg),
              _StrategyPicker(
                strategy: _strategy,
                onChanged: (strategy) => setState(() => _strategy = strategy),
              ),
              const SizedBox(height: AppSpacing.md),
              _PaymentControls(
                monthlyController: _monthlyExtraController,
                oneTimeController: _oneTimeExtraController,
                monthlyError: _moneyError(_monthlyExtraController.text),
                oneTimeError: _moneyError(_oneTimeExtraController.text),
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              _PausedDebtPicker(
                debts: debts,
                pausedDebtIds: _pausedDebtIds,
                onChanged: (debtId, value) {
                  setState(() {
                    if (value) {
                      _pausedDebtIds.add(debtId);
                    } else {
                      _pausedDebtIds.remove(debtId);
                    }
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _PreviewCard(
                preview: preview,
                currency: preferences.currencyCode,
              ),
              const SizedBox(height: AppSpacing.md),
              _SafetyNote(
                oneTimeExtra: _oneTimeExtra,
                currency: preferences.currencyCode,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ActionBar(
                saving: _saving,
                canApply: !_hasInputErrors,
                onCancel: () => Navigator.of(context).maybePop(),
                onApply: () => _apply(preferences: preferences, debts: debts),
              ),
            ],
          );
        },
      ),
    );
  }

  void _initialize(UserPreferences preferences, List<Debt> debts) {
    if (_initialized) {
      return;
    }
    _strategy = preferences.defaultStrategy;
    _monthlyExtraController.text = _formatInput(
      preferences.planExtraMonthlyPayment,
    );
    _oneTimeExtraController.text = _formatInput(
      preferences.planOneTimeExtraPayment,
    );
    _pausedDebtIds
      ..clear()
      ..addAll(debts.where((debt) => debt.planPaused).map((debt) => debt.id));
    _initialized = true;
  }

  String _formatInput(double value) {
    if (value <= 0) {
      return '0';
    }
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  _PlanPreview _buildPreview(List<Debt> debts, UserPreferences preferences) {
    final startDate = DateTime.now();
    final minimumBudget = debts.fold<double>(
      0,
      (sum, debt) => sum + debt.minimumPayment,
    );
    final customPriorities = {
      for (final debt in debts) debt.id: debt.customPriority,
    };
    final engine = ref.watch(strategyEngineProvider);
    final currentPaused = {
      for (final debt in debts)
        if (debt.planPaused) debt.id,
    };
    final current = engine.simulate(
      debts: debts,
      request: StrategyRequest(
        strategyType: preferences.defaultStrategy,
        monthlyBudget: minimumBudget,
        extraMonthlyPayment: preferences.planExtraMonthlyPayment,
        startDate: startDate,
        lumpSum: preferences.planOneTimeExtraPayment,
        includeArchived: false,
        customPriorities: customPriorities,
        allowUnderMinimumBudget: false,
        pausedDebtIds: currentPaused,
      ),
    );
    final adjusted = engine.simulate(
      debts: debts,
      request: StrategyRequest(
        strategyType: _strategy,
        monthlyBudget: minimumBudget,
        extraMonthlyPayment: _monthlyExtra,
        startDate: startDate,
        lumpSum: _oneTimeExtra,
        includeArchived: false,
        customPriorities: customPriorities,
        allowUnderMinimumBudget: false,
        pausedDebtIds: _pausedDebtIds,
      ),
    );
    return _PlanPreview(
      current: current,
      adjusted: adjusted,
      monthsSaved: max(0, current.monthsToPayoff - adjusted.monthsToPayoff),
      interestSaved: max(
        0,
        current.totalInterestPaid - adjusted.totalInterestPaid,
      ).toDouble(),
      monthlyExtra: _monthlyExtra,
      oneTimeExtra: _oneTimeExtra,
      pausedCount: _pausedDebtIds.length,
    );
  }

  Future<void> _apply({
    required UserPreferences preferences,
    required List<Debt> debts,
  }) async {
    if (_hasInputErrors || _saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(preferencesRepositoryProvider)
          .savePreferences(
            preferences.copyWith(
              defaultStrategy: _strategy,
              planExtraMonthlyPayment: _monthlyExtra,
              planOneTimeExtraPayment: _oneTimeExtra,
            ),
          );

      final debtsRepository = ref.read(debtsRepositoryProvider);
      for (final debt in debts) {
        final nextPaused = _pausedDebtIds.contains(debt.id);
        if (debt.planPaused == nextPaused) {
          continue;
        }
        await debtsRepository.saveDebt(
          debt.copyWith(planPaused: nextPaused, updatedAt: DateTime.now()),
        );
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Plan updated')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  bool get _hasInputErrors =>
      _moneyError(_monthlyExtraController.text) != null ||
      _moneyError(_oneTimeExtraController.text) != null;

  double get _monthlyExtra =>
      max(0, Parsers.parseMoney(_monthlyExtraController.text)).toDouble();

  double get _oneTimeExtra =>
      max(0, Parsers.parseMoney(_oneTimeExtraController.text)).toDouble();

  String? _moneyError(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    if (Parsers.parseMoney(value) < 0) {
      return 'Enter 0 or more';
    }
    return null;
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.preview, required this.currency});

  final _PlanPreview preview;
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
            'Adjust payoff plan',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.date(preview.adjusted.payoffDate),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Interest change',
                  value: Formatters.currency(
                    preview.interestSaved,
                    currencyCode: currency,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeroMetric(
                  label: 'Months saved',
                  value: preview.monthsSaved.toString(),
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

class _StrategyPicker extends StatelessWidget {
  const _StrategyPicker({required this.strategy, required this.onChanged});

  final StrategyType strategy;
  final ValueChanged<StrategyType> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Strategy',
            subtitle: 'Choose how extra money is focused after minimums.',
          ),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<StrategyType>(
            segments: const [
              ButtonSegment(
                value: StrategyType.snowball,
                label: Text('Snowball'),
              ),
              ButtonSegment(
                value: StrategyType.avalanche,
                label: Text('Avalanche'),
              ),
              ButtonSegment(
                value: StrategyType.customPriority,
                label: Text('Custom'),
              ),
            ],
            selected: {strategy},
            onSelectionChanged: (selection) => onChanged(selection.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentControls extends StatelessWidget {
  const _PaymentControls({
    required this.monthlyController,
    required this.oneTimeController,
    required this.monthlyError,
    required this.oneTimeError,
    required this.onChanged,
  });

  final TextEditingController monthlyController;
  final TextEditingController oneTimeController;
  final String? monthlyError;
  final String? oneTimeError;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Extra payments',
            subtitle: 'Preview changes before they touch your real plan.',
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const ValueKey('monthly-extra-input'),
            controller: monthlyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
            ],
            decoration: InputDecoration(
              labelText: 'Monthly extra payment',
              helperText: 'Amount you can add each month.',
              errorText: monthlyError,
              prefixIcon: const Icon(Icons.add_card_outlined),
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const ValueKey('one-time-extra-input'),
            controller: oneTimeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
            ],
            decoration: InputDecoration(
              labelText: 'One-time extra payment',
              helperText: 'Applied once at the start of the projection.',
              errorText: oneTimeError,
              prefixIcon: const Icon(Icons.savings_outlined),
            ),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

class _PausedDebtPicker extends StatelessWidget {
  const _PausedDebtPicker({
    required this.debts,
    required this.pausedDebtIds,
    required this.onChanged,
  });

  final List<Debt> debts;
  final Set<String> pausedDebtIds;
  final void Function(String debtId, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Pause payoff focus',
            subtitle:
                'Paused debts still get minimum payments, but extra money goes elsewhere first.',
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final debt in debts)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: pausedDebtIds.contains(debt.id),
              onChanged: (value) => onChanged(debt.id, value ?? false),
              title: Text(debt.title),
              subtitle: Text(
                '${Formatters.currency(debt.currentBalance, currencyCode: debt.currency)} • ${Formatters.percent(debt.apr)} APR',
              ),
              controlAffinity: ListTileControlAffinity.trailing,
            ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview, required this.currency});

  final _PlanPreview preview;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final progress = preview.current.monthsToPayoff <= 0
        ? 0.0
        : (preview.monthsSaved / preview.current.monthsToPayoff)
              .clamp(0, 1)
              .toDouble();
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Instant preview',
            subtitle: 'Current plan compared with these adjustments.',
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              color: AppColors.secondary,
              backgroundColor: AppColors.surfaceContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricLine(
            label: 'Current debt-free date',
            value: Formatters.date(preview.current.payoffDate),
          ),
          _MetricLine(
            label: 'New debt-free date',
            value: Formatters.date(preview.adjusted.payoffDate),
          ),
          _MetricLine(
            label: 'Projected interest',
            value: Formatters.currency(
              preview.adjusted.totalInterestPaid,
              currencyCode: currency,
            ),
          ),
          _MetricLine(
            label: 'Interest saved',
            value: Formatters.currency(
              preview.interestSaved,
              currencyCode: currency,
            ),
          ),
          _MetricLine(label: 'Months saved', value: '${preview.monthsSaved}'),
          if (preview.pausedCount > 0)
            AppStatusBadge(
              label:
                  '${preview.pausedCount} debt${preview.pausedCount == 1 ? '' : 's'} paused from extra payoff focus',
              icon: Icons.pause_circle_outline_rounded,
            ),
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
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote({required this.oneTimeExtra, required this.currency});

  final double oneTimeExtra;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final oneTimeText = oneTimeExtra > 0
        ? ' Your one-time extra of ${Formatters.currency(oneTimeExtra, currencyCode: currency)} stays in the projection until you set it back to 0.'
        : '';
    return AppCard(
      color: AppColors.surfaceContainer,
      borderColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_reset_rounded, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Nothing changes until you tap Apply changes. You can reopen this anytime and adjust it back.$oneTimeText',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.saving,
    required this.canApply,
    required this.onCancel,
    required this.onApply,
  });

  final bool saving;
  final bool canApply;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: saving ? null : onCancel,
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: FilledButton.icon(
            onPressed: saving || !canApply ? null : onApply,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(saving ? 'Applying' : 'Apply changes'),
          ),
        ),
      ],
    );
  }
}

class _PlanPreview {
  const _PlanPreview({
    required this.current,
    required this.adjusted,
    required this.monthsSaved,
    required this.interestSaved,
    required this.monthlyExtra,
    required this.oneTimeExtra,
    required this.pausedCount,
  });

  final StrategyResult current;
  final StrategyResult adjusted;
  final int monthsSaved;
  final double interestSaved;
  final double monthlyExtra;
  final double oneTimeExtra;
  final int pausedCount;
}
