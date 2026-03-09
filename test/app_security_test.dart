import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';

import 'package:debt_destroyer/core/services/app_services.dart';
import 'package:debt_destroyer/core/services/security_services.dart';
import 'package:debt_destroyer/core/services/vault_services.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('relock policy respects immediate and timeout-based settings', () {
    const policy = AppSecuritySessionPolicy();
    final now = DateTime(2026, 3, 10, 12);

    expect(
      policy.shouldRelock(
        timeout: AppRelockTimeout.immediate,
        backgroundedAt: now.subtract(const Duration(seconds: 1)),
        now: now,
      ),
      isTrue,
    );
    expect(
      policy.shouldRelock(
        timeout: AppRelockTimeout.seconds30,
        backgroundedAt: now.subtract(const Duration(seconds: 29)),
        now: now,
      ),
      isFalse,
    );
    expect(
      policy.shouldRelock(
        timeout: AppRelockTimeout.minutes5,
        backgroundedAt: now.subtract(const Duration(minutes: 5)),
        now: now,
      ),
      isTrue,
    );
  });

  test('coordinator relocks on resume after timeout is exceeded', () async {
    final sessionStore = AppSecuritySessionStore();
    final protectionService = _FakeSensitiveScreenProtectionService();
    final coordinator = AppSecurityCoordinator(
      sessionStore: sessionStore,
      protectionService: protectionService,
      routeRegistry: const SensitiveRouteRegistry(),
      biometricAuthService: _FakeBiometricAuthService(
        const AuthResult.success(),
      ),
    );

    await coordinator.syncPreferences(
      UserPreferences.defaults().copyWith(
        appLockEnabled: true,
        relockTimeout: AppRelockTimeout.seconds30,
      ),
    );
    await coordinator.unlock();
    await sessionStore.recordBackground(
      DateTime.now().subtract(const Duration(seconds: 31)),
    );

    await coordinator.handleLifecycleChange(AppLifecycleState.resumed);

    expect(coordinator.state.isLockRequired, isTrue);
    expect(coordinator.state.isUnlocked, isFalse);
    expect(coordinator.state.showPrivacyShield, isTrue);
  });

  test(
    'coordinator keeps session unlocked when resume is within timeout',
    () async {
      final sessionStore = AppSecuritySessionStore();
      final coordinator = AppSecurityCoordinator(
        sessionStore: sessionStore,
        protectionService: _FakeSensitiveScreenProtectionService(),
        routeRegistry: const SensitiveRouteRegistry(),
        biometricAuthService: _FakeBiometricAuthService(
          const AuthResult.success(),
        ),
      );

      await coordinator.syncPreferences(
        UserPreferences.defaults().copyWith(
          appLockEnabled: true,
          relockTimeout: AppRelockTimeout.minutes5,
        ),
      );
      await coordinator.unlock();
      await sessionStore.recordBackground(
        DateTime.now().subtract(const Duration(minutes: 2)),
      );

      await coordinator.handleLifecycleChange(AppLifecycleState.resumed);

      expect(coordinator.state.isUnlocked, isTrue);
      expect(coordinator.state.isLockRequired, isFalse);
      expect(coordinator.state.showPrivacyShield, isFalse);
    },
  );

  test('coordinator applies sensitive-screen protection by route', () async {
    final protectionService = _FakeSensitiveScreenProtectionService();
    final coordinator = AppSecurityCoordinator(
      sessionStore: AppSecuritySessionStore(),
      protectionService: protectionService,
      routeRegistry: const SensitiveRouteRegistry(),
      biometricAuthService: _FakeBiometricAuthService(
        const AuthResult.success(),
      ),
    );

    await coordinator.syncPreferences(UserPreferences.defaults());
    await coordinator.updateRoute('/dashboard');
    expect(protectionService.lastEnabled, isTrue);

    await coordinator.updateRoute('/premium');
    expect(protectionService.lastEnabled, isFalse);
  });

  test(
    'protected preferences persist security settings in secure storage',
    () async {
      final store = ProtectedPreferencesStore();
      final legacy = UserPreferences.defaults().copyWith(
        hideBalances: true,
        appLockEnabled: true,
        aiConsentEnabled: true,
        relockTimeout: AppRelockTimeout.minutes5,
        screenshotProtectionEnabled: false,
        privacyShieldOnAppSwitcherEnabled: false,
      );

      await store.migrateFromLegacy(legacy);
      final merged = await store.mergeInto(UserPreferences.defaults());

      expect(merged.hideBalances, isTrue);
      expect(merged.appLockEnabled, isTrue);
      expect(merged.aiConsentEnabled, isTrue);
      expect(merged.relockTimeout, AppRelockTimeout.minutes5);
      expect(merged.screenshotProtectionEnabled, isFalse);
      expect(merged.privacyShieldOnAppSwitcherEnabled, isFalse);
    },
  );
}

class _FakeBiometricAuthService extends BiometricAuthService {
  _FakeBiometricAuthService(this._result) : super(LocalAuthentication());

  final AuthResult _result;

  @override
  Future<AuthResult> authenticate() async => _result;
}

class _FakeSensitiveScreenProtectionService
    extends SensitiveScreenProtectionService {
  bool? lastEnabled;

  @override
  Future<void> setSecureScreenEnabled(bool enabled) async {
    lastEnabled = enabled;
  }
}
