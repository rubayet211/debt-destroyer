# App Correctness And Privacy Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the three approved app launch blockers: payment balance corruption, import pre-confirm persistence, and inaccurate reports sourcing/filtering.

**Architecture:** Keep the fixes localized to existing ownership boundaries. Payment behavior changes stay in the repository layer, import persistence changes stay in the controller/review-save path, and reports changes stay in providers/presentation with minimal helper extraction for date-range filtering and chart bucketing.

**Tech Stack:** Flutter, Riverpod, Drift, Flutter widget tests, Flutter unit tests

---

## File Map

- `lib/shared/data/repositories.dart`
  Payment repository behavior. This is where current-balance delta handling belongs.
- `lib/shared/providers/app_providers.dart`
  Source of app-level providers and state notifiers. This is where scan-import persistence must stop and where reports date-range state should live.
- `lib/features/scan_import/presentation/scan_screens.dart`
  Review/save UI path. This is where persistence must move to the final confirm boundary.
- `lib/features/reports/presentation/reports_screen.dart`
  Reports screen composition, date-range UI, filtered totals, and chart bucketing.
- `test/repositories_test.dart`
  Repository regression tests for payment save/update/delete balance behavior.
- `test/ocr_processing_screen_test.dart`
  Widget-level regression test proving OCR processing does not persist anything before review confirm.
- `test/scan_review_widget_test.dart`
  Widget-level regression tests for failed confirm and successful confirm persistence boundaries.
- `test/reports_screen_test.dart`
  Widget tests and helper tests for full-history sourcing, date-range filtering, and chart bucket behavior.

---

### Task 1: Fix Payment Balance Delta Handling

**Files:**
- Modify: `lib/shared/data/repositories.dart`
- Test: `test/repositories_test.dart`

- [ ] **Step 1: Write the failing regression tests**

Add these tests to `test/repositories_test.dart` near the existing payment-balance tests:

```dart
test(
  'saving a payment decrements current stored balance instead of deriving from original balance',
  () async {
    final debt = Debt(
      id: 'd-balance-delta',
      title: 'Visa',
      creditorName: 'Bank',
      type: DebtType.creditCard,
      currency: 'USD',
      originalBalance: 1000,
      currentBalance: 640,
      apr: 20,
      minimumPayment: 60,
      dueDate: null,
      paymentFrequency: PaymentFrequency.monthly,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      notes: '',
      tags: const [],
      status: DebtStatus.active,
      remindersEnabled: false,
      customPriority: 1,
    );
    await debtsRepository.saveDebt(debt);

    await paymentsRepository.savePayment(
      Payment(
        id: 'payment-delta-1',
        debtId: debt.id,
        amount: 50,
        date: DateTime(2026, 1, 20),
        method: 'ACH',
        sourceType: PaymentSourceType.manual,
        notes: '',
        tags: const [],
        createdAt: DateTime(2026, 1, 20),
      ),
    );

    final updated = await debtsRepository.loadDebts();
    expect(updated.single.currentBalance, 590);
  },
);

test('updating an existing payment only applies the payment delta', () async {
  final debt = Debt(
    id: 'd-payment-update',
    title: 'Visa',
    creditorName: 'Bank',
    type: DebtType.creditCard,
    currency: 'USD',
    originalBalance: 1000,
    currentBalance: 640,
    apr: 20,
    minimumPayment: 60,
    dueDate: null,
    paymentFrequency: PaymentFrequency.monthly,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    notes: '',
    tags: const [],
    status: DebtStatus.active,
    remindersEnabled: false,
    customPriority: 1,
  );
  await debtsRepository.saveDebt(debt);

  await paymentsRepository.savePayment(
    Payment(
      id: 'payment-update-1',
      debtId: debt.id,
      amount: 50,
      date: DateTime(2026, 1, 20),
      method: 'ACH',
      sourceType: PaymentSourceType.manual,
      notes: '',
      tags: const [],
      createdAt: DateTime(2026, 1, 20),
    ),
  );
  await paymentsRepository.savePayment(
    Payment(
      id: 'payment-update-1',
      debtId: debt.id,
      amount: 80,
      date: DateTime(2026, 1, 20),
      method: 'ACH',
      sourceType: PaymentSourceType.manual,
      notes: '',
      tags: const [],
      createdAt: DateTime(2026, 1, 20),
    ),
  );

  final updated = await debtsRepository.loadDebts();
  expect(updated.single.currentBalance, 560);
});

test('deleting a payment restores the deducted amount to current balance', () async {
  final debt = Debt(
    id: 'd-payment-delete',
    title: 'Visa',
    creditorName: 'Bank',
    type: DebtType.creditCard,
    currency: 'USD',
    originalBalance: 1000,
    currentBalance: 640,
    apr: 20,
    minimumPayment: 60,
    dueDate: null,
    paymentFrequency: PaymentFrequency.monthly,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    notes: '',
    tags: const [],
    status: DebtStatus.active,
    remindersEnabled: false,
    customPriority: 1,
  );
  await debtsRepository.saveDebt(debt);

  await paymentsRepository.savePayment(
    Payment(
      id: 'payment-delete-1',
      debtId: debt.id,
      amount: 50,
      date: DateTime(2026, 1, 20),
      method: 'ACH',
      sourceType: PaymentSourceType.manual,
      notes: '',
      tags: const [],
      createdAt: DateTime(2026, 1, 20),
    ),
  );
  await paymentsRepository.deletePayment('payment-delete-1');

  final updated = await debtsRepository.loadDebts();
  expect(updated.single.currentBalance, 640);
  expect(updated.single.status, DebtStatus.active);
});
```

- [ ] **Step 2: Run the repository tests and verify they fail for the right reason**

Run:

```bash
flutter test test/repositories_test.dart
```

Expected: FAIL. The new balance assertions should fail because the current implementation still derives balance from `originalBalance - totalPaid`, producing values like `950` or `920` instead of preserving the current stored balance semantics.

- [ ] **Step 3: Replace recalculation with current-balance delta handling**

Update `lib/shared/data/repositories.dart` inside `DriftPaymentsRepository`:

```dart
@override
Future<void> savePayment(Payment payment) async {
  final existing = await (database.select(
    database.paymentsTable,
  )..where((tbl) => tbl.id.equals(payment.id))).getSingleOrNull();

  await database
      .into(database.paymentsTable)
      .insertOnConflictUpdate(
        PaymentsTableCompanion.insert(
          id: payment.id,
          debtId: payment.debtId,
          amount: payment.amount,
          date: payment.date,
          method: Value(payment.method),
          sourceType: payment.sourceType.name,
          notes: Value(payment.notes),
          tagsJson: Value(database.encodeStringList(payment.tags)),
          createdAt: payment.createdAt,
        ),
      );

  final priorAmount = existing?.amount ?? 0;
  final amountDelta = payment.amount - priorAmount;
  await _applyPaymentDelta(payment.debtId, amountDelta);
}

@override
Future<void> deletePayment(String id) async {
  final payment = await (database.select(
    database.paymentsTable,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  await (database.delete(
    database.paymentsTable,
  )..where((tbl) => tbl.id.equals(id))).go();
  if (payment != null) {
    await _applyPaymentDelta(payment.debtId, -payment.amount);
  }
}

Future<void> _applyPaymentDelta(String debtId, double amountDelta) async {
  final debtRow = await (database.select(
    database.debtsTable,
  )..where((tbl) => tbl.id.equals(debtId))).getSingleOrNull();
  if (debtRow == null) {
    return;
  }

  final nextBalance = (debtRow.currentBalance - amountDelta).clamp(
    0,
    double.infinity,
  ).toDouble();
  final currentStatus = DebtStatus.values.byName(debtRow.status);
  final nextStatus = nextBalance == 0
      ? DebtStatus.paidOff
      : currentStatus == DebtStatus.paidOff
          ? DebtStatus.active
          : currentStatus;

  await (database.update(
    database.debtsTable,
  )..where((tbl) => tbl.id.equals(debtId))).write(
    DebtsTableCompanion(
      currentBalance: Value(nextBalance),
      status: Value(nextStatus.name),
      updatedAt: Value(DateTime.now()),
    ),
  );
}
```

Delete the old `_recalculateDebtBalance()` helper after the new delta helper is in place.

- [ ] **Step 4: Re-run the repository tests**

Run:

```bash
flutter test test/repositories_test.dart
```

Expected: PASS. The three new tests should pass along with the existing repository tests.

- [ ] **Step 5: Commit the slice**

```bash
git add test/repositories_test.dart lib/shared/data/repositories.dart
git commit -m "fix: preserve current balances when payments change"
```

---

### Task 2: Enforce No Persistence Before Final Import Confirm

**Files:**
- Modify: `lib/shared/providers/app_providers.dart`
- Modify: `lib/features/scan_import/presentation/scan_screens.dart`
- Test: `test/ocr_processing_screen_test.dart`
- Test: `test/scan_review_widget_test.dart`

- [ ] **Step 1: Write the failing import persistence tests**

Add this test to `test/ocr_processing_screen_test.dart`:

```dart
testWidgets('processing screen prepares review without persisting documents', (
  tester,
) async {
  final coordinator = _SuccessfulImportCoordinator();
  final documentsRepository = _RecordingDocumentsRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        importCoordinatorProvider.overrideWith((_) => coordinator),
        documentsRepositoryProvider.overrideWithValue(documentsRepository),
      ],
      child: MaterialApp(
        home: OCRProcessingScreen(
          fileReference: const FileReference(
            path: 'test.png',
            sourceType: DocumentSourceType.gallery,
            mimeType: 'image/png',
          ),
          allowCloud: false,
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pumpAndSettle();

  expect(documentsRepository.savedDocuments, isEmpty);
});
```

Add the supporting fakes in the same test file:

```dart
class _SuccessfulImportCoordinator extends ImportCoordinator {
  _SuccessfulImportCoordinator()
    : super(
        documentVaultService: _DummyVaultService(),
        preprocessService: _DummyPreprocessService(),
        ocrService: _DummyOcrService(),
        classifier: DocumentClassifier(),
        aiExtractionService: _DummyAiExtractionService(),
        validationService: ParseValidationService(),
        preferencesRepository: _DummyPreferencesRepository(),
        retentionService: const DataRetentionService(),
      );

  @override
  Future<ImportReviewBundle> process({
    required FileReference input,
    required bool allowCloud,
  }) async {
    return ImportReviewBundle(
      document: ImportedDocument(
        id: 'doc-processing-success',
        storageRef: 'vault-processing-success',
        sourceType: input.sourceType,
        mimeType: input.mimeType,
        createdAt: DateTime(2026, 3, 1),
        lifecycleState: DocumentLifecycleState.processed,
        linkedDebtId: null,
        rawOcrText: null,
        parseStatus: ParseStatus.success,
        parseVersion: 'v1',
        deleted: false,
        retentionExpiresAt: null,
        rawOcrExpiresAt: null,
        processedAt: DateTime(2026, 3, 1),
        linkedAt: null,
        pendingDeletionAt: null,
        purgedAt: null,
        encryptedAt: DateTime(2026, 3, 1),
        hasRawOcrText: false,
      ),
      classification: DocumentClassification.creditCardStatement,
      normalizedText: 'ACME CREDIT CARD STATEMENT',
      candidate: const ExtractionCandidate(
        title: 'Imported debt',
        creditorName: 'Acme Bank',
        debtType: DebtType.creditCard,
        currentBalance: 500,
        confidence: 0.9,
      ),
      summary: const StatementSummaryCandidate(
        title: 'Imported debt',
        creditorName: 'Acme Bank',
        debtType: DebtType.creditCard,
        currentBalance: 500,
        confidence: 0.9,
      ),
      statementLineItems: const [],
      issues: const [],
      reviewMode: ImportReviewMode.summaryOnly,
      errorMessage: null,
    );
  }
}

class _RecordingDocumentsRepository extends _NoopDocumentsRepository {
  final List<ImportedDocument> savedDocuments = [];

  @override
  Future<void> saveDocument(ImportedDocument document) async {
    savedDocuments.add(document);
  }
}
```

Extend `test/scan_review_widget_test.dart` with a recording documents repository and two tests:

```dart
testWidgets(
  'review screen leaves storage unchanged when add-payment validation fails',
  (tester) async {
    final documentsRepository = _TestDocumentsRepository();
    final paymentsRepository = _TestPaymentsRepository();
    final debt = buildTestDebt(id: 'debt-1');
    final bundle = ImportReviewBundle(
      document: ImportedDocument(
        id: 'doc-2',
        storageRef: 'vault-2',
        sourceType: DocumentSourceType.gallery,
        mimeType: 'image/png',
        createdAt: DateTime(2026, 3, 1),
        lifecycleState: DocumentLifecycleState.processed,
        linkedDebtId: null,
        rawOcrText: null,
        parseStatus: ParseStatus.success,
        parseVersion: 'v1',
        deleted: false,
        retentionExpiresAt: null,
        rawOcrExpiresAt: null,
        processedAt: DateTime(2026, 3, 1),
        linkedAt: null,
        pendingDeletionAt: null,
        purgedAt: null,
        encryptedAt: DateTime(2026, 3, 1),
        hasRawOcrText: false,
      ),
      classification: DocumentClassification.creditCardStatement,
      normalizedText: 'ACME CREDIT CARD STATEMENT',
      candidate: const ExtractionCandidate(
        title: 'Acme Statement',
        creditorName: 'Acme Bank',
        debtType: DebtType.creditCard,
        currency: 'USD',
        confidence: 0.7,
      ),
      summary: const StatementSummaryCandidate(
        title: 'Acme Statement',
        creditorName: 'Acme Bank',
        debtType: DebtType.creditCard,
        currency: 'USD',
        confidence: 0.7,
      ),
      statementLineItems: const [],
      issues: const [],
      reviewMode: ImportReviewMode.summaryOnly,
      errorMessage: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          debtsProvider.overrideWith((_) => Stream.value([debt])),
          documentsRepositoryProvider.overrideWithValue(documentsRepository),
          paymentsRepositoryProvider.overrideWithValue(paymentsRepository),
          userPreferencesProvider.overrideWith(
            (_) => Stream.value(UserPreferences.defaults()),
          ),
          paymentsByDebtProvider(
            debt.id,
          ).overrideWith((_) => Stream.value(const <Payment>[])),
        ],
        child: MaterialApp(home: ParsedReviewConfirmScreen(bundle: bundle)),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<ImportActionType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add payment').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visa').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(documentsRepository.savedDocuments, isEmpty);
    expect(documentsRepository.savedExtractions, isEmpty);
    expect(paymentsRepository.savedPayments, isEmpty);
  },
);

testWidgets('review screen persists artifacts only after successful save', (
  tester,
) async {
  final documentsRepository = _TestDocumentsRepository();
  final debtsRepository = _TestDebtsRepository();
  final bundle = ImportReviewBundle(
    document: ImportedDocument(
      id: 'doc-success',
      storageRef: 'vault-success',
      sourceType: DocumentSourceType.gallery,
      mimeType: 'image/png',
      createdAt: DateTime(2026, 3, 1),
      lifecycleState: DocumentLifecycleState.processed,
      linkedDebtId: null,
      rawOcrText: null,
      parseStatus: ParseStatus.success,
      parseVersion: 'v1',
      deleted: false,
      retentionExpiresAt: null,
      rawOcrExpiresAt: null,
      processedAt: DateTime(2026, 3, 1),
      linkedAt: null,
      pendingDeletionAt: null,
      purgedAt: null,
      encryptedAt: DateTime(2026, 3, 1),
      hasRawOcrText: false,
    ),
    classification: DocumentClassification.creditCardStatement,
    normalizedText: 'ACME CREDIT CARD STATEMENT',
    candidate: const ExtractionCandidate(
      title: 'Imported debt',
      creditorName: 'Acme Bank',
      debtType: DebtType.creditCard,
      currentBalance: 500,
      confidence: 0.9,
    ),
    summary: const StatementSummaryCandidate(
      title: 'Imported debt',
      creditorName: 'Acme Bank',
      debtType: DebtType.creditCard,
      currentBalance: 500,
      confidence: 0.9,
    ),
    statementLineItems: const [],
    issues: const [],
    reviewMode: ImportReviewMode.summaryOnly,
    errorMessage: null,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        debtsProvider.overrideWith((_) => Stream.value(const <Debt>[])),
        debtsRepositoryProvider.overrideWithValue(debtsRepository),
        documentsRepositoryProvider.overrideWithValue(documentsRepository),
        userPreferencesProvider.overrideWith(
          (_) => Stream.value(UserPreferences.defaults()),
        ),
      ],
      child: MaterialApp(home: ParsedReviewConfirmScreen(bundle: bundle)),
    ),
  );

  await tester.pumpAndSettle();
  await tester.drag(find.byType(ListView), const Offset(0, -800));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();

  expect(documentsRepository.savedDocuments, hasLength(1));
  expect(documentsRepository.savedExtractions, hasLength(1));
  expect(debtsRepository.savedDebts, hasLength(1));
});
```

Also extend `_TestDocumentsRepository` with:

```dart
final List<ParsedExtraction> savedExtractions = [];

@override
Future<void> saveParsedExtraction(ParsedExtraction extraction) async {
  savedExtractions.add(extraction);
}
```

And add a `_TestDebtsRepository` fake:

```dart
class _TestDebtsRepository implements DebtsRepository {
  final List<Debt> savedDebts = [];

  @override
  Future<void> saveDebt(Debt debt) async {
    savedDebts.add(debt);
  }

  @override
  Future<void> archiveDebt(String id) async {}
  @override
  Future<void> deleteDebt(String id) async {}
  @override
  Future<List<Debt>> loadDebts({bool includeArchived = false}) async => savedDebts;
  @override
  Future<void> markPaidOff(String id) async {}
  @override
  Future<void> restoreDebt(String id) async {}
  @override
  Stream<Debt?> watchDebt(String id) => Stream.value(null);
  @override
  Stream<List<Debt>> watchDebts({bool includeArchived = false}) =>
      Stream.value(savedDebts);
}
```

- [ ] **Step 2: Run the import-related tests and verify they fail**

Run:

```bash
flutter test test/ocr_processing_screen_test.dart
flutter test test/scan_review_widget_test.dart
```

Expected: FAIL. `ScanImportController.process()` still saves the document during OCR processing, and `_save()` still persists document/extraction artifacts before validating payment/debt selection.

- [ ] **Step 3: Remove pre-review persistence and move persistence into the validated save path**

Update `lib/shared/providers/app_providers.dart` so `ScanImportController.process()` stops persisting documents:

```dart
Future<void> process({
  required FileReference input,
  required bool allowCloud,
}) async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() async {
    return ref
        .read(importCoordinatorProvider)
        .process(input: input, allowCloud: allowCloud);
  });
}
```

In `lib/features/scan_import/presentation/scan_screens.dart`, extract artifact persistence into a helper and call it only after branch validation passes:

```dart
Future<void> _persistReviewArtifacts(
  DocumentsRepository documentsRepository,
) async {
  await documentsRepository.saveDocument(widget.bundle.document);
  await documentsRepository.saveParsedExtraction(
    ParsedExtraction(
      id: const Uuid().v4(),
      documentId: widget.bundle.document.id,
      classification: widget.bundle.classification,
      confidence: widget.bundle.candidate.confidence,
      payloadJson: jsonEncode({
        'title': _title.text,
        'creditorName': _creditor.text,
        'balance': _balance.text,
        'apr': _apr.text,
        'minimum': _minimum.text,
        'paymentAmount': _paymentAmount.text,
        'statementLineItems': _lineItems
            .map(
              (item) => {
                'description': item.description,
                'amount': item.amount,
                'date': item.date?.toIso8601String(),
                'type': item.type.name,
                'selected': item.isSelected,
              },
            )
            .toList(),
      }),
      ambiguityNotes: widget.bundle.errorMessage ?? '',
      createdAt: DateTime.now(),
    ),
  );
}
```

Then restructure `_save()` so:

- `ImportActionType.createDebt` calls `_persistReviewArtifacts()` immediately before `saveDebt()`
- `ImportActionType.addPayment` validates `debtId` and `amount` first, then calls `_persistReviewArtifacts()` before `savePayment()`
- `ImportActionType.importStatementItems` validates `debtId`, selected items, and dates first, then calls `_persistReviewArtifacts()` before saving payments

Do not leave `saveDocument()` or `saveParsedExtraction()` above the validation branches.

- [ ] **Step 4: Re-run the import persistence tests**

Run:

```bash
flutter test test/ocr_processing_screen_test.dart
flutter test test/scan_review_widget_test.dart
```

Expected: PASS. The processing screen should prepare a review bundle without persistence, failed review saves should leave storage unchanged, and successful saves should persist artifacts once.

- [ ] **Step 5: Commit the slice**

```bash
git add lib/shared/providers/app_providers.dart lib/features/scan_import/presentation/scan_screens.dart test/ocr_processing_screen_test.dart test/scan_review_widget_test.dart
git commit -m "fix: persist imports only after final confirmation"
```

---

### Task 3: Add Full-History Reports With Date-Range Filtering

**Files:**
- Modify: `lib/shared/providers/app_providers.dart`
- Modify: `lib/features/reports/presentation/reports_screen.dart`
- Test: `test/reports_screen_test.dart`

- [ ] **Step 1: Write the failing reports tests**

In `test/reports_screen_test.dart`, switch the screen setup to use `allPaymentsProvider` and add these tests:

```dart
testWidgets('reports screen uses full payment history by default', (
  tester,
) async {
  final debt = buildTestDebt(id: 'debt-full-history', dueDate: DateTime(2026, 3, 15));
  final payments = [
    buildTestPayment(id: 'payment-1', debtId: debt.id, amount: 125, date: DateTime(2026, 3, 9)),
    buildTestPayment(id: 'payment-2', debtId: debt.id, amount: 200, date: DateTime(2026, 1, 5)),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        allDebtsProvider.overrideWith((_) => Stream.value([debt])),
        allPaymentsProvider.overrideWith((_) => Stream.value(payments)),
        recentPaymentsProvider.overrideWith((_) => Stream.value([payments.first])),
        userPreferencesProvider.overrideWith(
          (_) => Stream.value(buildTestPreferences()),
        ),
        subscriptionStateProvider.overrideWith(
          (_) => Stream.value(SubscriptionState.free()),
        ),
        entitlementRefreshProvider.overrideWith(
          (_) async => EntitlementSnapshot.free(),
        ),
      ],
      child: const MaterialApp(home: ReportsScreen()),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Payments tracked'), findsOneWidget);
  expect(find.text('\$325.00'), findsOneWidget);
  expect(find.text('Full history'), findsOneWidget);
});

testWidgets('reports screen filters totals by selected date range', (
  tester,
) async {
  final debt = buildTestDebt(id: 'debt-filtered', dueDate: DateTime(2026, 3, 15));
  final payments = [
    buildTestPayment(id: 'payment-1', debtId: debt.id, amount: 125, date: DateTime(2026, 3, 9)),
    buildTestPayment(id: 'payment-2', debtId: debt.id, amount: 200, date: DateTime(2026, 1, 5)),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        allDebtsProvider.overrideWith((_) => Stream.value([debt])),
        allPaymentsProvider.overrideWith((_) => Stream.value(payments)),
        reportsDateRangeProvider.overrideWith(
          (ref) => DateTimeRange(
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 3, 31),
          ),
        ),
        userPreferencesProvider.overrideWith(
          (_) => Stream.value(buildTestPreferences()),
        ),
        subscriptionStateProvider.overrideWith(
          (_) => Stream.value(SubscriptionState.free()),
        ),
        entitlementRefreshProvider.overrideWith(
          (_) async => EntitlementSnapshot.free(),
        ),
      ],
      child: const MaterialApp(home: ReportsScreen()),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('\$125.00'), findsOneWidget);
  expect(find.textContaining('Mar 1, 2026'), findsOneWidget);
});

test('buildMonthlyPaymentBuckets keeps year-month buckets distinct', () {
  final buckets = buildMonthlyPaymentBuckets([
    buildTestPayment(id: 'payment-a', amount: 100, date: DateTime(2025, 12, 20)),
    buildTestPayment(id: 'payment-b', amount: 200, date: DateTime(2026, 12, 3)),
  ]);

  expect(buckets, hasLength(2));
  expect(buckets[0].label, 'Dec 2025');
  expect(buckets[1].label, 'Dec 2026');
});
```

- [ ] **Step 2: Run the reports tests and verify they fail**

Run:

```bash
flutter test test/reports_screen_test.dart
```

Expected: FAIL. The screen still watches `recentPaymentsProvider`, there is no `reportsDateRangeProvider`, and there is no year-aware monthly bucketing helper yet.

- [ ] **Step 3: Implement full-history sourcing, date-range state, and year-aware chart buckets**

Add reports date-range state in `lib/shared/providers/app_providers.dart`:

```dart
final reportsDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);
```

In `lib/features/reports/presentation/reports_screen.dart`:

1. Switch the screen to watch `allPaymentsProvider` instead of `recentPaymentsProvider`.
2. Add a small public helper model for chart buckets:

```dart
class MonthlyPaymentBucket {
  const MonthlyPaymentBucket({
    required this.month,
    required this.total,
    required this.label,
  });

  final DateTime month;
  final double total;
  final String label;
}

List<Payment> filterPaymentsByDateRange(
  List<Payment> payments,
  DateTimeRange? range,
) {
  if (range == null) {
    return payments;
  }
  final rangeStart = DateTime(range.start.year, range.start.month, range.start.day);
  final rangeEnd = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59, 999);
  return payments.where((payment) {
    return !payment.date.isBefore(rangeStart) && !payment.date.isAfter(rangeEnd);
  }).toList();
}

List<MonthlyPaymentBucket> buildMonthlyPaymentBuckets(List<Payment> payments) {
  final totals = <DateTime, double>{};
  for (final payment in payments) {
    final monthKey = DateTime(payment.date.year, payment.date.month);
    totals.update(monthKey, (value) => value + payment.amount, ifAbsent: () => payment.amount);
  }
  final months = totals.keys.toList()..sort();
  return [
    for (final month in months)
      MonthlyPaymentBucket(
        month: month,
        total: totals[month]!,
        label: '${Formatters.shortMonth(month)} ${month.year}',
      ),
  ];
}
```

3. Inside `ReportsScreen`, read the selected range:

```dart
final selectedRange = ref.watch(reportsDateRangeProvider);
```

4. Pass `selectedRange` into `_buildBody()` and `_ReportsBody`, filter payments before computing totals, and use `buildMonthlyPaymentBuckets(filteredPayments)` for the bar chart instead of the current `Map<int, double>` keyed only by month number.
5. Add a simple range card above the charts:

```dart
AppCard(
  child: Row(
    children: [
      Expanded(
        child: Text(
          selectedRange == null
              ? 'Full history'
              : '${Formatters.date(selectedRange.start)} - ${Formatters.date(selectedRange.end)}',
        ),
      ),
      TextButton(
        onPressed: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDateRange: selectedRange,
          );
          if (picked != null) {
            ref.read(reportsDateRangeProvider.notifier).state = picked;
          }
        },
        child: const Text('Choose range'),
      ),
      if (selectedRange != null)
        TextButton(
          onPressed: () {
            ref.read(reportsDateRangeProvider.notifier).state = null;
          },
          child: const Text('Clear'),
        ),
    ],
  ),
)
```

6. Update the summary totals and bar chart to use `filteredPayments`.

- [ ] **Step 4: Re-run the reports tests**

Run:

```bash
flutter test test/reports_screen_test.dart
```

Expected: PASS. The screen should default to full history, the selected range should filter the total, and the chart helper should keep December 2025 and December 2026 distinct.

- [ ] **Step 5: Commit the slice**

```bash
git add lib/shared/providers/app_providers.dart lib/features/reports/presentation/reports_screen.dart test/reports_screen_test.dart
git commit -m "fix: add date range filtering to reports"
```

---

### Task 4: Run Full Verification For The App Slice

**Files:**
- Modify: none expected

- [ ] **Step 1: Run the focused regression files together**

Run:

```bash
flutter test test/repositories_test.dart
flutter test test/ocr_processing_screen_test.dart
flutter test test/scan_review_widget_test.dart
flutter test test/reports_screen_test.dart
```

Expected: PASS for all four commands.

- [ ] **Step 2: Run the full Flutter verification suite**

Run:

```bash
flutter analyze
flutter test
flutter build appbundle --flavor prod --release --dart-define=APP_ENV=prod --dart-define=APP_FLAVOR=prod
```

Expected:
- `flutter analyze` exits 0 with `No issues found!`
- `flutter test` exits 0 with all tests passing
- the prod AAB build succeeds and writes `build\app\outputs\bundle\prodRelease\app-prod-release.aab`

- [ ] **Step 3: Inspect the final diff**

Run:

```bash
git status --short
git diff -- lib/shared/data/repositories.dart lib/shared/providers/app_providers.dart lib/features/scan_import/presentation/scan_screens.dart lib/features/reports/presentation/reports_screen.dart test/repositories_test.dart test/ocr_processing_screen_test.dart test/scan_review_widget_test.dart test/reports_screen_test.dart
```

Expected: only the intended app-correctness/privacy files are changed.

- [ ] **Step 4: Request code review before moving to sub-project 2**

Run:

```bash
git rev-parse HEAD~3
git rev-parse HEAD
```

Then use the `superpowers:requesting-code-review` workflow with:

```text
WHAT_WAS_IMPLEMENTED: Payment balance delta handling, no pre-confirm import persistence, full-history reports with date-range filtering
PLAN_OR_REQUIREMENTS: docs/superpowers/specs/2026-04-29-app-correctness-privacy-fixes-design.md and this implementation plan
DESCRIPTION: Launch-hardening fixes for app correctness and privacy
```

Expected: review feedback captured and addressed before starting the backend-hardening sub-project.
