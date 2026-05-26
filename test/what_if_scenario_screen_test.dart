import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/strategy/presentation/what_if_scenario_screen.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/strategy_models.dart';
import 'package:debt_destroyer/shared/models/subscription_state.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('compares the current plan with an extra payment scenario', (
    tester,
  ) async {
    await tester.pumpWhatIfPlanner(
      debts: [
        buildTestDebt(
          id: 'card',
          title: 'Rewards card',
          currentBalance: 4500,
          apr: 22,
          minimumPayment: 130,
        ),
        buildTestDebt(
          id: 'loan',
          title: 'Personal loan',
          currentBalance: 2500,
          apr: 9,
          minimumPayment: 90,
        ),
      ],
    );

    expect(find.text('What If Planner'), findsOneWidget);
    expect(find.text('Original plan'), findsOneWidget);
    expect(find.text('New scenario'), findsOneWidget);
    expect(find.text('New debt-free date'), findsOneWidget);
    expect(find.text('Total interest saved'), findsOneWidget);
    expect(find.text('Months saved'), findsOneWidget);
    expect(find.text('+\$100'), findsOneWidget);
    expect(find.text('+\$200'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Apply to my plan'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Apply to my plan'), findsOneWidget);
  });

  testWidgets('saves a favorite scenario and applies its extra payment', (
    tester,
  ) async {
    final preferencesRepository = _FakePreferencesRepository(
      UserPreferences.defaults(),
    );
    final scenariosRepository = _FakeScenariosRepository();

    await tester.pumpWhatIfPlanner(
      debts: [
        buildTestDebt(
          id: 'card',
          title: 'Rewards card',
          currentBalance: 4500,
          apr: 22,
          minimumPayment: 130,
        ),
      ],
      preferencesRepository: preferencesRepository,
      scenariosRepository: scenariosRepository,
      subscription: SubscriptionState.free().copyWith(
        isPremium: true,
        unlockedFeatures: {PremiumFeature.scenarioSaving},
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
    );

    await tester.tap(find.text('+\$200'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Save favorite'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save favorite'));
    await tester.pumpAndSettle();
    expect(find.text('Scenario saved'), findsOneWidget);

    await tester.tap(find.text('Apply to my plan'));
    await tester.pumpAndSettle();

    expect(scenariosRepository.saved.single.extraPayment, 200);
    expect(preferencesRepository.saved.single.planExtraMonthlyPayment, 200);
    expect(find.text('Scenario applied to your plan'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpWhatIfPlanner({
    required List<Debt> debts,
    _FakePreferencesRepository? preferencesRepository,
    _FakeScenariosRepository? scenariosRepository,
    SubscriptionState? subscription,
  }) {
    final preferences =
        preferencesRepository ??
        _FakePreferencesRepository(UserPreferences.defaults());
    return pumpWidget(
      ProviderScope(
        overrides: [
          debtsProvider.overrideWith((_) => Stream.value(debts)),
          userPreferencesProvider.overrideWith(
            (_) => preferences.watchPreferences(),
          ),
          preferencesRepositoryProvider.overrideWithValue(preferences),
          scenariosRepositoryProvider.overrideWithValue(
            scenariosRepository ?? _FakeScenariosRepository(),
          ),
          subscriptionStateProvider.overrideWith(
            (_) => Stream.value(subscription ?? SubscriptionState.free()),
          ),
          entitlementRefreshProvider.overrideWith(
            (_) async => throw UnimplementedError(),
          ),
        ],
        child: const MaterialApp(home: WhatIfScenarioScreen()),
      ),
    ).then((_) => pumpAndSettle());
  }
}

class _FakePreferencesRepository implements PreferencesRepository {
  _FakePreferencesRepository(this._preferences);

  UserPreferences _preferences;
  final saved = <UserPreferences>[];

  @override
  Future<UserPreferences> loadPreferences() async => _preferences;

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    _preferences = preferences;
    saved.add(preferences);
  }

  @override
  Stream<UserPreferences> watchPreferences() => Stream.value(_preferences);
}

class _FakeScenariosRepository implements ScenariosRepository {
  final saved = <Scenario>[];
  final _controller = StreamController<List<Scenario>>.broadcast();

  @override
  Future<void> deleteScenario(String scenarioId) async {}

  @override
  Future<void> saveScenario(Scenario scenario) async {
    saved.add(scenario);
    _controller.add(saved);
  }

  @override
  Stream<List<Scenario>> watchScenarios() => _controller.stream;
}
