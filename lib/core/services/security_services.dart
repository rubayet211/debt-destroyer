import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/user_preferences.dart';
import 'app_services.dart';
import 'vault_services.dart';

class AppSecurityState {
  const AppSecurityState({
    required this.isInitialized,
    required this.isUnlocked,
    required this.isLockRequired,
    required this.showPrivacyShield,
    required this.isSensitiveRoute,
    required this.currentRoute,
    required this.lifecycleState,
    required this.lastUnlockedAt,
    required this.lastBackgroundedAt,
  });

  factory AppSecurityState.initial() {
    return const AppSecurityState(
      isInitialized: false,
      isUnlocked: false,
      isLockRequired: false,
      showPrivacyShield: false,
      isSensitiveRoute: false,
      currentRoute: '/',
      lifecycleState: AppLifecycleState.resumed,
      lastUnlockedAt: null,
      lastBackgroundedAt: null,
    );
  }

  final bool isInitialized;
  final bool isUnlocked;
  final bool isLockRequired;
  final bool showPrivacyShield;
  final bool isSensitiveRoute;
  final String currentRoute;
  final AppLifecycleState lifecycleState;
  final DateTime? lastUnlockedAt;
  final DateTime? lastBackgroundedAt;

  bool get shouldObscureApp =>
      showPrivacyShield || (isLockRequired && isSensitiveRoute);

  AppSecurityState copyWith({
    bool? isInitialized,
    bool? isUnlocked,
    bool? isLockRequired,
    bool? showPrivacyShield,
    bool? isSensitiveRoute,
    String? currentRoute,
    AppLifecycleState? lifecycleState,
    DateTime? lastUnlockedAt,
    DateTime? lastBackgroundedAt,
  }) {
    return AppSecurityState(
      isInitialized: isInitialized ?? this.isInitialized,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isLockRequired: isLockRequired ?? this.isLockRequired,
      showPrivacyShield: showPrivacyShield ?? this.showPrivacyShield,
      isSensitiveRoute: isSensitiveRoute ?? this.isSensitiveRoute,
      currentRoute: currentRoute ?? this.currentRoute,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
      lastBackgroundedAt: lastBackgroundedAt ?? this.lastBackgroundedAt,
    );
  }
}

class SensitiveRouteRegistry {
  const SensitiveRouteRegistry();

  bool isSensitiveLocation(String location) {
    if (location.startsWith('/dashboard')) {
      return true;
    }
    if (location == '/debts' || location.startsWith('/debts/')) {
      return true;
    }
    if (location.startsWith('/strategy')) {
      return true;
    }
    if (location.startsWith('/reports')) {
      return true;
    }
    if (location == '/security') {
      return true;
    }
    if (location.startsWith('/scan/processing') ||
        location.startsWith('/scan/review')) {
      return true;
    }
    return false;
  }
}

class SensitiveScreenProtectionService {
  const SensitiveScreenProtectionService();

  static const _channel = MethodChannel('debt_destroyer/privacy');

  Future<void> setSecureScreenEnabled(bool enabled) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('setSecureScreenEnabled', {
        'enabled': enabled,
      });
    } on MissingPluginException {
      return;
    }
  }
}

class AppSecuritySessionPolicy {
  const AppSecuritySessionPolicy();

  bool shouldRelock({
    required AppRelockTimeout timeout,
    required DateTime? backgroundedAt,
    required DateTime now,
  }) {
    if (backgroundedAt == null) {
      return false;
    }
    if (timeout == AppRelockTimeout.immediate) {
      return true;
    }
    return now.difference(backgroundedAt) >= timeout.duration;
  }
}

class AppSecurityCoordinator extends StateNotifier<AppSecurityState> {
  AppSecurityCoordinator({
    required this.sessionStore,
    required this.protectionService,
    required this.routeRegistry,
    required this.biometricAuthService,
    AppSecuritySessionPolicy sessionPolicy = const AppSecuritySessionPolicy(),
  }) : _sessionPolicy = sessionPolicy,
       super(AppSecurityState.initial());

  final AppSecuritySessionStore sessionStore;
  final SensitiveScreenProtectionService protectionService;
  final SensitiveRouteRegistry routeRegistry;
  final BiometricAuthService biometricAuthService;
  final AppSecuritySessionPolicy _sessionPolicy;

  UserPreferences _preferences = UserPreferences.defaults();

  Future<void> syncPreferences(UserPreferences preferences) async {
    _preferences = preferences;
    if (!state.isInitialized) {
      final snapshot = await sessionStore.read();
      final canResumeUnlocked =
          preferences.appLockEnabled &&
          snapshot.activeSession &&
          !_sessionPolicy.shouldRelock(
            timeout: preferences.relockTimeout,
            backgroundedAt: snapshot.lastBackgroundedAt,
            now: DateTime.now(),
          );
      state = state.copyWith(
        isInitialized: true,
        isUnlocked: !preferences.appLockEnabled || canResumeUnlocked,
        isLockRequired: preferences.appLockEnabled && !canResumeUnlocked,
        showPrivacyShield: false,
        lastUnlockedAt: snapshot.lastUnlockedAt,
        lastBackgroundedAt: snapshot.lastBackgroundedAt,
      );
    } else if (!preferences.appLockEnabled) {
      await sessionStore.markLocked();
      state = state.copyWith(
        isUnlocked: true,
        isLockRequired: false,
        showPrivacyShield: false,
      );
    } else if (!state.isUnlocked) {
      state = state.copyWith(isLockRequired: true);
    }
    await _applySensitiveProtection();
  }

  Future<AuthResult> unlock() async {
    final result = await biometricAuthService.authenticate();
    if (result.isSuccess) {
      final now = DateTime.now();
      await sessionStore.recordUnlock(now);
      state = state.copyWith(
        isUnlocked: true,
        isLockRequired: false,
        showPrivacyShield: false,
        lastUnlockedAt: now,
      );
      await _applySensitiveProtection();
    }
    return result;
  }

  Future<void> lockNow() async {
    await sessionStore.markLocked();
    state = state.copyWith(
      isUnlocked: false,
      isLockRequired: _preferences.appLockEnabled,
      showPrivacyShield:
          _preferences.appLockEnabled ||
          _preferences.privacyShieldOnAppSwitcherEnabled,
    );
    await _applySensitiveProtection();
  }

  Future<void> handleLifecycleChange(AppLifecycleState lifecycleState) async {
    if (lifecycleState == AppLifecycleState.resumed) {
      final snapshot = await sessionStore.read();
      final shouldRelock =
          _preferences.appLockEnabled &&
          _sessionPolicy.shouldRelock(
            timeout: _preferences.relockTimeout,
            backgroundedAt: snapshot.lastBackgroundedAt,
            now: DateTime.now(),
          );
      if (shouldRelock) {
        await sessionStore.markLocked();
      }
      state = state.copyWith(
        lifecycleState: lifecycleState,
        lastBackgroundedAt: snapshot.lastBackgroundedAt,
        isUnlocked: shouldRelock ? false : state.isUnlocked,
        isLockRequired: shouldRelock ? true : false,
        showPrivacyShield: shouldRelock ? true : false,
      );
      await _applySensitiveProtection();
      return;
    }

    if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.hidden) {
      final now = DateTime.now();
      await sessionStore.recordBackground(now);
      final shouldImmediateLock =
          _preferences.appLockEnabled &&
          _preferences.relockTimeout == AppRelockTimeout.immediate;
      if (shouldImmediateLock) {
        await sessionStore.markLocked();
      }
      state = state.copyWith(
        lifecycleState: lifecycleState,
        lastBackgroundedAt: now,
        isUnlocked: shouldImmediateLock ? false : state.isUnlocked,
        isLockRequired: shouldImmediateLock ? true : false,
        showPrivacyShield: _preferences.privacyShieldOnAppSwitcherEnabled,
      );
      await _applySensitiveProtection();
      return;
    }

    state = state.copyWith(lifecycleState: lifecycleState);
  }

  Future<void> updateRoute(String location) async {
    state = state.copyWith(
      currentRoute: location,
      isSensitiveRoute: routeRegistry.isSensitiveLocation(location),
    );
    await _applySensitiveProtection();
  }

  Future<void> _applySensitiveProtection() async {
    final enabled =
        _preferences.screenshotProtectionEnabled && state.isSensitiveRoute;
    await protectionService.setSecureScreenEnabled(enabled);
  }
}
