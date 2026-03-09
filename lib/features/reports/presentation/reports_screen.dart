import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/payment.dart';
import '../../../shared/models/strategy_models.dart';
import '../../../shared/models/subscription_state.dart';
import '../../../shared/models/user_preferences.dart';
import '../../../shared/providers/app_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entitlementRefreshProvider);
    final debts = ref.watch(allDebtsProvider);
    final payments = ref.watch(recentPaymentsProvider);
    final subscription = ref.watch(subscriptionStateProvider).valueOrNull;
    final preferences =
        ref.watch(userPreferencesProvider).valueOrNull ??
        UserPreferences.defaults();
    final currency = preferences.currencyCode;

    return AppPage(
      title: 'Reports',
      actions: [
        IconButton(
          onPressed: () async {
            final premium = subscription ?? SubscriptionState.free();
            final allowed = ref
                .read(premiumServiceProvider)
                .guard(premium, PremiumFeature.csvExport);
            if (!allowed) {
              if (context.mounted) {
                context.push('/premium');
              }
              return;
            }
            final file = await ref.read(exportCsvProvider)();
            await ref.read(csvExportServiceProvider).shareCsv(file.path);
          },
          icon: const Icon(Icons.ios_share_outlined),
        ),
      ],
      child: _buildBody(
        debts,
        payments,
        currency,
        preferences.defaultStrategy,
        ref,
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<List<Debt>> debts,
    AsyncValue<List<Payment>> payments,
    String currency,
    StrategyType defaultStrategy,
    WidgetRef ref,
  ) {
    if (debts is AsyncError<List<Debt>>) {
      return AppErrorState(message: debts.error.toString());
    }
    if (payments is AsyncError<List<Payment>>) {
      return AppErrorState(message: payments.error.toString());
    }
    if (debts is! AsyncData<List<Debt>> ||
        payments is! AsyncData<List<Payment>>) {
      return const LoadingPane(message: 'Loading reports...');
    }

    return _ReportsBody(
      debts: debts.value,
      payments: payments.value,
      currency: currency,
      defaultStrategy: defaultStrategy,
      ref: ref,
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody({
    required this.debts,
    required this.payments,
    required this.currency,
    required this.defaultStrategy,
    required this.ref,
  });

  final List<Debt> debts;
  final List<Payment> payments;
  final String currency;
  final StrategyType defaultStrategy;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (debts.isEmpty) {
      return const EmptyStateView(
        title: 'No reports yet',
        message: 'Reports appear after debts and payments are added.',
        icon: Icons.query_stats_outlined,
      );
    }

    final activeDebts = debts
        .where((debt) => debt.status == DebtStatus.active)
        .toList();
    final byType = <DebtType, double>{};
    for (final debt in activeDebts) {
      byType.update(
        debt.type,
        (value) => value + debt.currentBalance,
        ifAbsent: () => debt.currentBalance,
      );
    }
    final monthlyPayments = <int, double>{};
    for (final payment in payments) {
      monthlyPayments.update(
        payment.date.month,
        (value) => value + payment.amount,
        ifAbsent: () => payment.amount,
      );
    }

    final minimumBudget = activeDebts.fold<double>(
      0,
      (sum, debt) => sum + debt.minimumPayment,
    );
    final projection = ref
        .read(portfolioProjectionServiceProvider)
        .projectPortfolio(
          debts: activeDebts,
          request: StrategyRequest(
            strategyType: defaultStrategy,
            monthlyBudget: minimumBudget,
            extraMonthlyPayment: 0,
            startDate: DateTime.now(),
            lumpSum: 0,
            includeArchived: false,
            customPriorities: {
              for (final debt in activeDebts) debt.id: debt.customPriority,
            },
          ),
        );

    return ListView(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projection summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _SummaryLine(
                label: 'Projected debt-free',
                value: Formatters.date(projection.payoffDate),
              ),
              _SummaryLine(
                label: 'Projected interest',
                value: Formatters.currency(
                  projection.totalInterestPaid,
                  currencyCode: currency,
                ),
              ),
              _SummaryLine(
                label: 'Baseline savings',
                value: Formatters.currency(
                  projection.totalInterestSaved,
                  currencyCode: currency,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        Formatters.shortMonth(DateTime(2026, value.toInt())),
                      ),
                    ),
                  ),
                ),
                barGroups: monthlyPayments.entries
                    .map(
                      (entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [BarChartRodData(toY: entry.value)],
                      ),
                    )
                    .toList(),
              ),
            ),
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
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) =>
                          Text(value.toInt().toString()),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: projection.schedule
                        .map(
                          (month) => FlSpot(
                            month.monthIndex.toDouble(),
                            month.remainingBalance,
                          ),
                        )
                        .toList(),
                  ),
                  LineChartBarData(
                    isCurved: true,
                    spots: projection.schedule
                        .map(
                          (month) => FlSpot(
                            month.monthIndex.toDouble(),
                            month.totalInterest,
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
        AppCard(
          child: SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: byType.entries
                    .map(
                      (entry) => PieChartSectionData(
                        value: entry.value,
                        title: Formatters.debtType(entry.key),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _SummaryLine(
                label: 'Outstanding debt',
                value: Formatters.currency(
                  activeDebts.fold<double>(
                    0,
                    (sum, debt) => sum + debt.currentBalance,
                  ),
                  currencyCode: currency,
                ),
              ),
              _SummaryLine(
                label: 'Payments tracked',
                value: Formatters.currency(
                  payments.fold<double>(
                    0,
                    (sum, payment) => sum + payment.amount,
                  ),
                  currencyCode: currency,
                ),
              ),
              _SummaryLine(
                label: 'Projected monthly minimum',
                value: Formatters.currency(
                  projection.minimumRequiredPerCycle,
                  currencyCode: currency,
                ),
              ),
              _SummaryLine(
                label: 'Due dates this month',
                value: activeDebts
                    .where(
                      (debt) => debt.dueDate?.month == DateTime.now().month,
                    )
                    .length
                    .toString(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
