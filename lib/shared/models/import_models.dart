import 'backend_models.dart';
import '../enums/app_enums.dart';

class ImportedDocument {
  const ImportedDocument({
    required this.id,
    required this.storageRef,
    required this.sourceType,
    required this.mimeType,
    required this.createdAt,
    required this.linkedDebtId,
    required this.rawOcrText,
    required this.parseStatus,
    required this.parseVersion,
    required this.deleted,
    required this.retentionExpiresAt,
    required this.rawOcrExpiresAt,
    required this.purgedAt,
    required this.encryptedAt,
    required this.hasRawOcrText,
  });

  final String id;
  final String? storageRef;
  final DocumentSourceType sourceType;
  final String mimeType;
  final DateTime createdAt;
  final String? linkedDebtId;
  final String? rawOcrText;
  final ParseStatus parseStatus;
  final String parseVersion;
  final bool deleted;
  final DateTime? retentionExpiresAt;
  final DateTime? rawOcrExpiresAt;
  final DateTime? purgedAt;
  final DateTime? encryptedAt;
  final bool hasRawOcrText;

  ImportedDocument copyWith({
    String? storageRef,
    String? linkedDebtId,
    String? rawOcrText,
    ParseStatus? parseStatus,
    bool? deleted,
    DateTime? retentionExpiresAt,
    DateTime? rawOcrExpiresAt,
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
      linkedDebtId: linkedDebtId ?? this.linkedDebtId,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      parseStatus: parseStatus ?? this.parseStatus,
      parseVersion: parseVersion,
      deleted: deleted ?? this.deleted,
      retentionExpiresAt: retentionExpiresAt ?? this.retentionExpiresAt,
      rawOcrExpiresAt: rawOcrExpiresAt ?? this.rawOcrExpiresAt,
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

class ImportReviewBundle {
  const ImportReviewBundle({
    required this.document,
    required this.classification,
    required this.normalizedText,
    required this.candidate,
    required this.statementLineItems,
    required this.errorMessage,
  });

  final ImportedDocument document;
  final DocumentClassification classification;
  final String normalizedText;
  final ExtractionCandidate candidate;
  final List<ExtractionCandidate> statementLineItems;
  final String? errorMessage;

  bool get hasAiFailure => errorMessage != null;
}
