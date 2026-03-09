import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../shared/data/repositories.dart';
import '../../shared/enums/app_enums.dart';
import '../../shared/models/debt.dart';
import '../../shared/models/payment.dart';
import '../../shared/models/reminder_models.dart';
import '../../shared/models/subscription_state.dart';
import '../../shared/models/user_preferences.dart';

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

abstract class NotificationGateway {
  Future<void> initialize();
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledAt,
    required NotificationDetails details,
    String? payload,
  });
  Future<void> cancel(int id);
  Future<List<PendingNotificationRequest>> pendingRequests();
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    String? payload,
  });
}

class FlutterLocalNotificationsGateway implements NotificationGateway {
  FlutterLocalNotificationsGateway(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;

  @override
  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notifications.initialize(settings);
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledAt,
    required NotificationDetails details,
    String? payload,
  }) {
    return _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledAt,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) => _notifications.cancel(id);

  @override
  Future<List<PendingNotificationRequest>> pendingRequests() {
    return _notifications.pendingNotificationRequests();
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    String? payload,
  }) {
    return _notifications.show(id, title, body, details, payload: payload);
  }
}

class ReminderPlanBuilder {
  const ReminderPlanBuilder();

  static const bootstrapMarkerKey = 'bootstrap_seeded_v1';
  static const _payloadPrefix = 'debt_destroyer_reminder|';

  ReminderPlan build({
    required UserPreferences preferences,
    required List<Debt> debts,
    required List<Payment> recentPayments,
    required Set<String> existingEventKeys,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final scheduledItems = <ReminderPlanItem>[];
    final milestoneNotifications = <MilestoneNotification>[];
    final activeReminderDebts = debts.where((debt) {
      return debt.status == DebtStatus.active &&
          debt.remindersEnabled &&
          debt.currentBalance > 0;
    }).toList();

    if (preferences.notificationsEnabled) {
      if (preferences.dueRemindersEnabled) {
        scheduledItems.addAll(
          _buildDueReminders(
            activeReminderDebts,
            preferences.dueReminderLeadDays.clamp(1, 3),
            reference,
          ),
        );
      }
      if (preferences.overdueRemindersEnabled) {
        scheduledItems.addAll(
          _buildOverdueReminders(activeReminderDebts, reference),
        );
      }
      if (preferences.weeklySummaryEnabled) {
        final snapshot = _buildWeeklySummarySnapshot(
          debts: debts,
          recentPayments: recentPayments,
          now: reference,
        );
        final nextSummaryAt = _nextWeeklySummary(reference);
        scheduledItems.add(
          ReminderPlanItem(
            key: 'weekly_summary',
            id: ReminderScheduler.notificationIdForKey('weekly_summary'),
            kind: ReminderKind.weeklySummary,
            title: 'Weekly debt progress',
            body:
                '${snapshot.dueThisWeekCount} due this week • ${snapshot.recentPaymentsCount} recent payments • ${snapshot.progressMessage}',
            scheduledAt: nextSummaryAt,
            payload: '${_payloadPrefix}weekly_summary',
          ),
        );
      }
    }

    if (preferences.notificationsEnabled &&
        preferences.milestoneNotificationsEnabled) {
      for (final debt in debts.where((debt) => debt.remindersEnabled)) {
        for (final notification in _buildMilestonesForDebt(
          debt,
          existingEventKeys,
        )) {
          milestoneNotifications.add(notification);
        }
      }
    }

    return ReminderPlan(
      scheduledItems: scheduledItems,
      milestoneNotifications: milestoneNotifications,
    );
  }

  Set<String> achievedMilestoneKeys(List<Debt> debts) {
    final keys = <String>{bootstrapMarkerKey};
    for (final debt in debts.where((debt) => debt.remindersEnabled)) {
      keys.addAll(_achievedMilestoneKeysForDebt(debt));
    }
    return keys;
  }

  List<ReminderPlanItem> _buildDueReminders(
    List<Debt> debts,
    int leadDays,
    DateTime now,
  ) {
    final items = <ReminderPlanItem>[];
    for (final debt in debts) {
      final dueDate = debt.dueDate;
      if (dueDate == null) {
        continue;
      }
      final dueLeadAt = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        9,
      ).subtract(Duration(days: leadDays));
      final dueTodayAt = DateTime(dueDate.year, dueDate.month, dueDate.day, 9);
      if (dueLeadAt.isAfter(now)) {
        items.add(
          ReminderPlanItem(
            key: 'debt|${debt.id}|dueLead|$leadDays',
            id: ReminderScheduler.notificationIdForKey(
              'debt|${debt.id}|dueLead|$leadDays',
            ),
            kind: ReminderKind.dueLead,
            title: 'Payment due soon',
            body:
                '${debt.title} is due in ${leadDays == 1 ? '1 day' : '$leadDays days'}.',
            scheduledAt: dueLeadAt,
            payload: '${_payloadPrefix}debt|${debt.id}|dueLead|$leadDays',
            debtId: debt.id,
          ),
        );
      }
      if (dueTodayAt.isAfter(now)) {
        items.add(
          ReminderPlanItem(
            key: 'debt|${debt.id}|dueToday',
            id: ReminderScheduler.notificationIdForKey(
              'debt|${debt.id}|dueToday',
            ),
            kind: ReminderKind.dueToday,
            title: 'Payment due today',
            body: '${debt.title} is due today.',
            scheduledAt: dueTodayAt,
            payload: '${_payloadPrefix}debt|${debt.id}|dueToday',
            debtId: debt.id,
          ),
        );
      }
    }
    return items;
  }

  List<ReminderPlanItem> _buildOverdueReminders(
    List<Debt> debts,
    DateTime now,
  ) {
    const offsets = [1, 3, 7];
    final items = <ReminderPlanItem>[];
    for (final debt in debts) {
      final dueDate = debt.dueDate;
      if (dueDate == null) {
        continue;
      }
      final base = DateTime(dueDate.year, dueDate.month, dueDate.day, 9);
      for (final offset in offsets) {
        final scheduledAt = base.add(Duration(days: offset));
        if (!scheduledAt.isAfter(now)) {
          continue;
        }
        items.add(
          ReminderPlanItem(
            key: 'debt|${debt.id}|overdue|$offset',
            id: ReminderScheduler.notificationIdForKey(
              'debt|${debt.id}|overdue|$offset',
            ),
            kind: switch (offset) {
              1 => ReminderKind.overdueDay1,
              3 => ReminderKind.overdueDay3,
              _ => ReminderKind.overdueDay7,
            },
            title: offset == 1 ? 'Payment overdue' : 'Debt still overdue',
            body:
                '${debt.title} is now $offset day${offset == 1 ? '' : 's'} overdue.',
            scheduledAt: scheduledAt,
            payload: '${_payloadPrefix}debt|${debt.id}|overdue|$offset',
            debtId: debt.id,
          ),
        );
      }
    }
    return items;
  }

  WeeklySummarySnapshot _buildWeeklySummarySnapshot({
    required List<Debt> debts,
    required List<Payment> recentPayments,
    required DateTime now,
  }) {
    final weekEnd = now.add(const Duration(days: 7));
    final dueThisWeekCount = debts.where((debt) {
      final dueDate = debt.dueDate;
      return debt.status == DebtStatus.active &&
          dueDate != null &&
          !dueDate.isBefore(DateTime(now.year, now.month, now.day)) &&
          !dueDate.isAfter(weekEnd);
    }).length;
    final recentPaymentsCount = recentPayments
        .where(
          (payment) =>
              payment.date.isAfter(now.subtract(const Duration(days: 7))),
        )
        .length;
    final totalOriginal = debts.fold<double>(
      0,
      (sum, debt) => sum + debt.originalBalance,
    );
    final totalCurrent = debts.fold<double>(
      0,
      (sum, debt) => sum + debt.currentBalance,
    );
    final progress = totalOriginal <= 0
        ? 0
        : ((totalOriginal - totalCurrent) / totalOriginal).clamp(0, 1);
    final progressMessage = switch (progress) {
      >= 0.75 => 'you are in the final stretch',
      >= 0.5 => 'you are over halfway there',
      >= 0.25 => 'you are building steady payoff momentum',
      _ => 'keep momentum with your next payment',
    };
    return WeeklySummarySnapshot(
      dueThisWeekCount: dueThisWeekCount,
      recentPaymentsCount: recentPaymentsCount,
      progressMessage: progressMessage,
    );
  }

  DateTime _nextWeeklySummary(DateTime now) {
    final local = DateTime(now.year, now.month, now.day, 8);
    var candidate = local;
    while (candidate.weekday != DateTime.monday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  List<MilestoneNotification> _buildMilestonesForDebt(
    Debt debt,
    Set<String> existingEventKeys,
  ) {
    final notifications = <MilestoneNotification>[];
    if (debt.status == DebtStatus.paidOff) {
      final key = milestoneKey(debt.id, MilestoneKind.paidOff);
      if (!existingEventKeys.contains(key)) {
        notifications.add(
          MilestoneNotification(
            key: key,
            debtId: debt.id,
            kind: MilestoneKind.paidOff,
            title: 'Debt paid off',
            body: '${debt.title} is officially paid off.',
          ),
        );
      }
      return notifications;
    }
    final paidFraction = debt.originalBalance <= 0
        ? 0.0
        : ((debt.originalBalance - debt.currentBalance) / debt.originalBalance)
              .clamp(0, 1);
    final thresholds = <(MilestoneKind, int, String)>[
      (
        MilestoneKind.progress25,
        25,
        'A quarter of ${debt.title} is paid down.',
      ),
      (MilestoneKind.progress50, 50, '${debt.title} is halfway paid down.'),
      (
        MilestoneKind.progress75,
        75,
        '${debt.title} is three quarters paid down.',
      ),
    ];
    for (final threshold in thresholds) {
      final key = milestoneKey(debt.id, threshold.$1);
      if (paidFraction >= threshold.$2 / 100 &&
          !existingEventKeys.contains(key)) {
        notifications.add(
          MilestoneNotification(
            key: key,
            debtId: debt.id,
            kind: threshold.$1,
            title: 'Payoff milestone reached',
            body: threshold.$3,
          ),
        );
      }
    }
    return notifications;
  }

  Set<String> _achievedMilestoneKeysForDebt(Debt debt) {
    final keys = <String>{};
    final paidFraction = debt.originalBalance <= 0
        ? 0.0
        : ((debt.originalBalance - debt.currentBalance) / debt.originalBalance)
              .clamp(0, 1);
    if (paidFraction >= 0.25) {
      keys.add(milestoneKey(debt.id, MilestoneKind.progress25));
    }
    if (paidFraction >= 0.5) {
      keys.add(milestoneKey(debt.id, MilestoneKind.progress50));
    }
    if (paidFraction >= 0.75) {
      keys.add(milestoneKey(debt.id, MilestoneKind.progress75));
    }
    if (debt.status == DebtStatus.paidOff) {
      keys.add(milestoneKey(debt.id, MilestoneKind.paidOff));
    }
    return keys;
  }

  static String milestoneKey(String debtId, MilestoneKind kind) {
    return 'milestone|$debtId|${kind.name}';
  }
}

class ReminderScheduler {
  ReminderScheduler(this._gateway);

  static const payloadPrefix = 'debt_destroyer_reminder|';

  final NotificationGateway _gateway;
  Future<void>? _initializeFuture;

  Future<void> initialize() {
    return _initializeFuture ??= _gateway.initialize();
  }

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> isPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<void> synchronizePlan(List<ReminderPlanItem> items) async {
    await initialize();
    final pending = await _gateway.pendingRequests();
    final plannedIds = items.map((item) => item.id).toSet();

    for (final request in pending) {
      if (_isManagedRequest(request) && !plannedIds.contains(request.id)) {
        await _gateway.cancel(request.id);
      }
      if (_isLegacyRequest(request)) {
        await _gateway.cancel(request.id);
      }
    }
    for (final item in items) {
      await _gateway.cancel(item.id);
      await _gateway.zonedSchedule(
        id: item.id,
        title: item.title,
        body: item.body,
        scheduledAt: tz.TZDateTime.from(item.scheduledAt, tz.local),
        details: _detailsForKind(item.kind),
        payload: item.payload,
      );
    }
  }

  Future<void> cancelAllManaged() async {
    await initialize();
    final pending = await _gateway.pendingRequests();
    for (final request in pending) {
      if (_isManagedRequest(request) || _isLegacyRequest(request)) {
        await _gateway.cancel(request.id);
      }
    }
  }

  Future<void> showMilestone(MilestoneNotification notification) async {
    await initialize();
    await _gateway.show(
      id: notificationIdForKey(notification.key),
      title: notification.title,
      body: notification.body,
      details: _detailsForKind(ReminderKind.milestone),
      payload: '$payloadPrefix${notification.key}',
    );
  }

  static int notificationIdForKey(String key) {
    var hash = 2166136261;
    for (final codeUnit in key.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return hash;
  }

  bool _isManagedRequest(PendingNotificationRequest request) {
    return request.payload?.startsWith(payloadPrefix) ?? false;
  }

  bool _isLegacyRequest(PendingNotificationRequest request) {
    return request.payload == null || request.payload!.isEmpty;
  }

  NotificationDetails _detailsForKind(ReminderKind kind) {
    final (channelId, channelName) = switch (kind) {
      ReminderKind.dueLead ||
      ReminderKind.dueToday => ('due_reminders', 'Due reminders'),
      ReminderKind.overdueDay1 ||
      ReminderKind.overdueDay3 ||
      ReminderKind.overdueDay7 => ('overdue_reminders', 'Overdue reminders'),
      ReminderKind.weeklySummary => ('weekly_summary', 'Weekly summary'),
      ReminderKind.milestone => ('milestones', 'Milestones'),
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }
}

class ReminderOrchestrator {
  ReminderOrchestrator({
    required this.scheduler,
    required this.planBuilder,
    required this.eventsRepository,
  });

  final ReminderScheduler scheduler;
  final ReminderPlanBuilder planBuilder;
  final ReminderEventsRepository eventsRepository;
  Future<void>? _inFlight;
  _ReminderReconcileInput? _pendingInput;

  Future<void> reconcile({
    required UserPreferences preferences,
    required List<Debt> debts,
    required List<Payment> recentPayments,
    DateTime? now,
  }) async {
    final nextInput = _ReminderReconcileInput(
      preferences: preferences,
      debts: debts,
      recentPayments: recentPayments,
      now: now,
    );
    if (_inFlight != null) {
      _pendingInput = nextInput;
      return _inFlight!;
    }
    _inFlight = _runSerialized(nextInput);
    try {
      await _inFlight;
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _runSerialized(_ReminderReconcileInput input) async {
    await _reconcileNow(
      preferences: input.preferences,
      debts: input.debts,
      recentPayments: input.recentPayments,
      now: input.now,
    );
    while (_pendingInput != null) {
      final next = _pendingInput!;
      _pendingInput = null;
      await _reconcileNow(
        preferences: next.preferences,
        debts: next.debts,
        recentPayments: next.recentPayments,
        now: next.now,
      );
    }
  }

  Future<void> _reconcileNow({
    required UserPreferences preferences,
    required List<Debt> debts,
    required List<Payment> recentPayments,
    DateTime? now,
  }) async {
    final eventKeys = await eventsRepository.loadEventKeys();
    if (!eventKeys.contains(ReminderPlanBuilder.bootstrapMarkerKey)) {
      final seeded = planBuilder.achievedMilestoneKeys(debts);
      for (final key in seeded) {
        final parts = key.split('|');
        await eventsRepository.saveEvent(
          ReminderEventRecord(
            id: key,
            debtId: key.startsWith('milestone|') && parts.length > 1
                ? parts[1]
                : null,
            kind: key == ReminderPlanBuilder.bootstrapMarkerKey
                ? MilestoneKind.bootstrapSeeded
                : MilestoneKind.values.byName(parts.last),
            createdAt: now ?? DateTime.now(),
          ),
        );
      }
      eventKeys.addAll(seeded);
    }

    if (!preferences.notificationsEnabled) {
      await scheduler.cancelAllManaged();
      return;
    }

    final plan = planBuilder.build(
      preferences: preferences,
      debts: debts,
      recentPayments: recentPayments,
      existingEventKeys: eventKeys,
      now: now,
    );
    await scheduler.synchronizePlan(plan.scheduledItems);
    for (final milestone in plan.milestoneNotifications) {
      await scheduler.showMilestone(milestone);
      await eventsRepository.saveEvent(
        ReminderEventRecord(
          id: milestone.key,
          debtId: milestone.debtId,
          kind: milestone.kind,
          createdAt: now ?? DateTime.now(),
        ),
      );
    }
  }
}

class _ReminderReconcileInput {
  const _ReminderReconcileInput({
    required this.preferences,
    required this.debts,
    required this.recentPayments,
    required this.now,
  });

  final UserPreferences preferences;
  final List<Debt> debts;
  final List<Payment> recentPayments;
  final DateTime? now;
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
