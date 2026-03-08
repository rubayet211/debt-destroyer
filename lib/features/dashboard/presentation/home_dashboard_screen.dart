import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/providers/app_providers.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dashboardSnapshotProvider);
    final preferences = ref.watch(userPreferencesProvider).valueOrNull;
    final currency = preferences?.currencyCode ?? 'USD';
    final hideBalances = preferences?.hideBalances ?? false;
    final debts = ref.watch(debtsProvider).valueOrNull ?? const <Debt>[];

    return AppPage(
      title: 'Dashboard',
      actions: [
        IconButton(
          onPressed: () => context.push('/reports'),
          icon: const Icon(Icons.analytics_outlined),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scan'),
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scan'),
      ),
      child: snapshot.when(
        data: (data) => ListView(
          children: [
            if (debts.isEmpty)
              EmptyStateView(
                title: 'No debts yet',
                message:
                    'Add a debt manually or import a statement to build your payoff plan.',
                icon: Icons.account_balance_wallet_outlined,
                action: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () => context.push('/debts/add'),
                      child: const Text('Add debt'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push('/scan'),
                      child: const Text('Scan a document'),
                    ),
                  ],
                ),
              )
            else ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total outstanding',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SensitiveValueText(
                      value: Formatters.currency(
                        data.totalOutstandingDebt,
                        currencyCode: currency,
                      ),
                      hide: hideBalances,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            label: 'Total paid',
                            value: Formatters.currency(
                              data.totalPaidSoFar,
                              currencyCode: currency,
                              obscure: hideBalances,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _MetricTile(
                            label: 'Monthly minimums',
                            value: Formatters.currency(
                              data.monthlyMinimumTotal,
                              currencyCode: currency,
                              obscure: hideBalances,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (data.mixedCurrency) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Mixed currencies detected. Aggregate cards use your selected display currency only.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Projected debt-free'),
                          const SizedBox(height: 6),
                          Text(
                            Formatters.date(data.projectedDebtFreeDate),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Interest horizon'),
                          const SizedBox(height: 6),
                          SensitiveValueText(
                            value: Formatters.currency(
                              data.interestExpected,
                              currencyCode: currency,
                            ),
                            hide: hideBalances,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppCard(
                child: SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 42,
                      sections: _buildDebtDistribution(
                        debts.where((debt) => debt.isActive).toList(),
                        currency,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Upcoming due dates',
                trailing: TextButton(
                  onPressed: () => context.go('/debts'),
                  child: const Text('See all'),
                ),
              ),
              const SizedBox(height: 12),
              ...data.upcomingDueDebts.map(
                (debt) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(debt.title),
                      subtitle: Text(Formatters.date(debt.dueDate)),
                      trailing: SensitiveValueText(
                        value: Formatters.currency(
                          debt.currentBalance,
                          currencyCode: debt.currency,
                        ),
                        hide: hideBalances,
                      ),
                      onTap: () => context.push('/debts/${debt.id}'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Recent activity',
                trailing: TextButton(
                  onPressed: debts.isEmpty
                      ? null
                      : () => context.push('/debts/${debts.first.id}/payments'),
                  child: const Text('History'),
                ),
              ),
              const SizedBox(height: 12),
              if (data.recentPayments.isEmpty)
                const AppCard(
                  child: Text('Payments you log or import will show here.'),
                )
              else
                ...data.recentPayments.map(
                  (payment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.arrow_downward_rounded),
                        title: Text(
                          Formatters.currency(
                            payment.amount,
                            currencyCode: currency,
                          ),
                        ),
                        subtitle: Text(Formatters.date(payment.date)),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
        error: (error, _) => AppErrorState(message: error.toString()),
        loading: () => const LoadingPane(message: 'Loading your dashboard...'),
      ),
    );
  }

  List<PieChartSectionData> _buildDebtDistribution(
    List<Debt> debts,
    String currency,
  ) {
    if (debts.isEmpty) {
      return [PieChartSectionData(value: 1, title: 'No debt')];
    }

    final palette = [
      const Color(0xFF102A43),
      const Color(0xFF2BB673),
      const Color(0xFFF08C00),
      const Color(0xFFD64545),
      const Color(0xFF3A506B),
    ];

    return debts.asMap().entries.map((entry) {
      final index = entry.key;
      final debt = entry.value;
      return PieChartSectionData(
        value: debt.currentBalance,
        color: palette[index % palette.length],
        title: debt.title,
        radius: 72,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

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
