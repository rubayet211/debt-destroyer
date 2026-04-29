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
    final payments = ref.watch(allPaymentsProvider);
    final selectedRange = ref.watch(reportsDateRangeProvider);
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
        selectedRange,
        currency,
        preferences.defaultStrategy,
        ref,
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<List<Debt>> debts,
    AsyncValue<List<Payment>> payments,
    DateTimeRange? selectedRange,
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
      selectedRange: selectedRange,
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
    required this.selectedRange,
    required this.currency,
    required this.defaultStrategy,
    required this.ref,
  });

  final List<Debt> debts;
  final List<Payment> payments;
  final DateTimeRange? selectedRange;
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
    final filteredPayments = filterPaymentsByDateRangeForReports(
      payments,
      selectedRange,
    );
    final byType = <DebtType, double>{};
    for (final debt in activeDebts) {
      byType.update(
        debt.type,
        (value) => value + debt.currentBalance,
        ifAbsent: () => debt.currentBalance,
      );
    }
    final monthlyPayments = buildMonthlyPaymentBucketsForReports(
      filteredPayments,
    );

    final projectionStart = DateTime.now();
    final minimumBudget = ref
        .read(portfolioProjectionServiceProvider)
        .minimumRequiredBudget(debts: activeDebts, asOf: projectionStart);
    final projection = ref
        .read(portfolioProjectionServiceProvider)
        .projectPortfolio(
          debts: activeDebts,
          request: StrategyRequest(
            strategyType: defaultStrategy,
            monthlyBudget: minimumBudget,
            extraMonthlyPayment: 0,
            startDate: projectionStart,
            lumpSum: 0,
            includeArchived: false,
            customPriorities: {
              for (final debt in activeDebts) debt.id: debt.customPriority,
            },
            allowUnderMinimumBudget: false,
          ),
        );

    return ListView(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Reporting range',
                trailing: selectedRange == null
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () {
                          ref.read(reportsDateRangeProvider.notifier).state =
                              null;
                        },
                        child: const Text('Reset'),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedRange == null
                    ? 'Full history'
                    : '${Formatters.date(selectedRange!.start)} - ${Formatters.date(selectedRange!.end)}',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: payments.isEmpty
                    ? null
                    : () async {
                        final dates =
                            payments.map((payment) => payment.date).toList()
                              ..sort((left, right) => left.compareTo(right));
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: dates.first,
                          lastDate: dates.last,
                          initialDateRange:
                              selectedRange ??
                              DateTimeRange(
                                start: dates.first,
                                end: dates.last,
                              ),
                        );
                        if (picked != null) {
                          ref.read(reportsDateRangeProvider.notifier).state =
                              picked;
                        }
                      },
                icon: const Icon(Icons.date_range_outlined),
                label: Text(
                  selectedRange == null
                      ? 'Choose date range'
                      : 'Change date range',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                      showTitles: monthlyPayments.isNotEmpty,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthlyPayments.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(monthlyPayments[index].label);
                      },
                    ),
                  ),
                ),
                barGroups: monthlyPayments
                    .map(
                      (entry) => BarChartGroupData(
                        x: entry.index,
                        barRods: [BarChartRodData(toY: entry.total)],
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
                  filteredPayments.fold<double>(
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

List<Payment> filterPaymentsByDateRangeForReports(
  List<Payment> payments,
  DateTimeRange? selectedRange,
) {
  if (selectedRange == null) {
    return [...payments]
      ..sort((left, right) => left.date.compareTo(right.date));
  }

  final start = DateTime(
    selectedRange.start.year,
    selectedRange.start.month,
    selectedRange.start.day,
  );
  final end = DateTime(
    selectedRange.end.year,
    selectedRange.end.month,
    selectedRange.end.day,
    23,
    59,
    59,
    999,
    999,
  );
  return payments
      .where(
        (payment) =>
            !payment.date.isBefore(start) && !payment.date.isAfter(end),
      )
      .toList()
    ..sort((left, right) => left.date.compareTo(right.date));
}

List<ReportsMonthlyPaymentBucket> buildMonthlyPaymentBucketsForReports(
  List<Payment> payments,
) {
  final totals = <DateTime, double>{};
  for (final payment in payments) {
    final month = DateTime(payment.date.year, payment.date.month);
    totals.update(
      month,
      (value) => value + payment.amount,
      ifAbsent: () => payment.amount,
    );
  }

  final months = totals.keys.toList()
    ..sort((left, right) => left.compareTo(right));
  return [
    for (var index = 0; index < months.length; index += 1)
      ReportsMonthlyPaymentBucket(
        index: index,
        month: months[index],
        total: totals[months[index]] ?? 0,
      ),
  ];
}

class ReportsMonthlyPaymentBucket {
  const ReportsMonthlyPaymentBucket({
    required this.index,
    required this.month,
    required this.total,
  });

  final int index;
  final DateTime month;
  final double total;

  String get label {
    final shortYear = (month.year % 100).toString().padLeft(2, '0');
    return '${Formatters.shortMonth(month)} $shortYear';
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
