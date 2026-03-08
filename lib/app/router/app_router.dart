import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth_lock/presentation/biometric_unlock_screen.dart';
import '../../features/dashboard/presentation/home_dashboard_screen.dart';
import '../../features/debts/presentation/debts_screens.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/scan_import/domain/import_services.dart';
import '../../features/scan_import/presentation/scan_screens.dart';
import '../../features/settings/presentation/data_protection_screens.dart';
import '../../features/settings/presentation/settings_screens.dart';
import '../../features/strategy/presentation/strategy_simulator_screen.dart';
import '../../shared/models/import_models.dart';

GoRouter buildRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/unlock',
        builder: (_, __) => const BiometricUnlockScreen(),
      ),
      GoRoute(
        path: '/privacy-upgrade',
        builder: (_, __) => const PrivacyUpgradeScreen(),
      ),
      GoRoute(
        path: '/data-protection-recovery',
        builder: (_, __) => const DataProtectionRecoveryScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, __) => const HomeDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/debts',
                builder: (_, __) => const DebtsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                builder: (_, __) => const ScanImportHubScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/strategy',
                builder: (_, __) => const StrategySimulatorScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/debts/add',
        builder: (_, __) => const AddEditDebtScreen(),
      ),
      GoRoute(
        path: '/debts/:id',
        builder: (_, state) =>
            DebtDetailsScreen(debtId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/debts/:id/edit',
        builder: (_, state) =>
            EditDebtLoaderScreen(debtId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/debts/:id/add-payment',
        builder: (_, state) =>
            AddPaymentScreen(debtId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/debts/:id/payments',
        builder: (_, state) =>
            PaymentHistoryScreen(debtId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/scan/camera',
        builder: (_, __) => const CameraCaptureScreen(),
      ),
      GoRoute(
        path: '/scan/processing',
        builder: (_, state) => OCRProcessingScreen(
          fileReference: state.extra! as FileReference,
          allowCloud: state.uri.queryParameters['cloud'] == 'true',
        ),
      ),
      GoRoute(
        path: '/scan/review',
        builder: (_, state) => ParsedReviewConfirmScreen(
          bundle: state.extra! as ImportReviewBundle,
        ),
      ),
      GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
      GoRoute(path: '/premium', builder: (_, __) => const PremiumScreen()),
      GoRoute(
        path: '/security',
        builder: (_, __) => const SecurityPrivacyScreen(),
      ),
      GoRoute(path: '/help', builder: (_, __) => const HelpAboutScreen()),
    ],
  );
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Debts',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            label: 'Strategy',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
