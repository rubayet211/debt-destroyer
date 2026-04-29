import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:debt_destroyer/core/services/app_services.dart';
import 'package:debt_destroyer/features/reports/presentation/reports_screen.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/billing_models.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/payment.dart';
import 'package:debt_destroyer/shared/models/subscription_state.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('reports screen shows loading state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allDebtsProvider.overrideWith(
            (_) => const Stream<List<Debt>>.empty(),
          ),
          allPaymentsProvider.overrideWith(
            (_) => const Stream<List<Payment>>.empty(),
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

    await tester.pump();
    expect(find.text('Loading reports...'), findsOneWidget);
  });

  testWidgets('reports screen shows repository error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allDebtsProvider.overrideWith(
            (_) => Stream.error('debt load failed'),
          ),
          allPaymentsProvider.overrideWith((_) => Stream.value(const [])),
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
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('debt load failed'), findsOneWidget);
  });

  testWidgets('reports screen shows empty state when there are no debts', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allDebtsProvider.overrideWith((_) => Stream.value(const [])),
          allPaymentsProvider.overrideWith((_) => Stream.value(const [])),
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
    expect(find.text('No reports yet'), findsOneWidget);
  });

  testWidgets('reports screen uses full payment history by default', (
    tester,
  ) async {
    final debt = buildTestDebt(id: 'debt-history', currentBalance: 940);
    final allPayments = [
      buildTestPayment(id: 'payment-1', debtId: debt.id, amount: 120),
      buildTestPayment(
        id: 'payment-2',
        debtId: debt.id,
        amount: 260,
        date: DateTime(2026, 2, 9),
      ),
      buildTestPayment(
        id: 'payment-3',
        debtId: debt.id,
        amount: 400,
        date: DateTime(2026, 1, 9),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allDebtsProvider.overrideWith((_) => Stream.value([debt])),
          allPaymentsProvider.overrideWith((_) => Stream.value(allPayments)),
          recentPaymentsProvider.overrideWith(
            (_) => Stream.value(allPayments.take(1).toList()),
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
    await tester.scrollUntilVisible(
      find.text('Payments tracked'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('\$780.00'), findsOneWidget);
  });

  testWidgets('reports screen filters totals and monthly bars by date range', (
    tester,
  ) async {
    final debt = buildTestDebt(id: 'debt-range', currentBalance: 880);
    final allPayments = [
      buildTestPayment(
        id: 'payment-jan',
        debtId: debt.id,
        amount: 90,
        date: DateTime(2026, 1, 15),
      ),
      buildTestPayment(
        id: 'payment-feb',
        debtId: debt.id,
        amount: 40,
        date: DateTime(2026, 2, 12),
      ),
      buildTestPayment(
        id: 'payment-mar',
        debtId: debt.id,
        amount: 70,
        date: DateTime(2026, 3, 18),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allDebtsProvider.overrideWith((_) => Stream.value([debt])),
          allPaymentsProvider.overrideWith((_) => Stream.value(allPayments)),
          reportsDateRangeProvider.overrideWith(
            (ref) => DateTimeRange(
              start: DateTime(2026, 2, 1),
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
    final chart = tester.widget<BarChart>(find.byType(BarChart).first);
    await tester.scrollUntilVisible(
      find.text('Payments tracked'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('\$110.00'), findsOneWidget);
    expect(chart.data.barGroups, hasLength(2));
    expect(chart.data.barGroups[0].barRods.single.toY, 40);
    expect(chart.data.barGroups[1].barRods.single.toY, 70);
  });

  testWidgets('reports screen exports csv when premium feature is active', (
    tester,
  ) async {
    final csvFile = File(
      '${Directory.systemTemp.path}/reports_export_${DateTime.now().millisecondsSinceEpoch}.csv',
    )..writeAsStringSync('type,id');
    addTearDown(() async {
      if (await csvFile.exists()) {
        await csvFile.delete();
      }
    });
    final csvService = _FakeCsvExportService();
    final debt = buildTestDebt(
      id: 'debt-export',
      dueDate: DateTime(2026, 3, 15),
    );
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const ReportsScreen()),
        GoRoute(
          path: '/premium',
          builder: (_, __) => const Scaffold(body: Text('Premium route')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allDebtsProvider.overrideWith((_) => Stream.value([debt])),
          allPaymentsProvider.overrideWith(
            (_) => Stream.value([buildTestPayment(debtId: debt.id)]),
          ),
          userPreferencesProvider.overrideWith(
            (_) => Stream.value(buildTestPreferences()),
          ),
          subscriptionStateProvider.overrideWith(
            (_) => Stream.value(
              SubscriptionState(
                isPremium: true,
                expiresAt: DateTime.now().add(const Duration(days: 30)),
                unlockedFeatures: const {PremiumFeature.csvExport},
                status: 'active',
                planId: 'yearly',
              ),
            ),
          ),
          entitlementRefreshProvider.overrideWith(
            (_) async => EntitlementSnapshot(
              isPremium: true,
              features: const {PremiumFeature.csvExport},
              validUntil: DateTime.now().add(const Duration(days: 30)),
              status: 'active',
              productId: 'premium',
              planId: 'yearly',
              billingProvider: 'google_play',
              lastVerifiedAt: DateTime.now(),
            ),
          ),
          exportCsvProvider.overrideWith(
            (_) =>
                () async => csvFile,
          ),
          csvExportServiceProvider.overrideWithValue(csvService),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.ios_share_outlined));
    await tester.pumpAndSettle();

    expect(csvService.sharedPaths, [csvFile.path]);
  });

  testWidgets('reports screen routes free users to premium on csv export', (
    tester,
  ) async {
    final debt = buildTestDebt(id: 'debt-free', dueDate: DateTime(2026, 3, 15));
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const ReportsScreen()),
        GoRoute(
          path: '/premium',
          builder: (_, __) => const Scaffold(body: Text('Premium route')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allDebtsProvider.overrideWith((_) => Stream.value([debt])),
          allPaymentsProvider.overrideWith(
            (_) => Stream.value([buildTestPayment(debtId: debt.id)]),
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
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.ios_share_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Premium route'), findsOneWidget);
  });

  testWidgets(
    'reports screen defaults to full payment history from all-payments storage',
    (tester) async {
      final debt = buildTestDebt(
        id: 'debt-history',
        dueDate: DateTime(2026, 3, 15),
      );
      final payments = [
        buildTestPayment(
          id: 'payment-history-1',
          debtId: debt.id,
          amount: 80,
          date: DateTime(2025, 1, 10),
        ),
        buildTestPayment(
          id: 'payment-history-2',
          debtId: debt.id,
          amount: 120,
          date: DateTime(2026, 1, 10),
        ),
        buildTestPayment(
          id: 'payment-history-3',
          debtId: debt.id,
          amount: 60,
          date: DateTime(2026, 2, 10),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allDebtsProvider.overrideWith((_) => Stream.value([debt])),
            allPaymentsProvider.overrideWith((_) => Stream.value(payments)),
            recentPaymentsProvider.overrideWith((_) => Stream.value(const [])),
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
      final monthlyChart = tester.widget<BarChart>(find.byType(BarChart).first);
      await tester.scrollUntilVisible(
        find.text('Payments tracked'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Payments tracked'), findsOneWidget);
      expect(find.text('\$260.00'), findsOneWidget);
      expect(monthlyChart.data.barGroups, hasLength(3));
    },
  );

  testWidgets(
    'reports screen filters totals and monthly chart by selected date range',
    (tester) async {
      final debt = buildTestDebt(
        id: 'debt-range',
        dueDate: DateTime(2026, 3, 15),
      );
      final payments = [
        buildTestPayment(
          id: 'payment-range-1',
          debtId: debt.id,
          amount: 80,
          date: DateTime(2026, 1, 10),
        ),
        buildTestPayment(
          id: 'payment-range-2',
          debtId: debt.id,
          amount: 120,
          date: DateTime(2026, 2, 10),
        ),
        buildTestPayment(
          id: 'payment-range-3',
          debtId: debt.id,
          amount: 60,
          date: DateTime(2026, 3, 10),
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          allDebtsProvider.overrideWith((_) => Stream.value([debt])),
          allPaymentsProvider.overrideWith((_) => Stream.value(payments)),
          recentPaymentsProvider.overrideWith((_) => Stream.value(payments)),
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
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ReportsScreen()),
        ),
      );

      await tester.pumpAndSettle();
      container.read(reportsDateRangeProvider.notifier).state = DateTimeRange(
        start: DateTime(2026, 2, 1),
        end: DateTime(2026, 2, 28),
      );
      await tester.pumpAndSettle();
      final monthlyChart = tester.widget<BarChart>(find.byType(BarChart).first);
      await tester.scrollUntilVisible(
        find.text('Payments tracked'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('\$120.00'), findsOneWidget);
      expect(monthlyChart.data.barGroups, hasLength(1));
      expect(monthlyChart.data.barGroups.single.barRods.single.toY, 120);
    },
  );
}

class _FakeCsvExportService extends CsvExportService {
  final List<String> sharedPaths = [];

  @override
  Future<void> shareCsv(String path) async {
    sharedPaths.add(path);
  }
}
