import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/strategy/presentation/adjust_plan_sheet.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('previews and applies payoff plan changes', (tester) async {
    final debtsRepository = _FakeDebtsRepository([
      buildTestDebt(
        id: 'card',
        title: 'Rewards card',
        currentBalance: 4200,
        apr: 24,
        minimumPayment: 120,
      ),
      buildTestDebt(
        id: 'loan',
        title: 'Personal loan',
        currentBalance: 1800,
        apr: 8,
        minimumPayment: 80,
      ),
    ]);
    final preferencesRepository = _FakePreferencesRepository(
      UserPreferences.defaults(),
    );

    await tester.pumpAdjustPlanSheet(
      debtsRepository: debtsRepository,
      preferencesRepository: preferencesRepository,
    );

    expect(find.text('Adjust payoff plan'), findsOneWidget);
    expect(find.text('Monthly extra payment'), findsOneWidget);
    expect(find.text('One-time extra payment'), findsOneWidget);
    await tester.tap(find.text('Snowball'));
    await tester.enterText(
      find.byKey(const ValueKey('monthly-extra-input')),
      '150',
    );
    await tester.enterText(
      find.byKey(const ValueKey('one-time-extra-input')),
      '300',
    );
    await tester.scrollUntilVisible(
      find.text('Pause payoff focus'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Pause payoff focus'), findsOneWidget);
    await tester.tap(find.text('Rewards card'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Instant preview'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Instant preview'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Apply changes'),
      500,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.text('Apply changes'));
    await tester.pumpAndSettle();

    expect(
      preferencesRepository.saved.single.defaultStrategy,
      StrategyType.snowball,
    );
    expect(preferencesRepository.saved.single.planExtraMonthlyPayment, 150);
    expect(preferencesRepository.saved.single.planOneTimeExtraPayment, 300);
    expect(
      debtsRepository.saved.lastWhere((debt) => debt.id == 'card').planPaused,
      isTrue,
    );
    expect(find.text('Plan updated'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpAdjustPlanSheet({
    required _FakeDebtsRepository debtsRepository,
    required _FakePreferencesRepository preferencesRepository,
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: [
          debtsProvider.overrideWith((_) => debtsRepository.watchDebts()),
          debtsRepositoryProvider.overrideWithValue(debtsRepository),
          userPreferencesProvider.overrideWith(
            (_) => preferencesRepository.watchPreferences(),
          ),
          preferencesRepositoryProvider.overrideWithValue(
            preferencesRepository,
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: AdjustPlanSheet())),
      ),
    ).then((_) => pumpAndSettle());
  }
}

class _FakeDebtsRepository implements DebtsRepository {
  _FakeDebtsRepository(this._debts);

  List<Debt> _debts;
  final saved = <Debt>[];
  final _controller = StreamController<List<Debt>>.broadcast();

  @override
  Future<void> archiveDebt(String id) async {}

  @override
  Future<void> deleteDebt(String id) async {}

  @override
  Future<List<Debt>> loadDebts({bool includeArchived = false}) async => _debts;

  @override
  Future<void> markPaidOff(String id) async {}

  @override
  Future<void> restoreDebt(String id) async {}

  @override
  Future<void> saveDebt(Debt debt) async {
    saved.add(debt);
    _debts = [
      for (final existing in _debts)
        if (existing.id == debt.id) debt else existing,
    ];
    _controller.add(_debts);
  }

  @override
  Stream<Debt?> watchDebt(String id) => watchDebts().map((debts) {
    for (final debt in debts) {
      if (debt.id == id) {
        return debt;
      }
    }
    return null;
  });

  @override
  Stream<List<Debt>> watchDebts({bool includeArchived = false}) async* {
    yield _debts;
    yield* _controller.stream;
  }
}

class _FakePreferencesRepository implements PreferencesRepository {
  _FakePreferencesRepository(this._preferences);

  UserPreferences _preferences;
  final saved = <UserPreferences>[];
  final _controller = StreamController<UserPreferences>.broadcast();

  @override
  Future<UserPreferences> loadPreferences() async => _preferences;

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    _preferences = preferences;
    saved.add(preferences);
    _controller.add(preferences);
  }

  @override
  Stream<UserPreferences> watchPreferences() async* {
    yield _preferences;
    yield* _controller.stream;
  }
}
