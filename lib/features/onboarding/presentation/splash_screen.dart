import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  size: 54,
                  color: AppColors.secondaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'DEBT DESTROYER',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onPrimary,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Take Control.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.72),
                ),
              ),
              const Spacer(flex: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: scheme.secondaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Local-First & Private',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: scheme.onPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 88,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(999),
                  color: scheme.secondaryContainer,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                ),
              ),
            ],
          ),
        ),
      ),
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
