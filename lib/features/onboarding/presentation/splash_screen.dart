import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../shared/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_resolve);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoadingPane(message: 'Preparing your debt workspace...'),
    );
  }

  Future<void> _resolve() async {
    final protection = await ref.read(dataProtectionBootstrapProvider.future);
    if (!mounted) {
      return;
    }
    if (!protection.ready) {
      context.go('/data-protection-recovery');
      return;
    }
    if (protection.showUpgradeExplainer) {
      context.go('/privacy-upgrade');
      return;
    }
    final prefs = await ref
        .read(preferencesRepositoryProvider)
        .loadPreferences();
    await ref
        .read(appSecurityCoordinatorProvider.notifier)
        .syncPreferences(prefs);
    if (!mounted) {
      return;
    }
    if (!prefs.onboardingCompleted) {
      context.go('/onboarding');
      return;
    }
    final security = ref.read(appSecurityCoordinatorProvider);
    if (prefs.appLockEnabled && security.isLockRequired) {
      context.go('/unlock');
      return;
    }
    context.go('/dashboard');
  }
}
