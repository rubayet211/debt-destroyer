import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';

import 'package:debt_destroyer/core/services/app_services.dart';
import 'package:debt_destroyer/core/services/security_services.dart';
import 'package:debt_destroyer/core/services/vault_services.dart';
import 'package:debt_destroyer/features/auth_lock/presentation/biometric_unlock_screen.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

void main() {
  testWidgets('unlock pane invokes callback on successful unlock', (
    tester,
  ) async {
    var unlocked = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSecurityCoordinatorProvider.overrideWith(
            (_) => _FakeAppSecurityCoordinator(const AuthResult.success()),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: UnlockPane(
              isFullscreen: false,
              onUnlocked: () => unlocked = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(unlocked, isTrue);
    expect(find.text('Authentication failed.'), findsNothing);
  });

  testWidgets('unlock pane shows calm cancelled message', (tester) async {
    await _pumpUnlockPane(
      tester,
      const AuthResult(outcome: AuthOutcome.cancelled),
    );

    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(find.text('Authentication was not completed.'), findsOneWidget);
  });

  testWidgets('unlock pane shows unavailable auth message', (tester) async {
    await _pumpUnlockPane(
      tester,
      const AuthResult(outcome: AuthOutcome.unavailable),
    );

    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(
      find.text('Device authentication is unavailable on this device.'),
      findsOneWidget,
    );
  });

  testWidgets('unlock pane shows temporary lockout guidance', (tester) async {
    await _pumpUnlockPane(
      tester,
      const AuthResult(outcome: AuthOutcome.temporaryLockout),
    );

    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(
      find.text('Authentication is temporarily locked. Try again shortly.'),
      findsOneWidget,
    );
  });

  testWidgets('unlock pane shows permanent lockout guidance', (tester) async {
    await _pumpUnlockPane(
      tester,
      const AuthResult(outcome: AuthOutcome.permanentLockout),
    );

    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(
      find.text('Biometrics are locked. Unlock your device, then return here.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpUnlockPane(WidgetTester tester, AuthResult result) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSecurityCoordinatorProvider.overrideWith(
          (_) => _FakeAppSecurityCoordinator(result),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: UnlockPane(isFullscreen: false)),
      ),
    ),
  );
}

class _FakeAppSecurityCoordinator extends AppSecurityCoordinator {
  _FakeAppSecurityCoordinator(this._result)
    : super(
        sessionStore: AppSecuritySessionStore(),
        protectionService: const SensitiveScreenProtectionService(),
        routeRegistry: const SensitiveRouteRegistry(),
        biometricAuthService: _StaticBiometricAuthService(_result),
      );

  final AuthResult _result;

  @override
  Future<AuthResult> unlock() async => _result;
}

class _StaticBiometricAuthService extends BiometricAuthService {
  _StaticBiometricAuthService(this._result) : super(LocalAuthentication());

  final AuthResult _result;

  @override
  Future<AuthResult> authenticate() async => _result;
}
