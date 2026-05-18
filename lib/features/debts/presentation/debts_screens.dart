import 'dart:math';

import 'package:flutter/material.dart';
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
import '../../../shared/models/ad_models.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/debt_financial_terms.dart';
import '../../../shared/models/payment.dart';
import '../../../shared/models/user_preferences.dart';
import '../../../shared/providers/app_providers.dart';

class DebtsListScreen extends ConsumerStatefulWidget {
  const DebtsListScreen({super.key});

  @override
  ConsumerState<DebtsListScreen> createState() => _DebtsListScreenState();
}

class _DebtsListScreenState extends ConsumerState<DebtsListScreen> {
  String _query = '';
  DebtStatus? _status;
  DebtType? _type;
  String _sort = 'updated';

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(allDebtsProvider);
    final hideBalances =
        ref.watch(userPreferencesProvider).valueOrNull?.hideBalances ?? false;

    return AppPage(
      title: 'Debts',
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'debts_add_fab',
        onPressed: () => context.push('/debts/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add debt'),
      ),
      child: debts.when(
        data: (items) {
          final filtered = _sortDebts(_filterDebts(items));
          if (items.isEmpty) {
            return EmptyStateView(
              title: 'No debts yet',
              message: 'Add your first debt to start building a payoff plan.',
              icon: Icons.account_balance_wallet_outlined,
              action: FilledButton.icon(
                onPressed: () => context.push('/debts/add'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add debt'),
              ),
            );
          }
          if (filtered.isEmpty) {
            return EmptyStateView(
              title: 'No matching debts',
              message: 'Try clearing filters or add a new debt.',
              icon: Icons.filter_alt_off_outlined,
              action: FilledButton(
                onPressed: () => context.push('/debts/add'),
                child: const Text('Add debt'),
              ),
            );
          }
          return Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search debts or creditors',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) =>
                    setState(() => _query = value.toLowerCase()),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ActionChip(
                      label: Text('Sort: ${_sortLabel(_sort)}'),
                      avatar: const Icon(Icons.sort, size: 16),
                      onPressed: () => _showSortOptions(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: Text('Status: ${_status?.name ?? "All"}'),
                      onPressed: () => _showStatusOptions(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: Text(
                        'Type: ${_type == null ? "All" : Formatters.debtType(_type!)}',
                      ),
                      onPressed: () => _showTypeOptions(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: ListView.separated(
                    key: ValueKey(
                      '${filtered.length}-$_query-$_sort-$_status-$_type',
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final debt = filtered[index];
                      return _DebtListCard(
                        debt: debt,
                        hideBalances: hideBalances,
                        onTap: () => context.push('/debts/${debt.id}'),
                      );
                    },
                  ),
                ),
              ),
              const PremiumAwareBannerAdSlot(placement: AdPlacement.debtsList),
            ],
          );
        },
        error: (error, _) => AppErrorState(message: error.toString()),
        loading: () => const LoadingPane(message: 'Loading debts...'),
      ),
    );
  }

  String _sortLabel(String sort) {
    switch (sort) {
      case 'name':
        return 'Name';
      case 'balance':
        return 'Balance';
      case 'apr':
        return 'APR';
      case 'due':
        return 'Due date';
      case 'snowball':
        return 'Snowball';
      case 'avalanche':
        return 'Avalanche';
      case 'custom':
        return 'Custom priority';
      default:
        return 'Recently updated';
    }
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sort by',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...[
            'updated',
            'name',
            'balance',
            'apr',
            'due',
            'snowball',
            'avalanche',
            'custom',
          ].map(
            (s) => ListTile(
              title: Text(_sortLabel(s)),
              trailing: _sort == s
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                setState(() => _sort = s);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Filter by Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('All statuses'),
            trailing: _status == null
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              setState(() => _status = null);
              Navigator.pop(context);
            },
          ),
          ...DebtStatus.values.map(
            (s) => ListTile(
              title: Text(s.name),
              trailing: _status == s
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                setState(() => _status = s);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTypeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Filter by Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('All types'),
            trailing: _type == null
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              setState(() => _type = null);
              Navigator.pop(context);
            },
          ),
          ...DebtType.values.map(
            (t) => ListTile(
              title: Text(Formatters.debtType(t)),
              trailing: _type == t
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                setState(() => _type = t);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Debt> _filterDebts(List<Debt> items) {
    return items.where((debt) {
      final queryMatches =
          _query.isEmpty ||
          debt.title.toLowerCase().contains(_query) ||
          debt.creditorName.toLowerCase().contains(_query);
      final statusMatches = _status == null || debt.status == _status;
      final typeMatches = _type == null || debt.type == _type;
      return queryMatches && statusMatches && typeMatches;
    }).toList();
  }

  List<Debt> _sortDebts(List<Debt> items) {
    final debts = [...items];
    switch (_sort) {
      case 'name':
        debts.sort((a, b) => a.title.compareTo(b.title));
      case 'balance':
        debts.sort((a, b) => b.currentBalance.compareTo(a.currentBalance));
      case 'apr':
        debts.sort((a, b) => b.apr.compareTo(a.apr));
      case 'due':
        debts.sort(
          (a, b) => (a.dueDate ?? DateTime(2999)).compareTo(
            b.dueDate ?? DateTime(2999),
          ),
        );
      case 'snowball':
        debts.sort((a, b) => a.currentBalance.compareTo(b.currentBalance));
      case 'avalanche':
        debts.sort((a, b) => b.apr.compareTo(a.apr));
      case 'custom':
        debts.sort((a, b) => a.customPriority.compareTo(b.customPriority));
      default:
        debts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return debts;
  }
}

class _DebtListCard extends StatelessWidget {
  const _DebtListCard({
    required this.debt,
    required this.hideBalances,
    required this.onTap,
  });

  final Debt debt;
  final bool hideBalances;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = debt.originalBalance <= 0
        ? 0.0
        : (1 - (debt.currentBalance / debt.originalBalance))
              .clamp(0, 1)
              .toDouble();
    final overdue =
        debt.dueDate != null &&
        debt.dueDate!.isBefore(DateTime.now()) &&
        debt.status == DebtStatus.active;
    final badgeColor = overdue
        ? AppColors.error
        : debt.status == DebtStatus.paidOff
        ? AppColors.secondary
        : AppColors.secondary;
    final badgeLabel = overdue
        ? 'Overdue'
        : debt.status == DebtStatus.paidOff
        ? 'Paid off'
        : 'On track';

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: overdue
          ? AppColors.error.withValues(alpha: 0.75)
          : Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${debt.creditorName} • ${Formatters.debtType(debt.type)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SensitiveValueText(
                    value: Formatters.currency(
                      debt.currentBalance,
                      currencyCode: debt.currency,
                    ),
                    hide: hideBalances,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppStatusBadge(
                    label: badgeLabel,
                    color: badgeColor,
                    icon: overdue
                        ? Icons.priority_high_rounded
                        : Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text('Progress', style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              color: AppColors.secondary,
              backgroundColor: AppColors.surfaceHigh,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _CompactDebtMeta(
                  label: 'APR',
                  value: Formatters.percent(debt.apr),
                ),
              ),
              Expanded(
                child: _CompactDebtMeta(
                  label: 'Minimum',
                  value: Formatters.currency(
                    debt.minimumPayment,
                    currencyCode: debt.currency,
                    obscure: hideBalances,
                  ),
                ),
              ),
              Expanded(
                child: _CompactDebtMeta(
                  label: 'Due',
                  value: Formatters.date(debt.dueDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactDebtMeta extends StatelessWidget {
  const _CompactDebtMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class DebtDetailsScreen extends ConsumerWidget {
  const DebtDetailsScreen({super.key, required this.debtId});

  final String debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debt = ref.watch(debtProvider(debtId));
    final payments = ref.watch(paymentsByDebtProvider(debtId));
    final documents = ref.watch(documentsByDebtProvider(debtId));
    final hideBalances =
        ref.watch(userPreferencesProvider).valueOrNull?.hideBalances ?? false;

    return AppPage(
      title: 'Debt details',
      actions: [
        IconButton(
          onPressed: () => context.push('/debts/$debtId/edit'),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'debt_details_add_payment_$debtId',
        onPressed: () => context.push('/debts/$debtId/add-payment'),
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Add payment'),
      ),
      child: debt.when(
        data: (item) {
          if (item == null) {
            return const AppErrorState(message: 'Debt not found.');
          }
          final progress = item.originalBalance <= 0
              ? 0.0
              : (1 - (item.currentBalance / item.originalBalance))
                    .clamp(0, 1)
                    .toDouble();
          return ListView(
            children: [
              HeroFinanceCard(
                label: item.creditorName,
                value: SensitiveValueText(
                  value: Formatters.currency(
                    item.currentBalance,
                    currencyCode: item.currency,
                  ),
                  hide: hideBalances,
                ),
                subtitle: item.title,
                trailing: AppStatusBadge(
                  label: item.status == DebtStatus.paidOff
                      ? 'Paid off'
                      : 'Active',
                  color: item.status == DebtStatus.paidOff
                      ? AppColors.secondaryContainer
                      : AppColors.tertiaryFixed,
                  icon: Icons.receipt_long_outlined,
                ),
                children: [
                  Row(
                    children: [
                      Text(
                        'Payoff Progress',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: AppColors.secondaryContainer,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppStatCard(
                      label: 'APR',
                      icon: Icons.percent_rounded,
                      value: Text(Formatters.percent(item.apr)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppStatCard(
                      label: 'Min Pay',
                      icon: Icons.payments_outlined,
                      value: Text(
                        Formatters.currency(
                          item.minimumPayment,
                          currencyCode: item.currency,
                          obscure: hideBalances,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppStatCard(
                      label: 'Due Date',
                      icon: Icons.event_outlined,
                      accentColor: AppColors.error,
                      value: Text(Formatters.date(item.dueDate)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Reminders & notes'),
                    const SizedBox(height: 12),
                    Text(item.notes.isEmpty ? 'No notes yet.' : item.notes),
                    const SizedBox(height: 12),
                    Text('Reminders: ${item.remindersEnabled ? 'On' : 'Off'}'),
                  ],
                ),
              ),
              if (item.financialTerms.hasAdvancedTerms) ...[
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Projection terms'),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Compounding',
                        value: _compoundingLabel(
                          item.financialTerms.interestCompounding,
                        ),
                      ),
                      _SummaryRow(
                        label: 'Minimum rule',
                        value: _minimumRuleLabel(
                          item.financialTerms.minimumPaymentRule,
                        ),
                      ),
                      if (item.financialTerms.minimumPaymentPercent != null)
                        _SummaryRow(
                          label: 'Minimum %',
                          value: Formatters.percent(
                            item.financialTerms.minimumPaymentPercent!,
                          ),
                        ),
                      if (item.financialTerms.promoApr != null)
                        _SummaryRow(
                          label: 'Promo APR',
                          value: item.financialTerms.promoEndsOn == null
                              ? '${Formatters.percent(item.financialTerms.promoApr!)} ongoing'
                              : '${Formatters.percent(item.financialTerms.promoApr!)} until ${Formatters.date(item.financialTerms.promoEndsOn)}',
                        ),
                      if (item.financialTerms.monthlyFee > 0)
                        _SummaryRow(
                          label: 'Monthly fee',
                          value: Formatters.currency(
                            item.financialTerms.monthlyFee,
                            currencyCode: item.currency,
                          ),
                        ),
                      if (item.financialTerms.lateFee > 0)
                        _SummaryRow(
                          label: 'Late fee',
                          value:
                              '${Formatters.currency(item.financialTerms.lateFee, currencyCode: item.currency)} after ${item.financialTerms.lateFeeGraceDays} grace days',
                        ),
                      if (item.financialTerms.penaltyApr != null)
                        _SummaryRow(
                          label: 'Penalty APR',
                          value: Formatters.percent(
                            item.financialTerms.penaltyApr!,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Recent payments',
                trailing: TextButton(
                  onPressed: () => context.push('/debts/$debtId/payments'),
                  child: const Text('View all'),
                ),
              ),
              const SizedBox(height: 12),
              payments.when(
                data: (items) => items.isEmpty
                    ? const AppCard(child: Text('No payments logged yet.'))
                    : Column(
                        children: items.take(3).map((payment) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  Formatters.currency(
                                    payment.amount,
                                    currencyCode: item.currency,
                                  ),
                                ),
                                subtitle: Text(
                                  '${Formatters.date(payment.date)} • ${payment.sourceType.name}',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                error: (error, _) => AppErrorState(message: error.toString()),
                loading: () => const LoadingPane(),
              ),
              const SizedBox(height: 16),
              SectionHeader(title: 'Source documents'),
              const SizedBox(height: 12),
              documents.when(
                data: (items) => items.isEmpty
                    ? const AppCard(child: Text('No linked imports yet.'))
                    : Column(
                        children: items.map((doc) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(doc.mimeType),
                                subtitle: Text(
                                  doc.retentionExpiresAt == null
                                      ? '${Formatters.date(doc.createdAt)} • Manual retention'
                                      : '${Formatters.date(doc.createdAt)} • Purges ${Formatters.date(doc.retentionExpiresAt)}',
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    await ref
                                        .read(documentsRepositoryProvider)
                                        .purgeDocument(doc.id);
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                error: (error, _) => AppErrorState(message: error.toString()),
                loading: () => const LoadingPane(),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: () => item.status == DebtStatus.archived
                        ? ref.read(debtsRepositoryProvider).restoreDebt(item.id)
                        : ref
                              .read(debtsRepositoryProvider)
                              .archiveDebt(item.id),
                    child: Text(
                      item.status == DebtStatus.archived
                          ? 'Restore'
                          : 'Archive',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: item.status == DebtStatus.paidOff
                        ? null
                        : () => ref
                              .read(debtsRepositoryProvider)
                              .markPaidOff(item.id),
                    child: const Text('Mark paid off'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(debtsRepositoryProvider)
                          .deleteDebt(item.id);
                      if (context.mounted) {
                        context.pop();
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          );
        },
        error: (error, _) => AppErrorState(message: error.toString()),
        loading: () => const LoadingPane(message: 'Loading debt...'),
      ),
    );
  }
}

class AddEditDebtScreen extends ConsumerStatefulWidget {
  const AddEditDebtScreen({super.key, this.initialDebt});

  final Debt? initialDebt;

  @override
  ConsumerState<AddEditDebtScreen> createState() => _AddEditDebtScreenState();
}

class EditDebtLoaderScreen extends ConsumerWidget {
  const EditDebtLoaderScreen({super.key, required this.debtId});

  final String debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debt = ref.watch(debtProvider(debtId));
    return debt.when(
      data: (item) => AddEditDebtScreen(initialDebt: item),
      error: (error, _) => AppPage(
        title: 'Edit debt',
        child: AppErrorState(message: error.toString()),
      ),
      loading: () => const AppPage(title: 'Edit debt', child: LoadingPane()),
    );
  }
}

class _DebtFormProgress extends StatelessWidget {
  const _DebtFormProgress();

  @override
  Widget build(BuildContext context) {
    final steps = ['Basic Info', 'Balance', 'Schedule'];
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 28,
          right: 28,
          top: 15,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var index = 0; index < steps.length; index++)
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? Theme.of(context).colorScheme.secondary
                          : AppColors.surfaceHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: index == 0
                            ? Theme.of(context).colorScheme.onSecondary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    steps[index],
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _AddEditDebtScreenState extends ConsumerState<AddEditDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _creditor;
  late final TextEditingController _originalBalance;
  late final TextEditingController _currentBalance;
  late final TextEditingController _apr;
  late final TextEditingController _minimumPayment;
  late final TextEditingController _notes;
  late final TextEditingController _minimumPercent;
  late final TextEditingController _statementDay;
  late final TextEditingController _promoApr;
  late final TextEditingController _monthlyFee;
  late final TextEditingController _lateFee;
  late final TextEditingController _lateFeeGraceDays;
  late final TextEditingController _penaltyApr;
  DebtType _type = DebtType.creditCard;
  PaymentFrequency _frequency = PaymentFrequency.monthly;
  DebtStatus _status = DebtStatus.active;
  bool _reminders = true;
  DateTime? _dueDate;
  DateTime? _promoEndsOn;
  InterestCompounding _interestCompounding =
      InterestCompounding.monthlyCompound;
  MinimumPaymentRule _minimumPaymentRule = MinimumPaymentRule.fixedAmount;

  @override
  void initState() {
    super.initState();
    final debt = widget.initialDebt;
    _title = TextEditingController(text: debt?.title ?? '');
    _creditor = TextEditingController(text: debt?.creditorName ?? '');
    _originalBalance = TextEditingController(
      text: debt?.originalBalance.toString() ?? '',
    );
    _currentBalance = TextEditingController(
      text: debt?.currentBalance.toString() ?? '',
    );
    _apr = TextEditingController(text: debt?.apr.toString() ?? '');
    _minimumPayment = TextEditingController(
      text: debt?.minimumPayment.toString() ?? '',
    );
    _notes = TextEditingController(text: debt?.notes ?? '');
    _minimumPercent = TextEditingController(
      text: debt?.financialTerms.minimumPaymentPercent?.toString() ?? '',
    );
    _statementDay = TextEditingController(
      text: debt?.financialTerms.statementDayOfMonth?.toString() ?? '',
    );
    _promoApr = TextEditingController(
      text: debt?.financialTerms.promoApr?.toString() ?? '',
    );
    _monthlyFee = TextEditingController(
      text: debt?.financialTerms.monthlyFee.toString() ?? '0',
    );
    _lateFee = TextEditingController(
      text: debt?.financialTerms.lateFee.toString() ?? '0',
    );
    _lateFeeGraceDays = TextEditingController(
      text: debt?.financialTerms.lateFeeGraceDays.toString() ?? '0',
    );
    _penaltyApr = TextEditingController(
      text: debt?.financialTerms.penaltyApr?.toString() ?? '',
    );
    _type = debt?.type ?? DebtType.creditCard;
    _frequency = debt?.paymentFrequency ?? PaymentFrequency.monthly;
    _status = debt?.status ?? DebtStatus.active;
    _reminders = debt?.remindersEnabled ?? true;
    _dueDate = debt?.dueDate;
    _promoEndsOn = debt?.financialTerms.promoEndsOn;
    _interestCompounding =
        debt?.financialTerms.interestCompounding ??
        InterestCompounding.monthlyCompound;
    _minimumPaymentRule =
        debt?.financialTerms.minimumPaymentRule ??
        MinimumPaymentRule.fixedAmount;
  }

  @override
  void dispose() {
    _title.dispose();
    _creditor.dispose();
    _originalBalance.dispose();
    _currentBalance.dispose();
    _apr.dispose();
    _minimumPayment.dispose();
    _notes.dispose();
    _minimumPercent.dispose();
    _statementDay.dispose();
    _promoApr.dispose();
    _monthlyFee.dispose();
    _lateFee.dispose();
    _lateFeeGraceDays.dispose();
    _penaltyApr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences =
        ref.watch(userPreferencesProvider).valueOrNull ??
        UserPreferences.defaults();
    return AppPage(
      title: widget.initialDebt == null ? 'Add debt' : 'Edit debt',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const _DebtFormProgress(),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(
              title: 'Basic Info',
              subtitle: 'Name the account and choose how it should be grouped.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Debt title'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _creditor,
              decoration: const InputDecoration(labelText: 'Creditor'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DebtType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Debt type'),
              items: DebtType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(Formatters.debtType(type)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: 12),
            const SectionHeader(
              title: 'Balance & Rates',
              subtitle: 'Use the latest statement numbers for projections.',
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _originalBalance,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText:
                          'Original balance (${preferences.currencyCode})',
                    ),
                    validator: (value) => (Parsers.parseMoney(value ?? '') <= 0)
                        ? 'Enter a value'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _currentBalance,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Current balance',
                    ),
                    validator: (value) => (Parsers.parseMoney(value ?? '') < 0)
                        ? 'Invalid'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _apr,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'APR %'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _minimumPayment,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Minimum payment',
                    ),
                    validator: (value) => (Parsers.parseMoney(value ?? '') < 0)
                        ? 'Invalid'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SectionHeader(
              title: 'Schedule',
              subtitle:
                  'Due dates and reminder settings stay local to this device.',
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<PaymentFrequency>(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'Payment frequency'),
              items: PaymentFrequency.values
                  .map(
                    (frequency) => DropdownMenuItem(
                      value: frequency,
                      child: Text(Formatters.paymentFrequency(frequency)),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _frequency = value ?? _frequency),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _dueDate == null
                    ? 'Choose due date'
                    : Formatters.date(_dueDate),
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  initialDate: _dueDate ?? DateTime.now(),
                );
                if (selected != null) {
                  setState(() => _dueDate = selected);
                }
              },
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due date reminders'),
              value: _reminders,
              onChanged: (value) => setState(() => _reminders = value),
            ),
            DropdownButtonFormField<DebtStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: DebtStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: AppSpacing.md),
                title: const Text('Advanced payoff terms'),
                subtitle: const Text(
                  'Optional promo APR, fees, and payment rules for better projections.',
                ),
                children: [
                  DropdownButtonFormField<InterestCompounding>(
                    initialValue: _interestCompounding,
                    decoration: const InputDecoration(
                      labelText: 'Interest compounding',
                    ),
                    items: InterestCompounding.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(_interestCompoundingLabel(value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(
                      () =>
                          _interestCompounding = value ?? _interestCompounding,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MinimumPaymentRule>(
                    initialValue: _minimumPaymentRule,
                    decoration: const InputDecoration(
                      labelText: 'Minimum payment rule',
                    ),
                    items: MinimumPaymentRule.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(_minimumPaymentRuleLabel(value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(
                      () => _minimumPaymentRule = value ?? _minimumPaymentRule,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minimumPercent,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Minimum % of balance',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _statementDay,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Statement day',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _promoApr,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Promo APR %',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _promoEndsOn == null
                                ? 'Promo end date'
                                : Formatters.date(_promoEndsOn),
                          ),
                          trailing: const Icon(Icons.event_outlined),
                          onTap: () async {
                            final selected = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 3650),
                              ),
                              initialDate: _promoEndsOn ?? DateTime.now(),
                            );
                            if (selected != null) {
                              setState(() => _promoEndsOn = selected);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _monthlyFee,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Monthly fee',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lateFee,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Late fee',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _lateFeeGraceDays,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Late fee grace days',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _penaltyApr,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Penalty APR %',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => _save(context, preferences),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                widget.initialDebt == null ? 'Save debt' : 'Update debt',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, UserPreferences preferences) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final id = widget.initialDebt?.id ?? const Uuid().v4();
    final financialTerms = DebtFinancialTerms(
      interestCompounding: _interestCompounding,
      statementDayOfMonth: _validatedStatementDay(_statementDay.text),
      minimumPaymentRule: _minimumPaymentRule,
      minimumPaymentPercent: _boundedPercent(_minimumPercent.text),
      promoApr: _nonNegativeNullableMoney(_promoApr.text),
      promoEndsOn: _promoEndsOn,
      monthlyFee: _nonNegativeMoney(_monthlyFee.text),
      lateFee: _nonNegativeMoney(_lateFee.text),
      lateFeeGraceDays: _nonNegativeInt(_lateFeeGraceDays.text),
      penaltyApr: _boundedPercent(_penaltyApr.text),
    );
    final debt = Debt(
      id: id,
      title: _title.text.trim(),
      creditorName: _creditor.text.trim(),
      type: _type,
      currency: preferences.currencyCode,
      originalBalance: Parsers.parseMoney(_originalBalance.text),
      currentBalance: Parsers.parseMoney(
        _currentBalance.text,
      ).clamp(0, double.infinity),
      apr: Parsers.parseMoney(_apr.text),
      minimumPayment: Parsers.parseMoney(_minimumPayment.text),
      dueDate: _dueDate,
      paymentFrequency: _frequency,
      createdAt: widget.initialDebt?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      notes: _notes.text.trim(),
      tags: const [],
      status: _status,
      remindersEnabled: _reminders,
      customPriority: widget.initialDebt?.customPriority ?? 99,
      financialTerms: financialTerms,
    );

    await ref.read(debtsRepositoryProvider).saveDebt(debt);
    if (context.mounted) {
      context.pop();
    }
  }

  double? _nullableMoney(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return Parsers.parseMoney(trimmed);
  }

  double _nonNegativeMoney(String raw) {
    return Parsers.parseMoney(raw).clamp(0, double.infinity).toDouble();
  }

  double? _nonNegativeNullableMoney(String raw) {
    final value = _nullableMoney(raw);
    if (value == null) {
      return null;
    }
    return value.clamp(0, double.infinity).toDouble();
  }

  double? _boundedPercent(String raw) {
    final value = _nullableMoney(raw);
    if (value == null) {
      return null;
    }
    return value.clamp(0, 100).toDouble();
  }

  int _nonNegativeInt(String raw) {
    final parsed = int.tryParse(raw.trim()) ?? 0;
    return max(0, parsed);
  }

  int? _validatedStatementDay(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 1 || parsed > 31) {
      return null;
    }
    return parsed;
  }

  String _interestCompoundingLabel(InterestCompounding value) {
    switch (value) {
      case InterestCompounding.none:
        return 'No interest';
      case InterestCompounding.dailySimple:
        return 'Daily simple';
      case InterestCompounding.monthlyCompound:
        return 'Monthly compound';
    }
  }

  String _minimumPaymentRuleLabel(MinimumPaymentRule value) {
    switch (value) {
      case MinimumPaymentRule.fixedAmount:
        return 'Fixed amount';
      case MinimumPaymentRule.maxOfFixedOrPercent:
        return 'Max of fixed or %';
      case MinimumPaymentRule.interestPlusPercent:
        return 'Interest plus %';
    }
  }
}

class AddPaymentScreen extends ConsumerStatefulWidget {
  const AddPaymentScreen({
    super.key,
    required this.debtId,
    this.initialAmount,
    this.initialNote,
  });

  final String debtId;
  final double? initialAmount;
  final String? initialNote;

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late final TextEditingController _method;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: widget.initialAmount?.toString() ?? '',
    );
    _note = TextEditingController(text: widget.initialNote ?? '');
    _method = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _method.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debt = ref.watch(debtProvider(widget.debtId)).valueOrNull;
    return AppPage(
      title: 'Add payment',
      child: debt == null
          ? const LoadingPane()
          : Form(
              key: _formKey,
              child: ListView(
                children: [
                  AppCard(
                    child: Text(
                      '${debt.title} • ${Formatters.currency(debt.currentBalance, currencyCode: debt.currency)}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Payment amount',
                    ),
                    validator: (value) => (Parsers.parseMoney(value ?? '') <= 0)
                        ? 'Enter a value'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _method,
                    decoration: const InputDecoration(
                      labelText: 'Method (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(Formatters.date(_date)),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final selected = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 3650),
                        ),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                        initialDate: _date,
                      );
                      if (selected != null) {
                        setState(() => _date = selected);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _note,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => _save(context),
                    child: const Text('Save payment'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(paymentsRepositoryProvider)
        .savePayment(
          Payment(
            id: const Uuid().v4(),
            debtId: widget.debtId,
            amount: Parsers.parseMoney(_amount.text),
            date: _date,
            method: _method.text.trim().isEmpty ? null : _method.text.trim(),
            sourceType: PaymentSourceType.manual,
            notes: _note.text.trim(),
            tags: const [],
            createdAt: DateTime.now(),
          ),
        );
    if (context.mounted) {
      context.pop();
    }
  }
}

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key, required this.debtId});

  final String debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debt = ref.watch(debtProvider(debtId)).valueOrNull;
    final payments = ref.watch(paymentsByDebtProvider(debtId));
    return AppPage(
      title: 'Payment history',
      child: payments.when(
        data: (items) => items.isEmpty
            ? const EmptyStateView(
                title: 'No payments yet',
                message: 'Manual or imported payments will appear here.',
                icon: Icons.payments_outlined,
              )
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final payment = items[index];
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        Formatters.currency(
                          payment.amount,
                          currencyCode: debt?.currency ?? 'USD',
                        ),
                      ),
                      subtitle: Text(
                        '${Formatters.date(payment.date)} • ${payment.notes}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(paymentsRepositoryProvider)
                            .deletePayment(payment.id),
                      ),
                    ),
                  );
                },
              ),
        error: (error, _) => AppErrorState(message: error.toString()),
        loading: () => const LoadingPane(),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

String _compoundingLabel(InterestCompounding value) {
  switch (value) {
    case InterestCompounding.none:
      return 'No interest';
    case InterestCompounding.dailySimple:
      return 'Daily simple';
    case InterestCompounding.monthlyCompound:
      return 'Monthly compound';
  }
}

String _minimumRuleLabel(MinimumPaymentRule value) {
  switch (value) {
    case MinimumPaymentRule.fixedAmount:
      return 'Fixed amount';
    case MinimumPaymentRule.maxOfFixedOrPercent:
      return 'Max of fixed or %';
    case MinimumPaymentRule.interestPlusPercent:
      return 'Interest plus %';
  }
}
