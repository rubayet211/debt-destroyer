import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/parsers.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/debt.dart';
import '../../../shared/models/import_models.dart';
import '../../../shared/models/strategy_models.dart';
import '../../../shared/models/user_preferences.dart';
import '../../../shared/providers/app_providers.dart';
import '../../strategy/domain/strategy_engine.dart';

class DebtReviewScreen extends ConsumerStatefulWidget {
  const DebtReviewScreen({super.key, required this.bundle});

  final ImportReviewBundle bundle;

  @override
  ConsumerState<DebtReviewScreen> createState() => _DebtReviewScreenState();
}

class _DebtReviewScreenState extends ConsumerState<DebtReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final List<_DebtDraftControllers> _drafts;
  var _selectedIndex = 0;
  var _saving = false;
  var _showErrors = false;

  bool get _canReviewMultipleDebts =>
      widget.bundle.document.sourceType == DocumentSourceType.pdf ||
      widget.bundle.document.mimeType == 'application/pdf';

  @override
  void initState() {
    super.initState();
    _drafts = [_DebtDraftControllers.fromCandidate(widget.bundle.candidate)];
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(debtsProvider).valueOrNull ?? const <Debt>[];
    final preferences = ref.watch(userPreferencesProvider).valueOrNull;
    final draft = _drafts[_selectedIndex];
    final currencyCode =
        widget.bundle.candidate.currency ?? preferences?.currencyCode ?? 'USD';

    return Scaffold(
      appBar: AppBar(title: const Text('Review & Confirm')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: _ActionRow(
            saving: _saving,
            onEditOrRescan: _editOrRescan,
            onSave: _saveDebts,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Form(
            key: _formKey,
            autovalidateMode: _showErrors
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _HeaderCard(bundle: widget.bundle),
                  const SizedBox(height: AppSpacing.md),
                  if (_canReviewMultipleDebts) ...[
                    _DebtSwitcher(
                      count: _drafts.length,
                      selectedIndex: _selectedIndex,
                      onSelect: (index) =>
                          setState(() => _selectedIndex = index),
                      onAdd: _addDraft,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: _drafts.length == 1
                              ? 'Debt details'
                              : 'Debt ${_selectedIndex + 1} details',
                          subtitle:
                              'Review the numbers before this is saved locally.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ReviewTextField(
                          label: 'Creditor name',
                          controller: draft.creditor,
                          uncertain: draft.uncertain.creditor,
                          hint: 'Bank, lender, or provider name',
                          validator: _requiredText,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ReviewTextField(
                          label: 'Balance',
                          controller: draft.balance,
                          uncertain: draft.uncertain.balance,
                          hint: 'Amount currently owed',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _balanceValidator,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ReviewTextField(
                          label: 'Interest rate (APR)',
                          controller: draft.apr,
                          uncertain: draft.uncertain.apr,
                          hint: 'Annual interest rate, 0 to 100',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _aprValidator,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ReviewTextField(
                          label: 'Minimum payment',
                          controller: draft.minimum,
                          uncertain: draft.uncertain.minimum,
                          hint: 'Smallest required payment',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _minimumValidator,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ReviewTextField(
                          label: 'Due date',
                          controller: draft.dueDate,
                          uncertain: draft.uncertain.dueDate,
                          hint: 'YYYY-MM-DD or MM/DD/YYYY',
                          keyboardType: TextInputType.datetime,
                          validator: _dueDateValidator,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PlanPreviewCard(
                    currentDebts: debts.where((debt) => debt.isActive).toList(),
                    draftDebts: _validDraftDebts(
                      currencyCode: currencyCode,
                      preferences: preferences,
                    ),
                    strategyType:
                        preferences?.defaultStrategy ?? StrategyType.avalanche,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'You can always edit this later. We recommend double-checking the numbers.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addDraft() {
    setState(() {
      _drafts.add(_DebtDraftControllers.blank(index: _drafts.length + 1));
      _selectedIndex = _drafts.length - 1;
    });
  }

  List<Debt> _validDraftDebts({
    required String currencyCode,
    required UserPreferences? preferences,
  }) {
    final now = DateTime.now();
    return [
      for (var i = 0; i < _drafts.length; i++)
        if (_drafts[i].balanceValue > 0)
          _drafts[i].toDebt(
            id: 'draft-$i',
            currencyCode: currencyCode,
            now: now,
          ),
    ];
  }

  Future<void> _editOrRescan() async {
    await ref
        .read(documentsRepositoryProvider)
        .purgeDocument(widget.bundle.document.id);
    ref.read(scanImportStateProvider.notifier).clear();
    if (mounted) {
      context.go('/scan');
    }
  }

  Future<void> _saveDebts() async {
    setState(() => _showErrors = true);
    if (!_formKey.currentState!.validate() || !_allDraftsValid()) {
      return;
    }
    setState(() => _saving = true);

    final preferences =
        ref.read(userPreferencesProvider).valueOrNull ??
        UserPreferences.defaults();
    final currencyCode =
        widget.bundle.candidate.currency ?? preferences.currencyCode;
    final now = DateTime.now();
    final debts = [
      for (final draft in _drafts)
        draft.toDebt(
          id: const Uuid().v4(),
          currencyCode: currencyCode,
          now: now,
        ),
    ];

    try {
      await ref
          .read(importFinalizationServiceProvider)
          .finalize(
            document: widget.bundle.document,
            extraction: _buildParsedExtraction(debts),
            linkedDebtId: debts.first.id,
            sourcePath: widget.bundle.sourcePath,
            debtToCreate: debts.first,
          );

      for (final debt in debts.skip(1)) {
        await ref.read(debtsRepositoryProvider).saveDebt(debt);
      }

      ref.read(scanImportStateProvider.notifier).clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              debts.length == 1
                  ? 'Debt saved.'
                  : '${debts.length} debts saved.',
            ),
          ),
        );
        context.go('/dashboard');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $error')));
      }
    }
  }

  bool _allDraftsValid() {
    for (var i = 0; i < _drafts.length; i++) {
      final draft = _drafts[i];
      final valid =
          _requiredText(draft.creditor.text) == null &&
          _balanceValidator(draft.balance.text) == null &&
          _aprValidator(draft.apr.text) == null &&
          _minimumValidator(draft.minimum.text) == null &&
          _dueDateValidator(draft.dueDate.text) == null;
      if (!valid) {
        setState(() => _selectedIndex = i);
        _formKey.currentState?.validate();
        return false;
      }
    }
    return true;
  }

  ParsedExtraction _buildParsedExtraction(List<Debt> debts) {
    return ParsedExtraction(
      id: const Uuid().v4(),
      documentId: widget.bundle.document.id,
      classification: widget.bundle.classification,
      confidence: widget.bundle.candidate.confidence,
      payloadJson: jsonEncode({
        'reviewType': 'debt_review',
        'debts': debts
            .map(
              (debt) => {
                'id': debt.id,
                'creditorName': debt.creditorName,
                'balance': debt.currentBalance,
                'apr': debt.apr,
                'minimumPayment': debt.minimumPayment,
                'dueDate': debt.dueDate?.toIso8601String(),
              },
            )
            .toList(),
        'sourceType': widget.bundle.document.sourceType.name,
      }),
      ambiguityNotes: widget.bundle.issues
          .map((issue) => issue.message)
          .join(' '),
      createdAt: DateTime.now(),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.saving,
    required this.onEditOrRescan,
    required this.onSave,
  });

  final bool saving;
  final VoidCallback onEditOrRescan;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: saving ? null : onEditOrRescan,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Edit / Rescan'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(saving ? 'Saving...' : 'Save Debt'),
          ),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.bundle});

  final ImportReviewBundle bundle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.documentClassification(bundle.classification),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${bundle.document.sourceType.name.toUpperCase()} import • ${(bundle.candidate.confidence * 100).toStringAsFixed(0)}% confidence',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (bundle.issues.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final issue in bundle.issues.take(3))
                        AppStatusBadge(
                          label: issue.code.replaceAll('_', ' '),
                          icon: Icons.info_outline_rounded,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtSwitcher extends StatelessWidget {
  const _DebtSwitcher({
    required this.count,
    required this.selectedIndex,
    required this.onSelect,
    required this.onAdd,
  });

  final int count;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Multiple debts from this document',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < count; i++)
                ChoiceChip(
                  label: Text('Debt ${i + 1}'),
                  selected: selectedIndex == i,
                  onSelected: (_) => onSelect(i),
                ),
              ActionChip(
                avatar: const Icon(Icons.add_rounded),
                label: const Text('Add another debt'),
                onPressed: onAdd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewTextField extends StatelessWidget {
  const _ReviewTextField({
    required this.label,
    required this.controller,
    required this.uncertain,
    required this.hint,
    required this.validator,
    required this.onChanged,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool uncertain;
  final String hint;
  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: uncertain ? 'Needs review' : hint,
        suffixIcon: uncertain
            ? Icon(Icons.warning_amber_rounded, color: scheme.tertiary)
            : const Icon(Icons.check_circle_outline_rounded),
        enabledBorder: uncertain
            ? OutlineInputBorder(
                borderSide: BorderSide(color: scheme.tertiary, width: 1.4),
                borderRadius: BorderRadius.circular(14),
              )
            : null,
      ),
    );
  }
}

class _PlanPreviewCard extends StatelessWidget {
  const _PlanPreviewCard({
    required this.currentDebts,
    required this.draftDebts,
    required this.strategyType,
  });

  final List<Debt> currentDebts;
  final List<Debt> draftDebts;
  final StrategyType strategyType;

  @override
  Widget build(BuildContext context) {
    final allDebts = [...currentDebts, ...draftDebts];
    final engine = StrategyEngine();
    final now = DateTime.now();
    final current = _simulate(engine, currentDebts, strategyType, now);
    final updated = _simulate(engine, allDebts, strategyType, now);
    final monthChange = updated.monthsToPayoff - current.monthsToPayoff;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Payoff plan preview',
            subtitle: 'Local estimate using your current strategy.',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _PreviewMetric(
                  label: 'Current plan',
                  value: current.monthsToPayoff == 0
                      ? 'No active debt'
                      : '${current.monthsToPayoff} months',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PreviewMetric(
                  label: 'After save',
                  value: updated.monthsToPayoff == 0
                      ? 'No active debt'
                      : '${updated.monthsToPayoff} months',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            monthChange <= 0
                ? 'This debt does not extend the estimate with current numbers.'
                : 'Estimated payoff changes by +$monthChange months.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  StrategyResult _simulate(
    StrategyEngine engine,
    List<Debt> debts,
    StrategyType strategyType,
    DateTime now,
  ) {
    final budget = debts.fold<double>(
      0,
      (sum, debt) => sum + debt.minimumPayment,
    );
    return engine.simulate(
      debts: debts,
      request: StrategyRequest(
        strategyType: strategyType,
        monthlyBudget: budget,
        extraMonthlyPayment: 0,
        startDate: now,
        lumpSum: 0,
        includeArchived: false,
        customPriorities: {
          for (final debt in debts) debt.id: debt.customPriority,
        },
        pausedDebtIds: {
          for (final debt in debts)
            if (debt.planPaused) debt.id,
        },
        allowUnderMinimumBudget: false,
      ),
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  const _PreviewMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _DebtDraftControllers {
  _DebtDraftControllers({
    required this.creditor,
    required this.balance,
    required this.apr,
    required this.minimum,
    required this.dueDate,
    required this.uncertain,
  });

  factory _DebtDraftControllers.fromCandidate(ExtractionCandidate candidate) {
    final confidence = candidate.confidence;
    return _DebtDraftControllers(
      creditor: TextEditingController(text: candidate.creditorName ?? ''),
      balance: TextEditingController(
        text: _numberText(candidate.currentBalance),
      ),
      apr: TextEditingController(text: _numberText(candidate.aprPercentage)),
      minimum: TextEditingController(
        text: _numberText(candidate.minimumPayment),
      ),
      dueDate: TextEditingController(text: _dateText(candidate.dueDate)),
      uncertain: _FieldUncertainty(
        creditor:
            (candidate.creditorName ?? '').trim().isEmpty || confidence < 0.55,
        balance: (candidate.currentBalance ?? 0) <= 0 || confidence < 0.65,
        apr: candidate.aprPercentage == null || confidence < 0.65,
        minimum: candidate.minimumPayment == null || confidence < 0.65,
        dueDate: candidate.dueDate == null || confidence < 0.65,
      ),
    );
  }

  factory _DebtDraftControllers.blank({required int index}) {
    return _DebtDraftControllers(
      creditor: TextEditingController(),
      balance: TextEditingController(),
      apr: TextEditingController(text: '0'),
      minimum: TextEditingController(),
      dueDate: TextEditingController(),
      uncertain: const _FieldUncertainty(
        creditor: true,
        balance: true,
        apr: true,
        minimum: true,
        dueDate: true,
      ),
    );
  }

  final TextEditingController creditor;
  final TextEditingController balance;
  final TextEditingController apr;
  final TextEditingController minimum;
  final TextEditingController dueDate;
  final _FieldUncertainty uncertain;

  double get balanceValue => Parsers.parseMoney(balance.text);

  Debt toDebt({
    required String id,
    required String currencyCode,
    required DateTime now,
  }) {
    final creditorName = creditor.text.trim();
    return Debt(
      id: id,
      title: creditorName.isEmpty ? 'Imported debt' : creditorName,
      creditorName: creditorName.isEmpty ? 'Unknown creditor' : creditorName,
      type: DebtType.creditCard,
      currency: currencyCode,
      originalBalance: Parsers.parseMoney(balance.text),
      currentBalance: Parsers.parseMoney(balance.text),
      apr: Parsers.parseMoney(apr.text),
      minimumPayment: Parsers.parseMoney(minimum.text),
      dueDate: Parsers.parseDate(dueDate.text),
      paymentFrequency: PaymentFrequency.monthly,
      createdAt: now,
      updatedAt: now,
      notes: 'Imported from document review',
      tags: const ['imported'],
      status: DebtStatus.active,
      remindersEnabled: true,
      customPriority: 99,
    );
  }

  void dispose() {
    creditor.dispose();
    balance.dispose();
    apr.dispose();
    minimum.dispose();
    dueDate.dispose();
  }
}

class _FieldUncertainty {
  const _FieldUncertainty({
    required this.creditor,
    required this.balance,
    required this.apr,
    required this.minimum,
    required this.dueDate,
  });

  final bool creditor;
  final bool balance;
  final bool apr;
  final bool minimum;
  final bool dueDate;
}

String? _requiredText(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter a creditor name';
  }
  return null;
}

String? _balanceValidator(String? value) {
  if (Parsers.parseMoney(value ?? '') <= 0) {
    return 'Balance must be greater than 0';
  }
  return null;
}

String? _aprValidator(String? value) {
  final apr = Parsers.parseMoney(value ?? '');
  if (apr < 0 || apr > 100) {
    return 'APR must be between 0 and 100';
  }
  return null;
}

String? _minimumValidator(String? value) {
  if (Parsers.parseMoney(value ?? '') < 0) {
    return 'Minimum payment cannot be negative';
  }
  return null;
}

String? _dueDateValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  if (Parsers.parseDate(value) == null) {
    return 'Enter a valid due date';
  }
  return null;
}

String _numberText(double? value) {
  if (value == null) {
    return '';
  }
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}

String _dateText(DateTime? value) {
  if (value == null) {
    return '';
  }
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
