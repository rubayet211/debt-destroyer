import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../shared/enums/app_enums.dart';
import '../../shared/models/debt.dart';
import '../../shared/models/subscription_state.dart';

abstract class AnalyticsService {
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  });
}

class NoopAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {}
}

abstract class CrashReporter {
  Future<void> recordError(Object error, StackTrace stackTrace);
}

class NoopCrashReporter implements CrashReporter {
  @override
  Future<void> recordError(Object error, StackTrace stackTrace) async {}
}

class AuthResult {
  const AuthResult({required this.outcome, this.message});

  const AuthResult.success() : outcome = AuthOutcome.success, message = null;

  final AuthOutcome outcome;
  final String? message;

  bool get isSuccess => outcome == AuthOutcome.success;
}

class BiometricAuthService {
  const BiometricAuthService(this._localAuth);

  final LocalAuthentication _localAuth;

  Future<AuthResult> authenticate() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        return const AuthResult(
          outcome: AuthOutcome.unavailable,
          message: 'Device authentication is not available on this device.',
        );
      }
      final success = await _localAuth.authenticate(
        localizedReason: 'Unlock DEBT DESTROYER',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return success
          ? const AuthResult.success()
          : const AuthResult(
              outcome: AuthOutcome.cancelled,
              message: 'Authentication was cancelled.',
            );
    } on PlatformException catch (error) {
      return switch (error.code) {
        'NotAvailable' ||
        'PasscodeNotSet' ||
        'NotEnrolled' ||
        'NoBiometricHardware' ||
        'NoHardware' ||
        'NoCredentials' => const AuthResult(
          outcome: AuthOutcome.unavailable,
          message:
              'Device authentication is unavailable. Add a screen lock or biometrics in system settings.',
        ),
        'LockedOut' || 'TemporaryLockout' => const AuthResult(
          outcome: AuthOutcome.temporaryLockout,
          message:
              'Authentication is temporarily locked. Wait a moment, then try again.',
        ),
        'PermanentlyLockedOut' || 'BiometricLockout' => const AuthResult(
          outcome: AuthOutcome.permanentLockout,
          message:
              'Biometrics are locked. Unlock your device first, then try again.',
        ),
        'UserCanceled' || 'SystemCanceled' || 'Timeout' => const AuthResult(
          outcome: AuthOutcome.cancelled,
          message: 'Authentication was not completed.',
        ),
        _ => AuthResult(
          outcome: AuthOutcome.error,
          message: error.message ?? 'Authentication failed.',
        ),
      };
    } catch (_) {
      return const AuthResult(
        outcome: AuthOutcome.error,
        message: 'Authentication failed.',
      );
    }
  }
}

class ReminderScheduler {
  ReminderScheduler(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notifications.initialize(settings);
  }

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> syncDebtReminders(Debt debt, bool notificationsEnabled) async {
    await cancelDebtReminders(debt.id);
    if (!notificationsEnabled ||
        !debt.remindersEnabled ||
        debt.dueDate == null) {
      return;
    }
    final dueSoon = tz.TZDateTime.from(
      DateTime(
        debt.dueDate!.year,
        debt.dueDate!.month,
        debt.dueDate!.day,
        9,
      ).subtract(const Duration(days: 2)),
      tz.local,
    );
    final dueToday = tz.TZDateTime.from(
      DateTime(debt.dueDate!.year, debt.dueDate!.month, debt.dueDate!.day, 9),
      tz.local,
    );

    await _notifications.zonedSchedule(
      debt.id.hashCode,
      'Payment due soon',
      '${debt.title} is due in 2 days.',
      dueSoon,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'due_soon',
          'Due Soon',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    await _notifications.zonedSchedule(
      debt.id.hashCode + 1,
      'Payment due today',
      '${debt.title} is due today.',
      dueToday,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'due_today',
          'Due Today',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelDebtReminders(String debtId) async {
    await _notifications.cancel(debtId.hashCode);
    await _notifications.cancel(debtId.hashCode + 1);
  }
}

class PremiumService {
  const PremiumService();

  bool guard(SubscriptionState state, PremiumFeature feature) {
    return state.hasFeature(feature);
  }
}

class CsvExportService {
  Future<void> shareCsv(String path) {
    return SharePlus.instance.share(ShareParams(files: [XFile(path)]));
  }
}
