import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/monetization_widgets.dart';
import '../../../shared/models/ad_models.dart';
import '../../../shared/models/dashboard_snapshot.dart';
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
        heroTag: 'dashboard_scan_fab',
        onPressed: () => context.push('/scan'),
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scan'),
      ),
      child: snapshot.when(
        data: (data) => _DashboardContent(
          data: data,
          debts: debts,
          currency: currency,
          hideBalances: hideBalances,
        ),
        error: (error, _) => AppErrorState(message: error.toString()),
        loading: () => const LoadingPane(message: 'Loading your dashboard...'),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.data,
    required this.debts,
    required this.currency,
    required this.hideBalances,
  });

  final DashboardSnapshot data;
  final List<Debt> debts;
  final String currency;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    final activeDebts = debts.where((debt) => debt.isActive).toList();
    if (activeDebts.isEmpty) {
      return EmptyStateView(
        title: 'No debts yet',
        message:
            'Add a debt manually or import a statement to build your payoff plan.',
        icon: Icons.account_balance_wallet_outlined,
        action: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () => context.push('/debts/add'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add debt'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/scan'),
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text('Scan'),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        HeroFinanceCard(
          label: 'Total outstanding',
          value: SensitiveValueText(
            value: Formatters.currency(
              data.totalOutstandingDebt,
              currencyCode: currency,
            ),
            hide: hideBalances,
          ),
          subtitle: '${activeDebts.length} active debts',
          trailing: AppStatusBadge(
            label: data.interestSavedVsBaseline > 0
                ? '-${Formatters.currency(data.interestSavedVsBaseline, currencyCode: currency, obscure: hideBalances)}'
                : 'Private',
            color: AppColors.secondaryContainer,
            icon: Icons.trending_down_rounded,
          ),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: _paidProgress,
                minHeight: 8,
                color: AppColors.secondaryContainer,
                backgroundColor: Colors.white.withValues(alpha: 0.14),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Debt Destroyed',
                    value: Formatters.currency(
                      data.totalPaidSoFar,
                      currencyCode: currency,
                      obscure: hideBalances,
                    ),
                    textColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Monthly Minimums',
                    value: Formatters.currency(
                      data.monthlyMinimumTotal,
                      currencyCode: currency,
                      obscure: hideBalances,
                    ),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (data.mixedCurrency) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            color: AppColors.errorContainer,
            child: Text(
              'Mixed currencies detected. Aggregate cards use your selected display currency only.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppStatCard(
                label: 'Projected debt-free',
                icon: Icons.flag_outlined,
                value: Text(Formatters.date(data.projectedDebtFreeDate)),
                subtitle: 'Projected payoff',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppStatCard(
                label: 'Interest horizon',
                icon: Icons.percent_rounded,
                accentColor: AppColors.warning,
                value: SensitiveValueText(
                  value: Formatters.currency(
                    data.interestExpected,
                    currencyCode: currency,
                  ),
                  hide: hideBalances,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.add_rounded,
                label: 'Add Debt',
                onTap: () => context.push('/debts/add'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickAction(
                icon: Icons.document_scanner_outlined,
                label: 'Scan',
                color: AppColors.secondaryContainer,
                onTap: () => context.push('/scan'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickAction(
                icon: Icons.query_stats_outlined,
                label: 'Simulate',
                onTap: () => context.go('/strategy'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Debt Distribution'),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 210,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 48,
                    sections: _buildDebtDistribution(activeDebts),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: 'Next Payment',
          trailing: TextButton(
            onPressed: () => context.go('/debts'),
            child: const Text('See all'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (data.upcomingDueDebts.isEmpty)
          const AppCard(child: Text('No upcoming due dates.'))
        else
          ...data.upcomingDueDebts
              .take(3)
              .map(
                (debt) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _DueDebtCard(debt: debt, hideBalances: hideBalances),
                ),
              ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: 'Recent Activity',
          trailing: TextButton(
            onPressed: debts.isEmpty
                ? null
                : () => context.push('/debts/${debts.first.id}/payments'),
            child: const Text('History'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (data.recentPayments.isEmpty)
          const AppCard(
            child: Text('Payments you log or import will show here.'),
          )
        else
          ...data.recentPayments
              .take(5)
              .map(
                (payment) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    radius: AppRadius.lg,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondaryContainer
                            .withValues(alpha: 0.35),
                        child: const Icon(Icons.arrow_downward_rounded),
                      ),
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
        const PremiumAwareBannerAdSlot(placement: AdPlacement.dashboard),
      ],
    );
  }

  double get _paidProgress {
    final total = data.totalOutstandingDebt + data.totalPaidSoFar;
    if (total <= 0) {
      return 0;
    }
    return (data.totalPaidSoFar / total).clamp(0, 1).toDouble();
  }

  List<PieChartSectionData> _buildDebtDistribution(List<Debt> debts) {
    final palette = [
      AppColors.primaryContainer,
      AppColors.secondary,
      AppColors.tertiaryFixed,
      AppColors.warning,
      AppColors.primaryFixedDim,
    ];

    return debts.asMap().entries.map((entry) {
      final index = entry.key;
      final debt = entry.value;
      return PieChartSectionData(
        value: debt.currentBalance <= 0 ? 1 : debt.currentBalance,
        color: palette[index % palette.length],
        title:
            '${((debt.currentBalance / data.totalOutstandingDebt) * 100).clamp(0, 100).toStringAsFixed(0)}%',
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value, this.textColor});

  final String label;
  final String value;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: textColor?.withValues(alpha: 0.72)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return AppCard(
      onTap: onTap,
      radius: AppRadius.lg,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _DueDebtCard extends StatelessWidget {
  const _DueDebtCard({required this.debt, required this.hideBalances});

  final Debt debt;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    final overdue =
        debt.dueDate != null && debt.dueDate!.isBefore(DateTime.now());
    return AppCard(
      radius: AppRadius.lg,
      onTap: () => context.push('/debts/${debt.id}'),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: overdue
                  ? AppColors.errorContainer
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Icon(
              overdue
                  ? Icons.priority_high_rounded
                  : Icons.event_available_outlined,
              color: overdue ? AppColors.error : AppColors.secondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(debt.title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  Formatters.date(debt.dueDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SensitiveValueText(
            value: Formatters.currency(
              debt.currentBalance,
              currencyCode: debt.currency,
            ),
            hide: hideBalances,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
