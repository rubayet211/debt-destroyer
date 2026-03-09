import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/settings/presentation/settings_screens.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

void main() {
  testWidgets('notification settings renders new reminder controls', (
    tester,
  ) async {
    final repository = _FakePreferencesRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(repository),
          userPreferencesProvider.overrideWith(
            (ref) => Stream.value(repository.current),
          ),
          notificationPermissionProvider.overrideWith((ref) async => true),
        ],
        child: const MaterialApp(home: NotificationSettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsNWidgets(2));
    expect(find.text('Due reminders'), findsOneWidget);
    expect(find.text('Overdue reminders'), findsOneWidget);
    expect(find.text('Milestone notifications'), findsOneWidget);
    expect(find.text('Weekly progress summary'), findsOneWidget);
    expect(find.text('Lead time'), findsOneWidget);
  });

  testWidgets('toggling due reminders saves preferences', (tester) async {
    final repository = _FakePreferencesRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(repository),
          userPreferencesProvider.overrideWith(
            (ref) => Stream.value(repository.current),
          ),
          notificationPermissionProvider.overrideWith((ref) async => true),
        ],
        child: const MaterialApp(home: NotificationSettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Due reminders'));
    await tester.pumpAndSettle();

    expect(repository.saved.last.dueRemindersEnabled, isFalse);
  });
}

class _FakePreferencesRepository implements PreferencesRepository {
  UserPreferences current = UserPreferences.defaults();
  final List<UserPreferences> saved = [];

  @override
  Future<UserPreferences> loadPreferences() async => current;

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    current = preferences;
    saved.add(preferences);
  }

  @override
  Stream<UserPreferences> watchPreferences() => Stream.value(current);
}
