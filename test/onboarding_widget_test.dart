import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/onboarding/presentation/onboarding_screen.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

void main() {
  testWidgets('onboarding advances from intro slides into setup flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(
            _FakePreferencesRepository(),
          ),
        ],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    expect(find.text('DEBT DESTROYER'), findsOneWidget);
    expect(find.text('Track debt without the data-entry drag'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Stay private by default'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(
      find.text('Choose a payoff path that fits real life'),
      findsOneWidget,
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Local-first setup'), findsOneWidget);
  });
}

class _FakePreferencesRepository implements PreferencesRepository {
  UserPreferences value = UserPreferences.defaults();

  @override
  Future<UserPreferences> loadPreferences() async => value;

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    value = preferences;
  }

  @override
  Stream<UserPreferences> watchPreferences() async* {
    yield value;
  }
}
