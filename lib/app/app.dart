import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth_lock/presentation/biometric_unlock_screen.dart';
import '../shared/enums/app_enums.dart';
import '../shared/models/debt.dart';
import '../shared/models/payment.dart';
import '../shared/models/user_preferences.dart';
import '../shared/providers/app_providers.dart';
import 'theme/app_theme.dart';

class DebtDestroyerApp extends ConsumerStatefulWidget {
  const DebtDestroyerApp({super.key});

  @override
  ConsumerState<DebtDestroyerApp> createState() => _DebtDestroyerAppState();
}

class _DebtDestroyerAppState extends ConsumerState<DebtDestroyerApp>
    with WidgetsBindingObserver {
  late final GoRouter _router;
  late final ProviderSubscription<AsyncValue<UserPreferences>>
  _preferencesSubscription;
  late final ProviderSubscription<AsyncValue<List<Debt>>> _debtsSubscription;
  late final ProviderSubscription<AsyncValue<List<Payment>>>
  _paymentsSubscription;
  Timer? _reminderReconcileDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = ref.read(appRouterProvider);
    _router.routerDelegate.addListener(_handleRouteChanged);
    _preferencesSubscription = ref.listenManual(userPreferencesProvider, (
      _,
      next,
    ) {
      next.whenData((preferences) {
        unawaited(
          ref
              .read(appSecurityCoordinatorProvider.notifier)
              .syncPreferences(preferences),
        );
        _scheduleReminderReconcile();
      });
    });
    _debtsSubscription = ref.listenManual(allDebtsProvider, (_, next) {
      if (next.hasValue) {
        _scheduleReminderReconcile();
      }
    });
    _paymentsSubscription = ref.listenManual(recentPaymentsProvider, (_, next) {
      if (next.hasValue) {
        _scheduleReminderReconcile();
      }
    });
    final initialPreferences = ref.read(userPreferencesProvider);
    initialPreferences.whenData((preferences) {
      unawaited(
        ref
            .read(appSecurityCoordinatorProvider.notifier)
            .syncPreferences(preferences),
      );
      _scheduleReminderReconcile();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRouteChanged());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.routerDelegate.removeListener(_handleRouteChanged);
    _preferencesSubscription.close();
    _debtsSubscription.close();
    _paymentsSubscription.close();
    _reminderReconcileDebounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(
      ref
          .read(appSecurityCoordinatorProvider.notifier)
          .handleLifecycleChange(state),
    );
  }

  void _handleRouteChanged() {
    final location = _router.routeInformationProvider.value.uri.path;
    unawaited(
      ref.read(appSecurityCoordinatorProvider.notifier).updateRoute(location),
    );
  }

  void _scheduleReminderReconcile() {
    _reminderReconcileDebounce?.cancel();
    _reminderReconcileDebounce = Timer(const Duration(milliseconds: 200), () {
      final preferences = ref.read(userPreferencesProvider).valueOrNull;
      final debts = ref.read(allDebtsProvider).valueOrNull;
      final payments = ref.read(recentPaymentsProvider).valueOrNull ?? const [];
      if (preferences == null || debts == null) {
        return;
      }
      unawaited(
        ref
            .read(reminderOrchestratorProvider)
            .reconcile(
              preferences: preferences,
              debts: debts,
              recentPayments: payments,
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(userPreferencesProvider).valueOrNull;
    final themeMode = preferences?.themeMode.toThemeMode() ?? ThemeMode.system;
    final security = ref.watch(appSecurityCoordinatorProvider);

    return MaterialApp.router(
      title: 'DEBT DESTROYER',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (security.showPrivacyShield)
              const Positioned.fill(child: _PrivacyShieldOverlay()),
            if (security.isLockRequired &&
                security.currentRoute != '/unlock' &&
                security.currentRoute != '/onboarding' &&
                security.currentRoute != '/')
              const Positioned.fill(child: _LockOverlay()),
          ],
        );
      },
    );
  }
}

class _PrivacyShieldOverlay extends StatelessWidget {
  const _PrivacyShieldOverlay();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surface.withValues(alpha: 0.97);
    return ColoredBox(
      color: color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_moon_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Privacy shield active',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LockOverlay extends StatelessWidget {
  const _LockOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const UnlockPane(isFullscreen: false),
            ),
          ),
        ),
      ),
    );
  }
}
