import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:debt_destroyer/core/services/app_services.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/debt_financial_terms.dart';
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
  });
}

class _FakeNotificationGateway implements NotificationGateway {
  final List<PendingNotificationRequest> pending = [];
  final List<_ShownNotification> shown = [];

  @override
  Future<void> cancel(int id) async {
    pending.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> initialize() async {}

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
  final Set<String> keys = <String>{};

  @override
  Future<Set<String>> loadEventKeys() async => Set<String>.from(keys);

  @override
  Future<void> saveEvent(ReminderEventRecord event) async {
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
