import '../enums/app_enums.dart';

class ReminderPlanItem {
  const ReminderPlanItem({
    required this.key,
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.payload,
    this.debtId,
  });

  final String key;
  final int id;
  final ReminderKind kind;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String payload;
  final String? debtId;
}

class WeeklySummarySnapshot {
  const WeeklySummarySnapshot({
    required this.dueThisWeekCount,
    required this.recentPaymentsCount,
    required this.progressMessage,
  });

  final int dueThisWeekCount;
  final int recentPaymentsCount;
  final String progressMessage;
}

class MilestoneNotification {
  const MilestoneNotification({
    required this.key,
    required this.debtId,
    required this.kind,
    required this.title,
    required this.body,
  });

  final String key;
  final String debtId;
  final MilestoneKind kind;
  final String title;
  final String body;
}

class ReminderPlan {
  const ReminderPlan({
    required this.scheduledItems,
    required this.milestoneNotifications,
  });

  final List<ReminderPlanItem> scheduledItems;
  final List<MilestoneNotification> milestoneNotifications;
}

class ReminderEventRecord {
  const ReminderEventRecord({
    required this.id,
    required this.kind,
    required this.createdAt,
    this.debtId,
  });

  final String id;
  final MilestoneKind kind;
  final DateTime createdAt;
  final String? debtId;
}
