import '../enums/app_enums.dart';
import 'debt.dart';
import 'debt_financial_terms.dart';
import 'import_models.dart';
import 'payment.dart';
import 'reminder_models.dart';
import 'strategy_models.dart';
import 'user_preferences.dart';

class BackupManifest {
  const BackupManifest({
    required this.backupFormatVersion,
    required this.createdAt,
    required this.createdByAppVersion,
    required this.createdBySchemaVersion,
    required this.containsDocuments,
    required this.debtCount,
    required this.paymentCount,
    required this.documentCount,
    required this.parsedExtractionCount,
    required this.scenarioCount,
    required this.reminderEventCount,
  });

  final int backupFormatVersion;
  final DateTime createdAt;
  final String createdByAppVersion;
  final int createdBySchemaVersion;
  final bool containsDocuments;
  final int debtCount;
  final int paymentCount;
  final int documentCount;
  final int parsedExtractionCount;
  final int scenarioCount;
  final int reminderEventCount;

  Map<String, Object?> toJson() {
    return {
      'backupFormatVersion': backupFormatVersion,
      'createdAt': createdAt.toIso8601String(),
      'createdByAppVersion': createdByAppVersion,
      'createdBySchemaVersion': createdBySchemaVersion,
      'containsDocuments': containsDocuments,
      'debtCount': debtCount,
      'paymentCount': paymentCount,
      'documentCount': documentCount,
      'parsedExtractionCount': parsedExtractionCount,
      'scenarioCount': scenarioCount,
      'reminderEventCount': reminderEventCount,
    };
  }

  factory BackupManifest.fromJson(Map<String, Object?> json) {
    return BackupManifest(
      backupFormatVersion: _readInt(json, 'backupFormatVersion'),
      createdAt: _readDate(json, 'createdAt'),
      createdByAppVersion: _readString(json, 'createdByAppVersion'),
      createdBySchemaVersion: _readInt(json, 'createdBySchemaVersion'),
      containsDocuments: _readBool(json, 'containsDocuments'),
      debtCount: _readInt(json, 'debtCount'),
      paymentCount: _readInt(json, 'paymentCount'),
      documentCount: _readInt(json, 'documentCount'),
      parsedExtractionCount: _readInt(json, 'parsedExtractionCount'),
      scenarioCount: _readInt(json, 'scenarioCount'),
      reminderEventCount: _readInt(json, 'reminderEventCount'),
    );
  }
}

class BackupPreview {
  const BackupPreview({
    required this.manifest,
    required this.debtCount,
    required this.paymentCount,
    required this.documentCount,
    required this.parsedExtractionCount,
    required this.scenarioCount,
    required this.reminderEventCount,
  });

  final BackupManifest manifest;
  final int debtCount;
  final int paymentCount;
  final int documentCount;
  final int parsedExtractionCount;
  final int scenarioCount;
  final int reminderEventCount;
}

class BackupValidationResult {
  const BackupValidationResult({
    required this.isValid,
    required this.errors,
    this.preview,
  });

  final bool isValid;
  final List<String> errors;
  final BackupPreview? preview;
}

class BackupPayloadV1 {
  const BackupPayloadV1({
    required this.manifest,
    required this.debts,
    required this.payments,
    required this.documents,
    required this.parsedExtractions,
    required this.scenarios,
    required this.reminderEvents,
    required this.preferences,
  });

  final BackupManifest manifest;
  final List<Debt> debts;
  final List<Payment> payments;
  final List<ImportedDocument> documents;
  final List<ParsedExtraction> parsedExtractions;
  final List<Scenario> scenarios;
  final List<ReminderEventRecord> reminderEvents;
  final UserPreferences preferences;

  BackupPreview toPreview() {
    return BackupPreview(
      manifest: manifest,
      debtCount: debts.length,
      paymentCount: payments.length,
      documentCount: documents.length,
      parsedExtractionCount: parsedExtractions.length,
      scenarioCount: scenarios.length,
      reminderEventCount: reminderEvents.length,
    );
  }
}

Map<String, Object?> debtToJson(Debt debt) {
  return {
    'id': debt.id,
    'title': debt.title,
    'creditorName': debt.creditorName,
    'type': debt.type.name,
    'currency': debt.currency,
    'originalBalance': debt.originalBalance,
    'currentBalance': debt.currentBalance,
    'apr': debt.apr,
    'minimumPayment': debt.minimumPayment,
    'dueDate': debt.dueDate?.toIso8601String(),
    'paymentFrequency': debt.paymentFrequency.name,
    'createdAt': debt.createdAt.toIso8601String(),
    'updatedAt': debt.updatedAt.toIso8601String(),
    'notes': debt.notes,
    'tags': debt.tags,
    'status': debt.status.name,
    'remindersEnabled': debt.remindersEnabled,
    'customPriority': debt.customPriority,
    'financialTerms': debt.financialTerms.toJson(),
  };
}

Debt debtFromJson(Map<String, Object?> json) {
  return Debt(
    id: _readString(json, 'id'),
    title: _readString(json, 'title'),
    creditorName: _readString(json, 'creditorName'),
    type: _readEnum(
      DebtType.values,
      json['type'],
      field: 'type',
      fallback: DebtType.other,
    ),
    currency: _readString(json, 'currency'),
    originalBalance: _readDouble(json, 'originalBalance'),
    currentBalance: _readDouble(json, 'currentBalance'),
    apr: _readDouble(json, 'apr'),
    minimumPayment: _readDouble(json, 'minimumPayment'),
    dueDate: _readNullableDate(json['dueDate']),
    paymentFrequency: _readEnum(
      PaymentFrequency.values,
      json['paymentFrequency'],
      field: 'paymentFrequency',
      fallback: PaymentFrequency.monthly,
    ),
    createdAt: _readDate(json, 'createdAt'),
    updatedAt: _readDate(json, 'updatedAt'),
    notes: json['notes']?.toString() ?? '',
    tags: _readStringList(json['tags']),
    status: _readEnum(
      DebtStatus.values,
      json['status'],
      field: 'status',
      fallback: DebtStatus.active,
    ),
    remindersEnabled: _readBoolWithDefault(json['remindersEnabled'], false),
    customPriority: _readIntWithDefault(json['customPriority'], 0),
    financialTerms: DebtFinancialTerms.fromJson(
      _readMap(json['financialTerms']),
    ),
  );
}

Map<String, Object?> paymentToJson(Payment payment) {
  return {
    'id': payment.id,
    'debtId': payment.debtId,
    'amount': payment.amount,
    'date': payment.date.toIso8601String(),
    'method': payment.method,
    'sourceType': payment.sourceType.name,
    'notes': payment.notes,
    'tags': payment.tags,
    'createdAt': payment.createdAt.toIso8601String(),
  };
}

Payment paymentFromJson(Map<String, Object?> json) {
  return Payment(
    id: _readString(json, 'id'),
    debtId: _readString(json, 'debtId'),
    amount: _readDouble(json, 'amount'),
    date: _readDate(json, 'date'),
    method: json['method']?.toString(),
    sourceType: _readEnum(
      PaymentSourceType.values,
      json['sourceType'],
      field: 'sourceType',
      fallback: PaymentSourceType.manual,
    ),
    notes: json['notes']?.toString() ?? '',
    tags: _readStringList(json['tags']),
    createdAt: _readDate(json, 'createdAt'),
  );
}

Map<String, Object?> documentToJson(ImportedDocument document) {
  return {
    'id': document.id,
    'storageRef': document.storageRef,
    'sourceType': document.sourceType.name,
    'mimeType': document.mimeType,
    'createdAt': document.createdAt.toIso8601String(),
    'lifecycleState': document.lifecycleState.name,
    'linkedDebtId': document.linkedDebtId,
    'rawOcrText': document.rawOcrText,
    'parseStatus': document.parseStatus.name,
    'parseVersion': document.parseVersion,
    'deleted': document.deleted,
    'retentionExpiresAt': document.retentionExpiresAt?.toIso8601String(),
    'rawOcrExpiresAt': document.rawOcrExpiresAt?.toIso8601String(),
    'processedAt': document.processedAt?.toIso8601String(),
    'linkedAt': document.linkedAt?.toIso8601String(),
    'pendingDeletionAt': document.pendingDeletionAt?.toIso8601String(),
    'purgedAt': document.purgedAt?.toIso8601String(),
    'encryptedAt': document.encryptedAt?.toIso8601String(),
    'hasRawOcrText': document.hasRawOcrText,
  };
}

ImportedDocument documentFromJson(Map<String, Object?> json) {
  return ImportedDocument(
    id: _readString(json, 'id'),
    storageRef: json['storageRef']?.toString(),
    sourceType: _readEnum(
      DocumentSourceType.values,
      json['sourceType'],
      field: 'sourceType',
      fallback: DocumentSourceType.gallery,
    ),
    mimeType: _readString(json, 'mimeType'),
    createdAt: _readDate(json, 'createdAt'),
    lifecycleState: _readEnum(
      DocumentLifecycleState.values,
      json['lifecycleState'],
      field: 'lifecycleState',
      fallback: DocumentLifecycleState.imported,
    ),
    linkedDebtId: json['linkedDebtId']?.toString(),
    rawOcrText: json['rawOcrText']?.toString(),
    parseStatus: _readEnum(
      ParseStatus.values,
      json['parseStatus'],
      field: 'parseStatus',
      fallback: ParseStatus.pending,
    ),
    parseVersion: json['parseVersion']?.toString() ?? 'v1',
    deleted: _readBoolWithDefault(json['deleted'], false),
    retentionExpiresAt: _readNullableDate(json['retentionExpiresAt']),
    rawOcrExpiresAt: _readNullableDate(json['rawOcrExpiresAt']),
    processedAt: _readNullableDate(json['processedAt']),
    linkedAt: _readNullableDate(json['linkedAt']),
    pendingDeletionAt: _readNullableDate(json['pendingDeletionAt']),
    purgedAt: _readNullableDate(json['purgedAt']),
    encryptedAt: _readNullableDate(json['encryptedAt']),
    hasRawOcrText: _readBoolWithDefault(json['hasRawOcrText'], false),
  );
}

Map<String, Object?> parsedExtractionToJson(ParsedExtraction extraction) {
  return {
    'id': extraction.id,
    'documentId': extraction.documentId,
    'classification': extraction.classification.name,
    'confidence': extraction.confidence,
    'payloadJson': extraction.payloadJson,
    'ambiguityNotes': extraction.ambiguityNotes,
    'createdAt': extraction.createdAt.toIso8601String(),
  };
}

ParsedExtraction parsedExtractionFromJson(Map<String, Object?> json) {
  return ParsedExtraction(
    id: _readString(json, 'id'),
    documentId: _readString(json, 'documentId'),
    classification: _readEnum(
      DocumentClassification.values,
      json['classification'],
      field: 'classification',
      fallback: DocumentClassification.unknown,
    ),
    confidence: _readDouble(json, 'confidence'),
    payloadJson: json['payloadJson']?.toString() ?? '{}',
    ambiguityNotes: json['ambiguityNotes']?.toString() ?? '',
    createdAt: _readDate(json, 'createdAt'),
  );
}

Map<String, Object?> scenarioToJson(Scenario scenario) {
  return {
    'id': scenario.id,
    'strategyType': scenario.strategyType.name,
    'extraPayment': scenario.extraPayment,
    'budget': scenario.budget,
    'createdAt': scenario.createdAt.toIso8601String(),
    'label': scenario.label,
    'baselineInterest': scenario.baselineInterest,
    'optimizedInterest': scenario.optimizedInterest,
    'monthsToPayoff': scenario.monthsToPayoff,
  };
}

Scenario scenarioFromJson(Map<String, Object?> json) {
  return Scenario(
    id: _readString(json, 'id'),
    strategyType: _readEnum(
      StrategyType.values,
      json['strategyType'],
      field: 'strategyType',
      fallback: StrategyType.avalanche,
    ),
    extraPayment: _readDouble(json, 'extraPayment'),
    budget: _readDouble(json, 'budget'),
    createdAt: _readDate(json, 'createdAt'),
    label: _readString(json, 'label'),
    baselineInterest: _readDouble(json, 'baselineInterest'),
    optimizedInterest: _readDouble(json, 'optimizedInterest'),
    monthsToPayoff: _readInt(json, 'monthsToPayoff'),
  );
}

Map<String, Object?> reminderEventToJson(ReminderEventRecord event) {
  return {
    'id': event.id,
    'debtId': event.debtId,
    'kind': event.kind.name,
    'createdAt': event.createdAt.toIso8601String(),
  };
}

ReminderEventRecord reminderEventFromJson(Map<String, Object?> json) {
  return ReminderEventRecord(
    id: _readString(json, 'id'),
    debtId: json['debtId']?.toString(),
    kind: _readEnum(
      MilestoneKind.values,
      json['kind'],
      field: 'kind',
      fallback: MilestoneKind.bootstrapSeeded,
    ),
    createdAt: _readDate(json, 'createdAt'),
  );
}

Map<String, Object?> preferencesToJson(UserPreferences preferences) {
  return {
    'themeMode': preferences.themeMode.name,
    'currencyCode': preferences.currencyCode,
    'localeCode': preferences.localeCode,
    'defaultStrategy': preferences.defaultStrategy.name,
    'hideBalances': preferences.hideBalances,
    'appLockEnabled': preferences.appLockEnabled,
    'aiConsentEnabled': preferences.aiConsentEnabled,
    'relockTimeout': preferences.relockTimeout.name,
    'screenshotProtectionEnabled': preferences.screenshotProtectionEnabled,
    'privacyShieldOnAppSwitcherEnabled':
        preferences.privacyShieldOnAppSwitcherEnabled,
    'notificationsEnabled': preferences.notificationsEnabled,
    'dueRemindersEnabled': preferences.dueRemindersEnabled,
    'overdueRemindersEnabled': preferences.overdueRemindersEnabled,
    'milestoneNotificationsEnabled': preferences.milestoneNotificationsEnabled,
    'onboardingCompleted': preferences.onboardingCompleted,
    'weeklySummaryEnabled': preferences.weeklySummaryEnabled,
    'dueReminderLeadDays': preferences.dueReminderLeadDays,
    'rawOcrRetentionEnabled': preferences.rawOcrRetentionEnabled,
    'rawOcrRetentionHours': preferences.rawOcrRetentionHours,
    'documentRetentionMode': preferences.documentRetentionMode.name,
    'purgeFailedImportsAfterHours': preferences.purgeFailedImportsAfterHours,
    'dataProtectionExplainerSeen': preferences.dataProtectionExplainerSeen,
  };
}

UserPreferences preferencesFromJson(Map<String, Object?> json) {
  final defaults = UserPreferences.defaults();
  return UserPreferences(
    themeMode: _readEnum(
      ThemePreference.values,
      json['themeMode'],
      field: 'themeMode',
      fallback: defaults.themeMode,
    ),
    currencyCode: json['currencyCode']?.toString() ?? defaults.currencyCode,
    localeCode: json['localeCode']?.toString() ?? defaults.localeCode,
    defaultStrategy: _readEnum(
      StrategyType.values,
      json['defaultStrategy'],
      field: 'defaultStrategy',
      fallback: defaults.defaultStrategy,
    ),
    hideBalances: _readBoolWithDefault(
      json['hideBalances'],
      defaults.hideBalances,
    ),
    appLockEnabled: _readBoolWithDefault(
      json['appLockEnabled'],
      defaults.appLockEnabled,
    ),
    aiConsentEnabled: _readBoolWithDefault(
      json['aiConsentEnabled'],
      defaults.aiConsentEnabled,
    ),
    relockTimeout: _readEnum(
      AppRelockTimeout.values,
      json['relockTimeout'],
      field: 'relockTimeout',
      fallback: defaults.relockTimeout,
    ),
    screenshotProtectionEnabled: _readBoolWithDefault(
      json['screenshotProtectionEnabled'],
      defaults.screenshotProtectionEnabled,
    ),
    privacyShieldOnAppSwitcherEnabled: _readBoolWithDefault(
      json['privacyShieldOnAppSwitcherEnabled'],
      defaults.privacyShieldOnAppSwitcherEnabled,
    ),
    notificationsEnabled: _readBoolWithDefault(
      json['notificationsEnabled'],
      defaults.notificationsEnabled,
    ),
    dueRemindersEnabled: _readBoolWithDefault(
      json['dueRemindersEnabled'],
      defaults.dueRemindersEnabled,
    ),
    overdueRemindersEnabled: _readBoolWithDefault(
      json['overdueRemindersEnabled'],
      defaults.overdueRemindersEnabled,
    ),
    milestoneNotificationsEnabled: _readBoolWithDefault(
      json['milestoneNotificationsEnabled'],
      defaults.milestoneNotificationsEnabled,
    ),
    onboardingCompleted: _readBoolWithDefault(
      json['onboardingCompleted'],
      defaults.onboardingCompleted,
    ),
    weeklySummaryEnabled: _readBoolWithDefault(
      json['weeklySummaryEnabled'],
      defaults.weeklySummaryEnabled,
    ),
    dueReminderLeadDays: _readIntWithDefault(
      json['dueReminderLeadDays'],
      defaults.dueReminderLeadDays,
    ).clamp(1, 3),
    rawOcrRetentionEnabled: _readBoolWithDefault(
      json['rawOcrRetentionEnabled'],
      defaults.rawOcrRetentionEnabled,
    ),
    rawOcrRetentionHours: _readIntWithDefault(
      json['rawOcrRetentionHours'],
      defaults.rawOcrRetentionHours,
    ),
    documentRetentionMode: _readEnum(
      DocumentRetentionMode.values,
      json['documentRetentionMode'],
      field: 'documentRetentionMode',
      fallback: defaults.documentRetentionMode,
    ),
    purgeFailedImportsAfterHours: _readIntWithDefault(
      json['purgeFailedImportsAfterHours'],
      defaults.purgeFailedImportsAfterHours,
    ),
    dataProtectionExplainerSeen: _readBoolWithDefault(
      json['dataProtectionExplainerSeen'],
      defaults.dataProtectionExplainerSeen,
    ),
  );
}

T _readEnum<T extends Enum>(
  List<T> values,
  Object? raw, {
  required String field,
  required T fallback,
}) {
  final name = raw?.toString();
  if (name == null || name.isEmpty) {
    return fallback;
  }
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  throw FormatException('Invalid enum value for $field: $name');
}

Map<String, Object?> _readMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map(
      (key, entry) => MapEntry(key.toString(), entry as Object?),
    );
  }
  return const {};
}

DateTime _readDate(Map<String, Object?> json, String key) {
  final raw = json[key];
  final parsed = _readNullableDate(raw);
  if (parsed == null) {
    throw FormatException('Missing or invalid date for $key');
  }
  return parsed;
}

DateTime? _readNullableDate(Object? raw) {
  final value = raw?.toString();
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

int _readInt(Map<String, Object?> json, String key) {
  final raw = json[key];
  final value = _readIntWithDefault(raw, -1);
  if (value == -1 && raw == null) {
    throw FormatException('Missing integer for $key');
  }
  return value;
}

int _readIntWithDefault(Object? raw, int fallback) {
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }
  final parsed = int.tryParse(raw?.toString() ?? '');
  return parsed ?? fallback;
}

double _readDouble(Map<String, Object?> json, String key) {
  final raw = json[key];
  if (raw is num) {
    return raw.toDouble();
  }
  final parsed = double.tryParse(raw?.toString() ?? '');
  if (parsed == null) {
    throw FormatException('Missing or invalid number for $key');
  }
  return parsed;
}

bool _readBool(Map<String, Object?> json, String key) {
  final raw = json[key];
  if (raw is bool) {
    return raw;
  }
  if (raw == null) {
    throw FormatException('Missing bool for $key');
  }
  return raw.toString().toLowerCase() == 'true';
}

bool _readBoolWithDefault(Object? raw, bool fallback) {
  if (raw is bool) {
    return raw;
  }
  if (raw == null) {
    return fallback;
  }
  return raw.toString().toLowerCase() == 'true';
}

String _readString(Map<String, Object?> json, String key) {
  final value = json[key]?.toString();
  if (value == null || value.isEmpty) {
    throw FormatException('Missing string for $key');
  }
  return value;
}

List<String> _readStringList(Object? raw) {
  if (raw is! List) {
    return const [];
  }
  return raw.map((item) => item.toString()).toList();
}
