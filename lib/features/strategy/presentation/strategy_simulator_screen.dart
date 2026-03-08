import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/parsers.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/subscription_state.dart';
import '../../../shared/models/strategy_models.dart';
import '../../../shared/providers/app_providers.dart';

class StrategySimulatorScreen extends ConsumerStatefulWidget {
  const StrategySimulatorScreen({super.key});

  @override
  ConsumerState<StrategySimulatorScreen> createState() =>
      _StrategySimulatorScreenState();
}

class _StrategySimulatorScreenState
    extends ConsumerState<StrategySimulatorScreen> {
  StrategyType _strategy = StrategyType.avalanche;
  final _budgetController = TextEditingController();
  final _extraController = TextEditingController(text: '100');
  final _lumpSumController = TextEditingController(text: '0');

  @override
  void dispose() {
    _budgetController.dispose();
    _extraController.dispose();
    _lumpSumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(debtsProvider).valueOrNull ?? const <Debt>[];
    final preferences = ref.watch(userPreferencesProvider).valueOrNull;
    final activeDebts = debts.where((debt) => debt.isActive).toList();
    final minimumBudget = activeDebts.fold<double>(
      0,
      (sum, debt) => sum + debt.minimumPayment,
    );
    if (_budgetController.text.isEmpty && minimumBudget > 0) {
      _budgetController.text = minimumBudget.toStringAsFixed(0);
    }
    final result = ref
        .watch(strategyEngineProvider)
        .simulate(
          debts: activeDebts,
          request: StrategyRequest(
            strategyType: _strategy,
            monthlyBudget: Parsers.parseMoney(_budgetController.text),
            extraMonthlyPayment: Parsers.parseMoney(_extraController.text),
            startDate: DateTime.now(),
            lumpSum: Parsers.parseMoney(_lumpSumController.text),
            includeArchived: false,
            customPriorities: {
              for (final debt in activeDebts) debt.id: debt.customPriority,
            },
          ),
        );
    final currency = preferences?.currencyCode ?? 'USD';
    final subscription = ref.watch(subscriptionStateProvider).valueOrNull;

    return AppPage(
      title: 'Strategy simulator',
      child: activeDebts.isEmpty
          ? const EmptyStateView(
              title: 'Add debts to compare strategies',
              message: 'The simulator needs at least one active debt.',
              icon: Icons.auto_graph_outlined,
            )
          : ListView(
              children: [
                DropdownButtonFormField<StrategyType>(
                  initialValue: _strategy,
                  decoration: const InputDecoration(labelText: 'Strategy'),
                  items: StrategyType.values
                      .map(
                        (strategy) => DropdownMenuItem(
                          value: strategy,
                          child: Text(Formatters.strategyLabel(strategy)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _strategy = value ?? _strategy),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _budgetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monthly budget',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _extraController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Extra monthly payment',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _lumpSumController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'One-time lump sum',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debt-free date',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Formatters.date(result.payoffDate),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryMetric(
                              label: 'Months',
                              value: result.monthsToPayoff.toString(),
                            ),
                          ),
                          Expanded(
                            child: _SummaryMetric(
                              label: 'Interest paid',
                              value: Formatters.currency(
                                result.totalInterestPaid,
                                currencyCode: currency,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _SummaryMetric(
                              label: 'Saved vs baseline',
                              value: Formatters.currency(
                                result.totalInterestSaved,
                                currencyCode: currency,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, _) =>
                                  Text(value.toInt().toString()),
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            spots: result.schedule
                                .map(
                                  (month) => FlSpot(
                                    month.monthIndex.toDouble(),
                                    month.remainingBalance,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Payoff order',
                  trailing: FilledButton.tonal(
                    onPressed: () async {
                      final premium = subscription ?? SubscriptionState.free();
                      final hasAccess = ref
                          .read(premiumServiceProvider)
                          .guard(premium, PremiumFeature.scenarioSaving);
                      if (!hasAccess) {
                        if (context.mounted) {
                          context.push('/premium');
                        }
                        return;
                      }
                      await ref
                          .read(scenariosRepositoryProvider)
                          .saveScenario(
                            Scenario(
                              id: const Uuid().v4(),
                              strategyType: _strategy,
                              extraPayment: Parsers.parseMoney(
                                _extraController.text,
                              ),
                              budget: Parsers.parseMoney(
                                _budgetController.text,
                              ),
                              createdAt: DateTime.now(),
                              label:
                                  '${Formatters.strategyLabel(_strategy)} scenario',
                              baselineInterest: result.baselineInterest,
                              optimizedInterest: result.totalInterestPaid,
                              monthsToPayoff: result.monthsToPayoff,
                            ),
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Scenario saved')),
                        );
                      }
                    },
                    child: const Text('Save scenario'),
                  ),
                ),
                const SizedBox(height: 12),
                ...result.payoffOrder.map(
                  (debt) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(debt.title),
                        subtitle: Text(
                          '${Formatters.debtType(debt.type)} • ${Formatters.percent(debt.apr)}',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
