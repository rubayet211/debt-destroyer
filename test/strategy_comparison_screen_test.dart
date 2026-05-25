import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/strategy/presentation/strategy_comparison_screen.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('shows payoff strategies with comparison estimates', (
    tester,
  ) async {
    await tester.pumpStrategyComparisonScreen(
      debts: [
        buildTestDebt(id: 'card', title: 'Rewards card', currentBalance: 2200),
        buildTestDebt(
          id: 'loan',
          title: 'Personal loan',
          currentBalance: 1200,
          apr: 8,
          minimumPayment: 75,
        ),
      ],
    );

    expect(find.text('Strategy comparison'), findsOneWidget);
    expect(find.text('Debt Snowball'), findsOneWidget);
    expect(find.text('Debt Avalanche'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Recommended for me'), findsOneWidget);
    expect(find.text('Total interest paid'), findsWidgets);
    expect(find.text('Months until debt-free'), findsWidgets);
    expect(find.text('Total amount paid'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text(
        'These are estimates based on the information you provided. Actual results may vary.',
      ),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text(
        'These are estimates based on the information you provided. Actual results may vary.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('learn more section expands for a strategy', (tester) async {
    await tester.pumpStrategyComparisonScreen(
      debts: [
        buildTestDebt(id: 'card', title: 'Rewards card', currentBalance: 2200),
      ],
    );

    expect(find.textContaining('Best for staying motivated'), findsNothing);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learn more').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Best for staying motivated'), findsOneWidget);
    expect(find.textContaining('May cost more interest'), findsOneWidget);
  });

  testWidgets('applies selected strategy to current plan preferences', (
    tester,
  ) async {
    final preferencesRepository = _FakePreferencesRepository(
      UserPreferences.defaults(),
    );

    await tester.pumpStrategyComparisonScreen(
      debts: [
        buildTestDebt(
          id: 'small',
          title: 'Store card',
          currentBalance: 300,
          apr: 8,
          minimumPayment: 35,
        ),
        buildTestDebt(
          id: 'large',
          title: 'Rewards card',
          currentBalance: 2600,
          apr: 24,
          minimumPayment: 95,
        ),
      ],
      preferencesRepository: preferencesRepository,
    );

    await tester.tap(find.text('Debt Snowball'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Apply Snowball'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Apply Snowball'));
    await tester.pumpAndSettle();

    expect(
      preferencesRepository.saved.single.defaultStrategy,
      StrategyType.snowball,
    );
    expect(find.text('Snowball applied to your plan'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpStrategyComparisonScreen({
    required List<Debt> debts,
    _FakePreferencesRepository? preferencesRepository,
  }) {
    final repository =
        preferencesRepository ??
        _FakePreferencesRepository(UserPreferences.defaults());
    return pumpWidget(
      ProviderScope(
        overrides: [
          debtsProvider.overrideWith((_) => Stream.value(debts)),
          userPreferencesProvider.overrideWith(
            (_) => repository.watchPreferences(),
          ),
          preferencesRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: StrategyComparisonScreen()),
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
