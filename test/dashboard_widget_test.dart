import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:debt_destroyer/shared/models/dashboard_snapshot.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/payment.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('dashboard shows empty state when there are no debts', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardSnapshotProvider.overrideWith(
            (_) => const AsyncValue.data(
              DashboardSnapshot(
                totalOutstandingDebt: 0,
                totalPaidSoFar: 0,
                monthlyMinimumTotal: 0,
                projectedDebtFreeDate: null,
                interestExpected: 0,
                interestSavedVsBaseline: 0,
                upcomingDueDebts: [],
                recentPayments: [],
                mixedCurrency: false,
              ),
            ),
          ),
          userPreferencesProvider.overrideWith(
            (_) => Stream.value(UserPreferences.defaults()),
          ),
          debtsProvider.overrideWith((_) => Stream.value(const <Debt>[])),
        ],
        child: const MaterialApp(home: HomeDashboardScreen()),
      ),
    );

    await tester.pump();
    expect(find.text('No debts yet'), findsOneWidget);
    expect(find.text('Add debt'), findsOneWidget);
  });

  testWidgets('dashboard shows loaded metrics', (tester) async {
    final debt = buildTestDebt(
      id: '1',
      originalBalance: 5000,
      currentBalance: 3200,
      minimumPayment: 125,
      dueDate: DateTime(2026, 3, 20),
    );
    final payment = buildTestPayment(
      id: 'p1',
      debtId: '1',
      amount: 200,
      date: DateTime(2026, 3, 2),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardSnapshotProvider.overrideWith(
            (_) => AsyncValue.data(
              DashboardSnapshot(
                totalOutstandingDebt: 3200,
                totalPaidSoFar: 1800,
                monthlyMinimumTotal: 125,
                projectedDebtFreeDate: DateTime(2028, 2, 1),
                interestExpected: 410,
                interestSavedVsBaseline: 0,
                upcomingDueDebts: [debt],
                recentPayments: [payment],
                mixedCurrency: false,
              ),
            ),
          ),
          userPreferencesProvider.overrideWith(
            (_) => Stream.value(UserPreferences.defaults()),
          ),
          debtsProvider.overrideWith((_) => Stream.value([debt])),
        ],
        child: const MaterialApp(home: HomeDashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Total outstanding'), findsOneWidget);
    expect(find.textContaining('\$3,200'), findsOneWidget);
    expect(find.text('Projected debt-free'), findsOneWidget);
    expect(find.text('Interest horizon'), findsOneWidget);
  });

  testWidgets('dashboard masks balances when privacy mode is enabled', (
    tester,
  ) async {
    final debt = buildTestDebt(
      id: 'masked',
      originalBalance: 5000,
      currentBalance: 3200,
      minimumPayment: 125,
      dueDate: DateTime(2026, 3, 20),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardSnapshotProvider.overrideWith(
            (_) => AsyncValue.data(
              DashboardSnapshot(
                totalOutstandingDebt: 3200,
                totalPaidSoFar: 1800,
                monthlyMinimumTotal: 125,
                projectedDebtFreeDate: DateTime(2028, 2, 1),
                interestExpected: 410,
                interestSavedVsBaseline: 0,
                upcomingDueDebts: [debt],
                recentPayments: const <Payment>[],
                mixedCurrency: false,
              ),
            ),
          ),
          userPreferencesProvider.overrideWith(
            (_) => Stream.value(buildTestPreferences(hideBalances: true)),
          ),
          debtsProvider.overrideWith((_) => Stream.value([debt])),
        ],
        child: const MaterialApp(home: HomeDashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('••••'), findsWidgets);
    expect(find.textContaining('\$3,200'), findsNothing);
  });
}
