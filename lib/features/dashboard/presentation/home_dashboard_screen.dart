import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/monetization_widgets.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/ad_models.dart';
import '../../../shared/models/dashboard_snapshot.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/payment.dart';
import '../../../shared/providers/app_providers.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dashboardSnapshotProvider);
    final preferences = ref.watch(userPreferencesProvider).valueOrNull;
    final currency = preferences?.currencyCode ?? 'USD';
    final hideBalances = preferences?.hideBalances ?? false;
    final activeStrategy =
        preferences?.defaultStrategy ?? StrategyType.avalanche;
    final debts = ref.watch(debtsProvider).valueOrNull ?? const <Debt>[];

    return AppPage(
      title: 'Dashboard',
      actions: [
        IconButton(
          tooltip: 'Reports',
          onPressed: () => context.push('/reports'),
          icon: const Icon(Icons.analytics_outlined),
        ),
      ],
      child: snapshot.when(
        data: (data) => _DashboardContent(
          data: data,
          debts: debts,
          currency: currency,
          hideBalances: hideBalances,
          activeStrategy: activeStrategy,
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
    required this.activeStrategy,
  });

  final DashboardSnapshot data;
  final List<Debt> debts;
  final String currency;
  final bool hideBalances;
  final StrategyType activeStrategy;

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

    final progress = _paidProgress;
    final paymentDebtId =
        (data.upcomingDueDebts.isNotEmpty
                ? data.upcomingDueDebts.first
                : activeDebts.first)
            .id;

    return ListView(
      children: [
        _DebtFreeHero(
          debtFreeDate: data.projectedDebtFreeDate,
          progress: progress,
          message: _progressMessage(progress),
        ),
        if (data.mixedCurrency) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            color: AppColors.errorContainer,
            child: Text(
              'Mixed currencies detected. Totals use your selected display currency only.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _DebtBalanceCard(
          data: data,
          currency: currency,
          hideBalances: hideBalances,
          progress: progress,
        ),
        const SizedBox(height: AppSpacing.md),
        _StrategyCard(strategy: activeStrategy),
        const SizedBox(height: AppSpacing.lg),
        _QuickActionsGrid(paymentDebtId: paymentDebtId),
        const SizedBox(height: AppSpacing.lg),
        _DashboardMetricRow(
          children: [
            AppStatCard(
              label: 'Interest saved',
              icon: Icons.savings_outlined,
              accentColor: AppColors.secondary,
              value: SensitiveValueText(
                value: Formatters.currency(
                  data.interestSavedVsBaseline,
                  currencyCode: currency,
                ),
                hide: hideBalances,
              ),
              subtitle: 'Compared with minimum payments only',
            ),
            AppStatCard(
              label: 'Total paid',
              icon: Icons.check_circle_outline_rounded,
              accentColor: AppColors.tertiaryFixed,
              value: SensitiveValueText(
                value: Formatters.currency(
                  data.totalPaidSoFar,
                  currencyCode: currency,
                ),
                hide: hideBalances,
              ),
              subtitle: 'Debt already reduced',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _UpcomingPaymentsSection(
          debts: data.upcomingDueDebts,
          hideBalances: hideBalances,
        ),
        const SizedBox(height: AppSpacing.lg),
        _RecentActivitySection(
          payments: data.recentPayments,
          debts: debts,
          currency: currency,
          hideBalances: hideBalances,
        ),
        const SizedBox(height: AppSpacing.lg),
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

  String _progressMessage(double progress) {
    final percent = (progress * 100).round();
    if (percent <= 0) {
      return 'Your plan is ready. Log your first payment to start tracking progress.';
    }
    if (percent >= 100) {
      return 'Debt free. Keep your plan close for the next goal.';
    }
    return "You're $percent% of the way there.";
  }
}

class _DebtFreeHero extends StatelessWidget {
  const _DebtFreeHero({
    required this.debtFreeDate,
    required this.progress,
    required this.message,
  });

  final DateTime? debtFreeDate;
  final double progress;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primaryContainer,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debt-Free Date',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  Formatters.date(debtFreeDate),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          _CircularProgressBadge(progress: progress),
        ],
      ),
    );
  }
}

class _CircularProgressBadge extends StatelessWidget {
  const _CircularProgressBadge({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: AppColors.secondaryContainer,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.paymentDebtId});

  final String paymentDebtId;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _DashboardAction(
        icon: Icons.payments_outlined,
        label: 'Log a Payment',
        onTap: () => context.push('/debts/$paymentDebtId/add-payment'),
      ),
      _DashboardAction(
        icon: Icons.add_rounded,
        label: 'Add New Debt',
        onTap: () => context.push('/debts/add'),
      ),
      _DashboardAction(
        icon: Icons.document_scanner_outlined,
        label: 'Scan Document',
        onTap: () => context.push('/scan'),
      ),
      _DashboardAction(
        icon: Icons.query_stats_outlined,
        label: 'View Full Plan',
        onTap: () => context.go('/strategy'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 4 : 2;
        final gap = AppSpacing.sm * (columns - 1);
        final width = (constraints.maxWidth - gap) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final action in actions)
              SizedBox(
                width: width,
                child: _QuickAction(action: action),
              ),
          ],
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: action.onTap,
      radius: AppRadius.lg,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(action.icon, color: scheme.primary, size: 21),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            action.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _DebtBalanceCard extends StatelessWidget {
  const _DebtBalanceCard({
    required this.data,
    required this.currency,
    required this.hideBalances,
    required this.progress,
  });

  final DashboardSnapshot data;
  final String currency;
  final bool hideBalances;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final remainingPercent = ((1 - progress) * 100).round();
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total debt',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '$remainingPercent% remaining',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SensitiveValueText(
            value: Formatters.currency(
              data.totalOutstandingDebt,
              currencyCode: currency,
            ),
            hide: hideBalances,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: AppColors.secondary,
              backgroundColor: AppColors.surfaceContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Progress moves toward zero as balances come down.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DashboardMetricRow extends StatelessWidget {
  const _DashboardMetricRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              for (final child in children) ...[
                child,
                if (child != children.last)
                  const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (final child in children) ...[
              Expanded(child: child),
              if (child != children.last) const SizedBox(width: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }
}

class _StrategyCard extends StatelessWidget {
  const _StrategyCard({required this.strategy});

  final StrategyType strategy;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: const Icon(Icons.route_outlined, color: AppColors.secondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
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
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/strategy/compare'),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _UpcomingPaymentsSection extends StatelessWidget {
  const _UpcomingPaymentsSection({
    required this.debts,
    required this.hideBalances,
  });

  final List<Debt> debts;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Upcoming payments',
          subtitle: 'Due in the next 14 days',
          trailing: TextButton(
            onPressed: () => context.go('/debts'),
            child: const Text('See all'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (debts.isEmpty)
          const AppCard(child: Text('No payments due in the next 14 days.'))
        else
          ...debts.map(
            (debt) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _DueDebtCard(debt: debt, hideBalances: hideBalances),
            ),
          ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({
    required this.payments,
    required this.debts,
    required this.currency,
    required this.hideBalances,
  });

  final List<Payment> payments;
  final List<Debt> debts;
  final String currency;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent activity',
          trailing: TextButton(
            onPressed: debts.isEmpty
                ? null
                : () => context.push('/debts/${debts.first.id}/payments'),
            child: const Text('History'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (payments.isEmpty)
          const AppCard(child: Text('Payments you log will show here.'))
        else
          ...payments
              .take(3)
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
                      title: SensitiveValueText(
                        value: Formatters.currency(
                          payment.amount,
                          currencyCode: currency,
                        ),
                        hide: hideBalances,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      subtitle: Text(Formatters.date(payment.date)),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class _DueDebtCard extends StatelessWidget {
  const _DueDebtCard({required this.debt, required this.hideBalances});

  final Debt debt;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.lg,
      onTap: () => context.push('/debts/${debt.id}'),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              color: AppColors.secondary,
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
              debt.minimumPayment,
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
