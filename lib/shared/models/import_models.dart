import 'backend_models.dart';
import '../enums/app_enums.dart';

class ImportedDocument {
  const ImportedDocument({
    required this.id,
    required this.storageRef,
    required this.sourceType,
    required this.mimeType,
    required this.createdAt,
    required this.lifecycleState,
    required this.linkedDebtId,
    required this.rawOcrText,
    required this.parseStatus,
    required this.parseVersion,
    required this.deleted,
    required this.retentionExpiresAt,
    required this.rawOcrExpiresAt,
    required this.processedAt,
    required this.linkedAt,
    required this.pendingDeletionAt,
    required this.purgedAt,
    required this.encryptedAt,
    required this.hasRawOcrText,
  });

  final String id;
  final String? storageRef;
  final DocumentSourceType sourceType;
  final String mimeType;
  final DateTime createdAt;
  final DocumentLifecycleState lifecycleState;
  final String? linkedDebtId;
  final String? rawOcrText;
  final ParseStatus parseStatus;
  final String parseVersion;
  final bool deleted;
  final DateTime? retentionExpiresAt;
  final DateTime? rawOcrExpiresAt;
  final DateTime? processedAt;
  final DateTime? linkedAt;
  final DateTime? pendingDeletionAt;
  final DateTime? purgedAt;
  final DateTime? encryptedAt;
  final bool hasRawOcrText;

  ImportedDocument copyWith({
    String? storageRef,
    DocumentLifecycleState? lifecycleState,
    String? linkedDebtId,
    String? rawOcrText,
    ParseStatus? parseStatus,
    bool? deleted,
    DateTime? retentionExpiresAt,
    DateTime? rawOcrExpiresAt,
    DateTime? processedAt,
    DateTime? linkedAt,
    DateTime? pendingDeletionAt,
    DateTime? purgedAt,
    DateTime? encryptedAt,
    bool? hasRawOcrText,
  }) {
    return ImportedDocument(
      id: id,
      storageRef: storageRef ?? this.storageRef,
      sourceType: sourceType,
      mimeType: mimeType,
      createdAt: createdAt,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      linkedDebtId: linkedDebtId ?? this.linkedDebtId,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      parseStatus: parseStatus ?? this.parseStatus,
      parseVersion: parseVersion,
      deleted: deleted ?? this.deleted,
      retentionExpiresAt: retentionExpiresAt ?? this.retentionExpiresAt,
      rawOcrExpiresAt: rawOcrExpiresAt ?? this.rawOcrExpiresAt,
      processedAt: processedAt ?? this.processedAt,
      linkedAt: linkedAt ?? this.linkedAt,
      pendingDeletionAt: pendingDeletionAt ?? this.pendingDeletionAt,
      purgedAt: purgedAt ?? this.purgedAt,
      encryptedAt: encryptedAt ?? this.encryptedAt,
      hasRawOcrText: hasRawOcrText ?? this.hasRawOcrText,
    );
  }
}

class ParsedExtraction {
  const ParsedExtraction({
    required this.id,
    required this.documentId,
    required this.classification,
    required this.confidence,
    required this.payloadJson,
    required this.ambiguityNotes,
    required this.createdAt,
  });

  final String id;
  final String documentId;
  final DocumentClassification classification;
  final double confidence;
  final String payloadJson;
  final String ambiguityNotes;
  final DateTime createdAt;
}

class ExtractionCandidate {
  const ExtractionCandidate({
    this.title,
    this.creditorName,
    this.debtType,
    this.currentBalance,
    this.originalBalance,
    this.aprPercentage,
    this.minimumPayment,
    this.dueDate,
    this.paymentDate,
    this.paymentAmount,
    this.currency,
    this.notes,
    this.confidence = 0,
    this.last4,
    this.labels = const [],
    this.warnings = const [],
    this.quotaSnapshot,
  });

  final String? title;
  final String? creditorName;
  final DebtType? debtType;
  final double? currentBalance;
  final double? originalBalance;
  final double? aprPercentage;
  final double? minimumPayment;
  final DateTime? dueDate;
  final DateTime? paymentDate;
  final double? paymentAmount;
  final String? currency;
  final String? notes;
  final double confidence;
  final String? last4;
  final List<String> labels;
  final List<String> warnings;
  final BackendQuotaSnapshot? quotaSnapshot;

  ExtractionCandidate copyWith({
    String? title,
    String? creditorName,
    DebtType? debtType,
    double? currentBalance,
    double? originalBalance,
    double? aprPercentage,
    double? minimumPayment,
    DateTime? dueDate,
    DateTime? paymentDate,
    double? paymentAmount,
    String? currency,
    String? notes,
    double? confidence,
    String? last4,
    List<String>? labels,
    List<String>? warnings,
    BackendQuotaSnapshot? quotaSnapshot,
  }) {
    return ExtractionCandidate(
      title: title ?? this.title,
      creditorName: creditorName ?? this.creditorName,
      debtType: debtType ?? this.debtType,
      currentBalance: currentBalance ?? this.currentBalance,
      originalBalance: originalBalance ?? this.originalBalance,
      aprPercentage: aprPercentage ?? this.aprPercentage,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      confidence: confidence ?? this.confidence,
      last4: last4 ?? this.last4,
      labels: labels ?? this.labels,
      warnings: warnings ?? this.warnings,
      quotaSnapshot: quotaSnapshot ?? this.quotaSnapshot,
    );
  }
}

class StatementSummaryCandidate {
  const StatementSummaryCandidate({
    this.title,
    this.creditorName,
    this.debtType,
    this.currentBalance,
    this.originalBalance,
    this.aprPercentage,
    this.minimumPayment,
    this.dueDate,
    this.paymentDate,
    this.paymentAmount,
    this.statementStartDate,
    this.statementEndDate,
    this.currency,
    this.notes,
    this.confidence = 0,
    this.last4,
    this.labels = const [],
  });

  final String? title;
  final String? creditorName;
  final DebtType? debtType;
  final double? currentBalance;
  final double? originalBalance;
  final double? aprPercentage;
  final double? minimumPayment;
  final DateTime? dueDate;
  final DateTime? paymentDate;
  final double? paymentAmount;
  final DateTime? statementStartDate;
  final DateTime? statementEndDate;
  final String? currency;
  final String? notes;
  final double confidence;
  final String? last4;
  final List<String> labels;

  ExtractionCandidate toExtractionCandidate({
    List<String> warnings = const [],
    BackendQuotaSnapshot? quotaSnapshot,
  }) {
    return ExtractionCandidate(
      title: title,
      creditorName: creditorName,
      debtType: debtType,
      currentBalance: currentBalance,
      originalBalance: originalBalance,
      aprPercentage: aprPercentage,
      minimumPayment: minimumPayment,
      dueDate: dueDate,
      paymentDate: paymentDate,
      paymentAmount: paymentAmount,
      currency: currency,
      notes: notes,
      confidence: confidence,
      last4: last4,
      labels: labels,
      warnings: warnings,
      quotaSnapshot: quotaSnapshot,
    );
  }

  StatementSummaryCandidate copyWith({
    String? title,
    String? creditorName,
    DebtType? debtType,
    double? currentBalance,
    double? originalBalance,
    double? aprPercentage,
    double? minimumPayment,
    DateTime? dueDate,
    DateTime? paymentDate,
    double? paymentAmount,
    DateTime? statementStartDate,
    DateTime? statementEndDate,
    String? currency,
    String? notes,
    double? confidence,
    String? last4,
    List<String>? labels,
  }) {
    return StatementSummaryCandidate(
      title: title ?? this.title,
      creditorName: creditorName ?? this.creditorName,
      debtType: debtType ?? this.debtType,
      currentBalance: currentBalance ?? this.currentBalance,
      originalBalance: originalBalance ?? this.originalBalance,
      aprPercentage: aprPercentage ?? this.aprPercentage,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      statementStartDate: statementStartDate ?? this.statementStartDate,
      statementEndDate: statementEndDate ?? this.statementEndDate,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      confidence: confidence ?? this.confidence,
      last4: last4 ?? this.last4,
      labels: labels ?? this.labels,
    );
  }
}

class StatementLineItemCandidate {
  const StatementLineItemCandidate({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.confidence,
    this.date,
    this.currency,
    this.isSelected = true,
    this.warnings = const [],
    this.duplicateWarning,
  });

  final String id;
  final String description;
  final double amount;
  final StatementLineItemType type;
  final double confidence;
  final DateTime? date;
  final String? currency;
  final bool isSelected;
  final List<String> warnings;
  final String? duplicateWarning;

  bool get isPaymentLike => type == StatementLineItemType.payment;

  StatementLineItemCandidate copyWith({
    String? id,
    String? description,
    double? amount,
    StatementLineItemType? type,
    double? confidence,
    DateTime? date,
    String? currency,
    bool? isSelected,
    List<String>? warnings,
    String? duplicateWarning,
  }) {
    return StatementLineItemCandidate(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      isSelected: isSelected ?? this.isSelected,
      warnings: warnings ?? this.warnings,
      duplicateWarning: duplicateWarning ?? this.duplicateWarning,
    );
  }
}

class ImportIssue {
  const ImportIssue({
    required this.code,
    required this.message,
    this.isBlocking = false,
  });

  final String code;
  final String message;
  final bool isBlocking;
}

class ImportExtractionResult {
  const ImportExtractionResult({
    required this.summary,
    required this.statementLineItems,
    required this.warnings,
    required this.documentSignals,
    required this.errorMessage,
    required this.quotaSnapshot,
  });

  final StatementSummaryCandidate summary;
  final List<StatementLineItemCandidate> statementLineItems;
  final List<String> warnings;
  final List<String> documentSignals;
  final String? errorMessage;
  final BackendQuotaSnapshot? quotaSnapshot;
}

class ImportReviewBundle {
  const ImportReviewBundle({
    required this.document,
    required this.classification,
    required this.normalizedText,
    required this.candidate,
    required this.summary,
    required this.statementLineItems,
    required this.issues,
    required this.reviewMode,
    required this.errorMessage,
  });

  final ImportedDocument document;
  final DocumentClassification classification;
  final String normalizedText;
  final ExtractionCandidate candidate;
  final StatementSummaryCandidate summary;
  final List<StatementLineItemCandidate> statementLineItems;
  final List<ImportIssue> issues;
  final ImportReviewMode reviewMode;
  final String? errorMessage;

  bool get hasAiFailure => errorMessage != null;
}
