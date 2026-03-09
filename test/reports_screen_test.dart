import 'dart:io';

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
          recentPaymentsProvider.overrideWith(
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
    expect(find.text('No reports yet'), findsOneWidget);
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
          recentPaymentsProvider.overrideWith(
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
          recentPaymentsProvider.overrideWith(
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
}

class _FakeCsvExportService extends CsvExportService {
  final List<String> sharedPaths = [];

  @override
  Future<void> shareCsv(String path) async {
    sharedPaths.add(path);
  }
}
