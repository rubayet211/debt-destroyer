import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:debt_destroyer/core/services/app_services.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/debt_financial_terms.dart';
import 'package:debt_destroyer/shared/models/payment.dart';
import 'package:debt_destroyer/shared/models/reminder_models.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('ReminderPlanBuilder', () {
    const builder = ReminderPlanBuilder();

    test('builds due lead and due today reminders', () {
      final now = DateTime(2026, 3, 10, 8);
      final plan = builder.build(
        preferences: UserPreferences.defaults(),
        debts: [_debt(dueDate: DateTime(2026, 3, 15))],
        recentPayments: const [],
        existingEventKeys: {ReminderPlanBuilder.bootstrapMarkerKey},
        now: now,
      );

      expect(
        plan.scheduledItems.where((item) => item.kind == ReminderKind.dueLead),
        hasLength(1),
      );
      expect(
        plan.scheduledItems.where((item) => item.kind == ReminderKind.dueToday),
        hasLength(1),
      );
    });

    test('builds overdue cadence only for future overdue checkpoints', () {
      final now = DateTime(2026, 3, 10, 8);
      final plan = builder.build(
        preferences: UserPreferences.defaults(),
        debts: [_debt(dueDate: DateTime(2026, 3, 9))],
        recentPayments: const [],
        existingEventKeys: {ReminderPlanBuilder.bootstrapMarkerKey},
        now: now,
      );

      final overdueKinds = plan.scheduledItems
          .where((item) => item.kind.name.startsWith('overdue'))
          .map((item) => item.kind)
          .toList();
      expect(overdueKinds, contains(ReminderKind.overdueDay1));
      expect(overdueKinds, contains(ReminderKind.overdueDay3));
      expect(overdueKinds, contains(ReminderKind.overdueDay7));
    });

    test('ignores archived and paid off debts', () {
      final now = DateTime(2026, 3, 10, 8);
      final plan = builder.build(
        preferences: UserPreferences.defaults(),
        debts: [
          _debt(
            id: 'archived',
            dueDate: DateTime(2026, 3, 15),
            status: DebtStatus.archived,
          ),
          _debt(
            id: 'paid-off',
            dueDate: DateTime(2026, 3, 15),
            status: DebtStatus.paidOff,
            currentBalance: 0,
          ),
        ],
        recentPayments: const [],
        existingEventKeys: {ReminderPlanBuilder.bootstrapMarkerKey},
        now: now,
      );

      expect(plan.scheduledItems, isEmpty);
    });

    test('respects configured lead days and weekly summary timing', () {
      final now = DateTime(2026, 3, 10, 8); // Tuesday
      final plan = builder.build(
        preferences: UserPreferences.defaults().copyWith(
          dueReminderLeadDays: 3,
          weeklySummaryEnabled: true,
        ),
        debts: [_debt(dueDate: DateTime(2026, 3, 15))],
        recentPayments: const [],
        existingEventKeys: {ReminderPlanBuilder.bootstrapMarkerKey},
        now: now,
      );

      final dueLead = plan.scheduledItems.firstWhere(
        (item) => item.kind == ReminderKind.dueLead,
      );
      final weekly = plan.scheduledItems.firstWhere(
        (item) => item.kind == ReminderKind.weeklySummary,
      );
      expect(dueLead.scheduledAt, DateTime(2026, 3, 12, 9));
      expect(weekly.scheduledAt, DateTime(2026, 3, 16, 8));
    });

    test('weekly summary counts all recent payments from uncapped input', () {
      final now = DateTime(2026, 3, 10, 8);
      final recentPayments = List.generate(
        12,
        (index) => _payment(
          id: 'payment-$index',
          date: now.subtract(Duration(days: index % 6)),
        ),
      );
      final plan = builder.build(
        preferences: UserPreferences.defaults().copyWith(
          weeklySummaryEnabled: true,
        ),
        debts: [_debt(dueDate: DateTime(2026, 3, 15))],
        recentPayments: recentPayments,
        existingEventKeys: {ReminderPlanBuilder.bootstrapMarkerKey},
        now: now,
      );

      final weekly = plan.scheduledItems.firstWhere(
        (item) => item.kind == ReminderKind.weeklySummary,
      );
      expect(weekly.body, contains('12 recent payments'));
    });
  });

  group('ReminderOrchestrator', () {
    test('seeds achieved milestones on first run without notifying', () async {
      final gateway = _FakeNotificationGateway();
      final orchestrator = ReminderOrchestrator(
        scheduler: ReminderScheduler(gateway),
        planBuilder: const ReminderPlanBuilder(),
        eventsRepository: _FakeReminderEventsRepository(),
      );

      await orchestrator.reconcile(
        preferences: UserPreferences.defaults(),
        debts: [
          _debt(
            currentBalance: 0,
            status: DebtStatus.paidOff,
            dueDate: DateTime.utc(2026, 3, 15),
          ),
        ],
        recentPayments: const [],
        now: DateTime(2026, 3, 10, 8),
      );

      expect(gateway.shown, isEmpty);
    });

    test(
      'shows paid off milestone after bootstrap and cancels all when disabled',
      () async {
        final gateway = _FakeNotificationGateway();
        final events = _FakeReminderEventsRepository();
        final orchestrator = ReminderOrchestrator(
          scheduler: ReminderScheduler(gateway),
          planBuilder: const ReminderPlanBuilder(),
          eventsRepository: events,
        );
        final now = DateTime(2026, 3, 10, 8);

        await orchestrator.reconcile(
          preferences: UserPreferences.defaults(),
          debts: [_debt(dueDate: DateTime(2026, 3, 15))],
          recentPayments: const [],
          now: now,
        );

        await orchestrator.reconcile(
          preferences: UserPreferences.defaults(),
          debts: [
            _debt(
              currentBalance: 0,
              status: DebtStatus.paidOff,
              dueDate: DateTime(2026, 3, 15),
            ),
          ],
          recentPayments: const [],
          now: now.add(const Duration(minutes: 1)),
        );

        expect(gateway.shown.single.title, 'Debt paid off');

        gateway.pending.add(
          const PendingNotificationRequest(99, 'legacy', 'legacy', ''),
        );
        await orchestrator.reconcile(
          preferences: UserPreferences.defaults().copyWith(
            notificationsEnabled: false,
          ),
          debts: const [],
          recentPayments: const [],
          now: now.add(const Duration(minutes: 2)),
        );

        expect(gateway.pending, isEmpty);
        expect(events.keys, contains(ReminderPlanBuilder.bootstrapMarkerKey));
      },
    );

    test(
      'serializes concurrent reconciles to avoid duplicate milestone sends',
      () async {
        final gateway = _FakeNotificationGateway(
          initializationDelay: const Duration(milliseconds: 20),
        );
        final events = _FakeReminderEventsRepository(
          readDelay: const Duration(milliseconds: 15),
          writeDelay: const Duration(milliseconds: 15),
        );
        final orchestrator = ReminderOrchestrator(
          scheduler: ReminderScheduler(gateway),
          planBuilder: const ReminderPlanBuilder(),
          eventsRepository: events,
        );
        final now = DateTime(2026, 3, 10, 8);

        await orchestrator.reconcile(
          preferences: UserPreferences.defaults(),
          debts: [_debt(dueDate: DateTime(2026, 3, 15))],
          recentPayments: const [],
          now: now,
        );

        await Future.wait([
          orchestrator.reconcile(
            preferences: UserPreferences.defaults(),
            debts: [
              _debt(
                currentBalance: 0,
                status: DebtStatus.paidOff,
                dueDate: DateTime(2026, 3, 15),
              ),
            ],
            recentPayments: const [],
            now: now.add(const Duration(minutes: 1)),
          ),
          orchestrator.reconcile(
            preferences: UserPreferences.defaults(),
            debts: [
              _debt(
                currentBalance: 0,
                status: DebtStatus.paidOff,
                dueDate: DateTime(2026, 3, 15),
              ),
            ],
            recentPayments: const [],
            now: now.add(const Duration(minutes: 1)),
          ),
        ]);

        expect(
          gateway.shown.where((item) => item.title == 'Debt paid off'),
          hasLength(1),
        );
      },
    );

    test(
      'scheduler initializes lazily before scheduling notifications',
      () async {
        final gateway = _FakeNotificationGateway();
        final scheduler = ReminderScheduler(gateway);

        await scheduler.synchronizePlan([
          ReminderPlanItem(
            key: 'weekly_summary',
            id: ReminderScheduler.notificationIdForKey('weekly_summary'),
            kind: ReminderKind.weeklySummary,
            title: 'Weekly debt progress',
            body: '1 due this week',
            scheduledAt: DateTime(2026, 3, 16, 8),
            payload: '${ReminderScheduler.payloadPrefix}weekly_summary',
          ),
        ]);

        expect(gateway.initializeCount, 1);
        expect(gateway.pending, hasLength(1));
      },
    );

    test(
      'scheduler cancels stale managed reminders while preserving others',
      () async {
        final gateway = _FakeNotificationGateway()
          ..pending.addAll([
            PendingNotificationRequest(
              ReminderScheduler.notificationIdForKey('stale_due'),
              'stale',
              'stale',
              '${ReminderScheduler.payloadPrefix}stale_due',
            ),
            const PendingNotificationRequest(
              777,
              'foreign',
              'foreign',
              'foreign',
            ),
          ]);
        final scheduler = ReminderScheduler(gateway);

        await scheduler.synchronizePlan([
          ReminderPlanItem(
            key: 'weekly_summary',
            id: ReminderScheduler.notificationIdForKey('weekly_summary'),
            kind: ReminderKind.weeklySummary,
            title: 'Weekly debt progress',
            body: '1 due this week',
            scheduledAt: DateTime(2026, 3, 16, 8),
            payload: '${ReminderScheduler.payloadPrefix}weekly_summary',
          ),
        ]);

        expect(
          gateway.pending.any((item) => item.payload == 'foreign'),
          isTrue,
        );
        expect(
          gateway.pending.any(
            (item) =>
                item.payload == '${ReminderScheduler.payloadPrefix}stale_due',
          ),
          isFalse,
        );
        expect(
          gateway.pending.any(
            (item) =>
                item.payload ==
                '${ReminderScheduler.payloadPrefix}weekly_summary',
          ),
          isTrue,
        );
      },
    );
  });
}

class _FakeNotificationGateway implements NotificationGateway {
  _FakeNotificationGateway({this.initializationDelay = Duration.zero});

  final Duration initializationDelay;
  int initializeCount = 0;
  final List<PendingNotificationRequest> pending = [];
  final List<_ShownNotification> shown = [];

  @override
  Future<void> cancel(int id) async {
    pending.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> initialize() async {
    initializeCount += 1;
    if (initializationDelay > Duration.zero) {
      await Future<void>.delayed(initializationDelay);
    }
  }

  @override
  Future<List<PendingNotificationRequest>> pendingRequests() async {
    return List<PendingNotificationRequest>.from(pending);
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    String? payload,
  }) async {
    shown.add(_ShownNotification(id: id, title: title, body: body));
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledAt,
    required NotificationDetails details,
    String? payload,
  }) async {
    pending.removeWhere((item) => item.id == id);
    pending.add(PendingNotificationRequest(id, title, body, payload));
  }
}

class _FakeReminderEventsRepository implements ReminderEventsRepository {
  _FakeReminderEventsRepository({
    this.readDelay = Duration.zero,
    this.writeDelay = Duration.zero,
  });

  final Duration readDelay;
  final Duration writeDelay;
  final Set<String> keys = <String>{};

  @override
  Future<Set<String>> loadEventKeys() async {
    if (readDelay > Duration.zero) {
      await Future<void>.delayed(readDelay);
    }
    return Set<String>.from(keys);
  }

  @override
  Future<void> saveEvent(ReminderEventRecord event) async {
    if (writeDelay > Duration.zero) {
      await Future<void>.delayed(writeDelay);
    }
    keys.add(event.id);
  }
}

class _ShownNotification {
  const _ShownNotification({
    required this.id,
    required this.title,
    required this.body,
  });

  final int id;
  final String title;
  final String body;
}

Payment _payment({required String id, required DateTime date}) {
  return Payment(
    id: id,
    debtId: 'debt-1',
    amount: 25,
    date: date,
    method: null,
    sourceType: PaymentSourceType.manual,
    notes: '',
    tags: const [],
    createdAt: date,
  );
}

Debt _debt({
  String id = 'debt-1',
  DateTime? dueDate,
  double originalBalance = 1000,
  double currentBalance = 800,
  DebtStatus status = DebtStatus.active,
}) {
  return Debt(
    id: id,
    title: 'Visa',
    creditorName: 'Bank',
    type: DebtType.creditCard,
    currency: 'USD',
    originalBalance: originalBalance,
    currentBalance: currentBalance,
    apr: 18,
    minimumPayment: 50,
    dueDate: dueDate,
    paymentFrequency: PaymentFrequency.monthly,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 3, 1),
    notes: '',
    tags: const [],
    status: status,
    remindersEnabled: true,
    customPriority: 1,
    financialTerms: const DebtFinancialTerms(),
  );
}
