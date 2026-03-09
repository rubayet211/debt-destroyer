import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/vault_services.dart';
import '../../../core/utils/parsers.dart';
import '../../../shared/data/repositories.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/import_models.dart';

class FileReference {
  const FileReference({
    required this.path,
    required this.sourceType,
    required this.mimeType,
  });

  final String path;
  final DocumentSourceType sourceType;
  final String mimeType;
}

class OcrResult {
  const OcrResult({required this.text, required this.lines});

  final String text;
  final List<String> lines;
}

abstract class ImagePreprocessService {
  Future<FileReference> preprocess(FileReference input);
}

class PassthroughImagePreprocessService implements ImagePreprocessService {
  @override
  Future<FileReference> preprocess(FileReference input) async => input;
}

abstract class OcrService {
  Future<OcrResult> extractText(FileReference file);
}

class MlKitOcrService implements OcrService {
  MlKitOcrService()
    : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<OcrResult> extractText(FileReference file) async {
    if (file.mimeType.contains('pdf')) {
      final bytes = await File(file.path).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      final text = extractor.extractText();
      document.dispose();
      final lines = text
          .split('\n')
          .map(_normalizeLine)
          .where((line) => line.isNotEmpty)
          .toList();
      return OcrResult(text: text, lines: lines);
    }

    final recognized = await _recognizer.processImage(
      InputImage.fromFilePath(file.path),
    );
    final lines = recognized.blocks
        .expand((block) => block.lines)
        .map((line) => _normalizeLine(line.text))
        .where((line) => line.isNotEmpty)
        .toList();
    return OcrResult(text: recognized.text, lines: lines);
  }

  String _normalizeLine(String line) =>
      line.replaceAll(RegExp(r'\s+'), ' ').trim();
}

class DocumentClassifier {
  DocumentClassification classify(String text) {
    final normalized = text.toLowerCase();
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final statementLikeRows = lines.where(_looksLikeStatementRow).length;
    final statementScore =
        _keywordScore(normalized, const [
          'statement',
          'minimum payment',
          'statement period',
          'payment due',
          'new balance',
          'current balance',
        ]) +
        (statementLikeRows >= 3 ? 3 : 0);
    final loanScore = _keywordScore(normalized, const [
      'loan statement',
      'installment',
      'principal balance',
      'loan number',
      'maturity',
    ]);
    final bnplScore = _keywordScore(normalized, const [
      'klarna',
      'afterpay',
      'affirm',
      'zip pay',
      'pay in 4',
      'installments remaining',
    ]);
    final receiptScore = _keywordScore(normalized, const [
      'receipt',
      'subtotal',
      'tax',
      'merchant',
      'total',
      'change',
    ]);
    final billScore = _keywordScore(normalized, const [
      'invoice',
      'amount due',
      'due date',
      'billing period',
      'utility',
      'account number',
    ]);
    final screenshotScore = _keywordScore(normalized, const [
      'available credit',
      'payment due',
      'account overview',
      'dashboard',
      'recent activity',
      'next payment',
    ]);

    if (statementScore >= 3 &&
        normalized.contains('credit') &&
        normalized.contains('statement')) {
      return DocumentClassification.creditCardStatement;
    }
    if (loanScore >= 3) {
      return DocumentClassification.loanStatement;
    }
    if (bnplScore >= 2) {
      return DocumentClassification.bnplDashboard;
    }
    if (receiptScore >= 3) {
      return DocumentClassification.receipt;
    }
    if (billScore >= 3) {
      return DocumentClassification.genericBill;
    }
    if (statementScore >= 4 || screenshotScore >= 3) {
      return DocumentClassification.genericFinanceScreenshot;
    }
    return DocumentClassification.unknown;
  }

  int _keywordScore(String haystack, List<String> keywords) {
    return keywords.where(haystack.contains).length;
  }

  bool _looksLikeStatementRow(String line) {
    final hasDate = RegExp(
      r'(^|\s)(\d{1,2}[/-]\d{1,2}([/-]\d{2,4})?|\d{4}-\d{2}-\d{2})(\s|$)',
    ).hasMatch(line);
    final hasAmount = RegExp(r'[-(]?\$?\d[\d,]*\.\d{2}\)?').hasMatch(line);
    return hasDate && hasAmount;
  }
}

class ParseValidationService {
  ImportExtractionResult validate(ImportExtractionResult result) {
    final warnings = [...result.warnings];
    final summary = result.summary.copyWith(
      currentBalance: _clampPositive(result.summary.currentBalance),
      originalBalance: _clampPositive(result.summary.originalBalance),
      minimumPayment: _clampPositive(result.summary.minimumPayment),
      paymentAmount: _clampPositive(result.summary.paymentAmount),
      aprPercentage: _clampPositive(result.summary.aprPercentage),
      currency: result.summary.currency?.toUpperCase(),
      labels: result.summary.labels
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(),
    );
    final items = <StatementLineItemCandidate>[];
    for (final item in result.statementLineItems) {
      final amount = _normalizeSignedAmount(item.amount, item.type);
      if (amount == 0) {
        warnings.add('dropped_zero_amount_line_item');
        continue;
      }
      if (item.description.trim().isEmpty) {
        warnings.add('dropped_empty_description_line_item');
        continue;
      }
      items.add(
        item.copyWith(
          amount: amount,
          currency: item.currency?.toUpperCase() ?? summary.currency,
          warnings: item.warnings.toSet().toList(),
        ),
      );
    }
    return ImportExtractionResult(
      summary: summary,
      statementLineItems: items,
      warnings: warnings.toSet().toList(),
      documentSignals: result.documentSignals.toSet().toList(),
      errorMessage: result.errorMessage,
      quotaSnapshot: result.quotaSnapshot,
    );
  }

  double? _clampPositive(double? value) {
    if (value == null) {
      return null;
    }
    return value.isNegative ? 0 : value;
  }

  double _normalizeSignedAmount(double value, StatementLineItemType type) {
    final absolute = value.abs();
    return switch (type) {
      StatementLineItemType.payment => absolute,
      StatementLineItemType.charge ||
      StatementLineItemType.fee ||
      StatementLineItemType.interest => -absolute,
      StatementLineItemType.other => value,
    };
  }
}

abstract class AiExtractionService {
  Future<ImportExtractionResult> extract({
    required DocumentClassification classification,
    required String normalizedText,
    required DocumentSourceType sourceType,
    required bool allowCloud,
  });
}

class StatementSummaryParser {
  const StatementSummaryParser();

  StatementSummaryCandidate parse(
    DocumentClassification classification,
    String text,
  ) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final lowerLines = lines.map((line) => line.toLowerCase()).toList();
    final balanceLine = _findLine(lowerLines, lines, const [
      'current balance',
      'new balance',
      'ending balance',
      'balance due',
      'balance',
    ]);
    final minimumLine = _findLine(lowerLines, lines, const [
      'minimum payment',
      'minimum due',
      'minimum',
    ]);
    final aprLine = _findLine(lowerLines, lines, const [
      'apr',
      'interest rate',
      'purchase apr',
    ]);
    final paymentLine = _findLine(lowerLines, lines, const [
      'payment received',
      'payment posted',
      'last payment',
      'payment amount',
      'payment',
    ]);
    final dueLine = _findLine(lowerLines, lines, const [
      'payment due',
      'due date',
      'due',
    ]);
    final statementLine = _findStatementPeriodLine(lowerLines, lines);
    final title = lines.isEmpty ? 'Imported debt' : lines.first;
    final creditorName = lines.length > 1
        ? lines[1]
        : (lines.isEmpty ? null : lines.first);
    final statementRange = _parseStatementRange(statementLine);
    final labels = <String>[
      classification.name,
      if (balanceLine.isNotEmpty) 'balance',
      if (minimumLine.isNotEmpty) 'minimum payment',
      if (statementLine.isNotEmpty) 'statement period',
    ];

    final extractedFields = [
      balanceLine,
      minimumLine,
      aprLine,
      paymentLine,
      dueLine,
      statementLine,
    ].where((line) => line.isNotEmpty).length;

    return StatementSummaryCandidate(
      title: title,
      creditorName: creditorName,
      debtType: _defaultTypeForClassification(classification),
      currentBalance: balanceLine.isEmpty
          ? null
          : Parsers.parseMoney(balanceLine),
      originalBalance: balanceLine.isEmpty
          ? null
          : Parsers.parseMoney(balanceLine),
      aprPercentage: aprLine.isEmpty ? null : Parsers.parseMoney(aprLine),
      minimumPayment: minimumLine.isEmpty
          ? null
          : Parsers.parseMoney(minimumLine),
      paymentAmount: paymentLine.isEmpty
          ? null
          : Parsers.parseMoney(paymentLine),
      paymentDate: _parseDateFromLine(paymentLine),
      dueDate: _parseDateFromLine(dueLine),
      statementStartDate: statementRange.$1,
      statementEndDate: statementRange.$2,
      currency: _detectCurrency(text),
      notes: extractedFields >= 2
          ? 'Heuristic statement summary extraction'
          : 'Manual review recommended',
      confidence: classification == DocumentClassification.unknown
          ? 0.34
          : (0.45 + (extractedFields * 0.08)).clamp(0.34, 0.86),
      last4: _parseLast4(text),
      labels: labels,
    );
  }

  DebtType? mapDebtType(String? raw) {
    if (raw == null) {
      return null;
    }
    return switch (raw.toLowerCase()) {
      'credit_card' || 'credit card' => DebtType.creditCard,
      'personal_loan' || 'personal loan' => DebtType.personalLoan,
      'student_loan' || 'student loan' => DebtType.studentLoan,
      'car_loan' || 'car loan' => DebtType.carLoan,
      'mortgage' => DebtType.mortgage,
      'bnpl' => DebtType.bnpl,
      'family_loan' || 'family loan' => DebtType.familyLoan,
      'utility_arrears' || 'utility arrears' => DebtType.utilityArrears,
      _ => DebtType.other,
    };
  }

  DebtType _defaultTypeForClassification(
    DocumentClassification classification,
  ) {
    switch (classification) {
      case DocumentClassification.creditCardStatement:
        return DebtType.creditCard;
      case DocumentClassification.loanStatement:
        return DebtType.personalLoan;
      case DocumentClassification.bnplDashboard:
        return DebtType.bnpl;
      default:
        return DebtType.other;
    }
  }

  String _findLine(
    List<String> lowerLines,
    List<String> originalLines,
    List<String> keywords,
  ) {
    for (var i = 0; i < lowerLines.length; i++) {
      if (keywords.any(lowerLines[i].contains)) {
        return originalLines[i];
      }
    }
    return '';
  }

  String _findStatementPeriodLine(
    List<String> lowerLines,
    List<String> originalLines,
  ) {
    final explicit = _findLine(lowerLines, originalLines, const [
      'statement period',
      'billing period',
    ]);
    if (explicit.isNotEmpty) {
      return explicit;
    }
    for (var i = 0; i < lowerLines.length; i++) {
      final lower = lowerLines[i];
      if (!lower.contains('statement from') &&
          !lower.contains('billing from') &&
          !lower.contains('period from')) {
        continue;
      }
      final matches = RegExp(
        r'(\d{4}-\d{2}-\d{2}|\d{1,2}/\d{1,2}/\d{2,4})',
      ).allMatches(originalLines[i]);
      if (matches.length >= 2) {
        return originalLines[i];
      }
    }
    return '';
  }

  DateTime? _parseDateFromLine(String line) {
    if (line.isEmpty) {
      return null;
    }
    final match = RegExp(
      r'(\d{4}-\d{2}-\d{2}|\d{1,2}/\d{1,2}/\d{2,4})',
    ).firstMatch(line);
    return match == null ? null : Parsers.parseDate(match.group(0));
  }

  (DateTime?, DateTime?) _parseStatementRange(String line) {
    if (line.isEmpty) {
      return (null, null);
    }
    final matches = RegExp(
      r'(\d{4}-\d{2}-\d{2}|\d{1,2}/\d{1,2}/\d{2,4})',
    ).allMatches(line).toList();
    if (matches.length < 2) {
      return (null, null);
    }
    return (
      Parsers.parseDate(matches.first.group(0)),
      Parsers.parseDate(matches[1].group(0)),
    );
  }

  String _detectCurrency(String text) {
    if (text.contains('€')) {
      return 'EUR';
    }
    if (text.contains('£')) {
      return 'GBP';
    }
    if (text.contains('৳')) {
      return 'BDT';
    }
    final upper = text.toUpperCase();
    if (upper.contains('EUR')) {
      return 'EUR';
    }
    if (upper.contains('GBP')) {
      return 'GBP';
    }
    return 'USD';
  }

  String? _parseLast4(String text) {
    final match = RegExp(
      r'(?:ending|last|acct|account)\D*(\d{4})',
    ).firstMatch(text.toLowerCase());
    return match?.group(1);
  }
}

class StatementLineItemParser {
  StatementLineItemParser() : _uuid = const Uuid();

  final Uuid _uuid;

  List<StatementLineItemCandidate> parse(
    DocumentClassification classification,
    String text,
  ) {
    final lines = _prepareLines(text);
    if (classification == DocumentClassification.receipt || lines.length < 2) {
      return const [];
    }
    final items = <StatementLineItemCandidate>[];
    StatementLineItemCandidate? previous;
    for (final line in lines) {
      final item = _parseLine(line);
      if (item == null) {
        continue;
      }
      if (previous != null &&
          previous.description == item.description &&
          previous.amount == item.amount &&
          previous.date == item.date) {
        continue;
      }
      items.add(item);
      previous = item;
    }
    return items;
  }

  List<String> _prepareLines(String text) {
    final merged = <String>[];
    for (final rawLine in text.split('\n')) {
      final line = rawLine.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (line.isEmpty) {
        continue;
      }
      if (merged.isNotEmpty &&
          !_hasAmount(line) &&
          !_startsWithDate(line) &&
          line.length > 3) {
        merged[merged.length - 1] = '${merged.last} $line';
        continue;
      }
      merged.add(line);
    }
    return merged;
  }

  StatementLineItemCandidate? _parseLine(String line) {
    if (_isSummaryLine(line)) {
      return null;
    }
    final amounts = RegExp(
      r'[-(]?\$?\d[\d,]*\.\d{2}\)?',
    ).allMatches(line).map((match) => match.group(0)!).toList();
    if (amounts.isEmpty) {
      return null;
    }
    final description = _extractDescription(line, amounts.last);
    if (description.isEmpty || description.length < 3) {
      return null;
    }
    final type = _classifyType(description);
    final warnings = <String>[];
    final date = _parseLineDate(line, warnings);
    final amount = _parseSignedAmount(amounts.last, type);
    if (amount == null) {
      return null;
    }
    final confidence = _confidenceFor(
      description: description,
      date: date,
      type: type,
      warnings: warnings,
    );
    if (confidence < 0.25) {
      return null;
    }
    return StatementLineItemCandidate(
      id: _uuid.v4(),
      description: description,
      amount: amount,
      type: type,
      confidence: confidence,
      date: date,
      warnings: warnings,
    );
  }

  String _extractDescription(String line, String amountText) {
    var description = line.replaceFirst(amountText, '').trim();
    description = description.replaceFirst(
      RegExp(r'^(\d{4}-\d{2}-\d{2}|\d{1,2}/\d{1,2}([/-]\d{2,4})?)\s*'),
      '',
    );
    description = description.replaceAll(RegExp(r'\s+'), ' ').trim();
    return description;
  }

  StatementLineItemType _classifyType(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('payment') ||
        lower.contains('autopay') ||
        lower.contains('thank you')) {
      return StatementLineItemType.payment;
    }
    if (lower.contains('interest') || lower.contains('finance charge')) {
      return StatementLineItemType.interest;
    }
    if (lower.contains('fee')) {
      return StatementLineItemType.fee;
    }
    if (lower.contains('purchase') ||
        lower.contains('pos ') ||
        lower.contains('debit ') ||
        lower.contains('charge')) {
      return StatementLineItemType.charge;
    }
    return StatementLineItemType.other;
  }

  DateTime? _parseLineDate(String line, List<String> warnings) {
    final fullMatch = RegExp(
      r'(\d{4}-\d{2}-\d{2}|\d{1,2}/\d{1,2}/\d{2,4})',
    ).firstMatch(line);
    if (fullMatch != null) {
      return Parsers.parseDate(fullMatch.group(0));
    }
    final ambiguous = RegExp(r'(\d{1,2}/\d{1,2})(?!/)').firstMatch(line);
    if (ambiguous != null) {
      warnings.add('ambiguous_date');
    }
    return null;
  }

  double? _parseSignedAmount(String amountText, StatementLineItemType type) {
    final cleaned = amountText.replaceAll(RegExp(r'[^0-9.()-]'), '');
    final numeric = double.tryParse(
      cleaned.replaceAll('(', '-').replaceAll(')', ''),
    );
    if (numeric == null) {
      return null;
    }
    final absolute = numeric.abs();
    return switch (type) {
      StatementLineItemType.payment => absolute,
      StatementLineItemType.charge ||
      StatementLineItemType.fee ||
      StatementLineItemType.interest => -absolute,
      StatementLineItemType.other => numeric,
    };
  }

  double _confidenceFor({
    required String description,
    required DateTime? date,
    required StatementLineItemType type,
    required List<String> warnings,
  }) {
    var confidence = 0.35;
    if (description.length > 5) {
      confidence += 0.2;
    }
    if (date != null) {
      confidence += 0.2;
    }
    if (type != StatementLineItemType.other) {
      confidence += 0.15;
    }
    if (warnings.isNotEmpty) {
      confidence -= 0.1;
    }
    return confidence.clamp(0, 0.95);
  }

  bool _hasAmount(String line) =>
      RegExp(r'[-(]?\$?\d[\d,]*\.\d{2}\)?').hasMatch(line);

  bool _startsWithDate(String line) => RegExp(
    r'^(\d{4}-\d{2}-\d{2}|\d{1,2}/\d{1,2}([/-]\d{2,4})?)',
  ).hasMatch(line);

  bool _isSummaryLine(String line) {
    final normalized = line.toLowerCase();
    return normalized.contains('current balance') ||
        normalized.contains('new balance') ||
        normalized.contains('minimum payment') ||
        normalized.contains('statement period') ||
        normalized.contains('billing period') ||
        normalized.contains('due date') ||
        normalized.contains('payment due') ||
        normalized.contains('account ending');
  }
}

class HeuristicExtractionParser {
  HeuristicExtractionParser({
    StatementSummaryParser? summaryParser,
    StatementLineItemParser? lineItemParser,
  }) : _summaryParser = summaryParser ?? const StatementSummaryParser(),
       _lineItemParser = lineItemParser ?? StatementLineItemParser();

  final StatementSummaryParser _summaryParser;
  final StatementLineItemParser _lineItemParser;

  ImportExtractionResult parse(
    DocumentClassification classification,
    String text,
  ) {
    final summary = _summaryParser.parse(classification, text);
    final lineItems = _lineItemParser.parse(classification, text);
    final warnings = <String>[
      if (summary.confidence < 0.5) 'low_confidence',
      if (summary.currentBalance == null &&
          summary.paymentAmount == null &&
          lineItems.isEmpty)
        'no_amount_detected',
      if (lineItems.isNotEmpty &&
          !lineItems.any((item) => item.isPaymentLike && item.date != null))
        'statement_items_need_review',
    ];
    return ImportExtractionResult(
      summary: summary,
      statementLineItems: lineItems,
      warnings: warnings,
      documentSignals: [
        classification.name,
        if (lineItems.isNotEmpty) 'local_statement_lines',
      ],
      errorMessage: summary.confidence > 0 ? null : 'Manual review required.',
      quotaSnapshot: null,
    );
  }

  DebtType? mapDebtType(String? raw) => _summaryParser.mapDebtType(raw);
}

class ImportCoordinator {
  ImportCoordinator({
    required this.documentVaultService,
    required this.preprocessService,
    required this.ocrService,
    required this.classifier,
    required this.aiExtractionService,
    required this.validationService,
    required this.preferencesRepository,
    required this.retentionService,
  });

  final SecureDocumentVaultService documentVaultService;
  final ImagePreprocessService preprocessService;
  final OcrService ocrService;
  final DocumentClassifier classifier;
  final AiExtractionService aiExtractionService;
  final ParseValidationService validationService;
  final PreferencesRepository preferencesRepository;
  final DataRetentionService retentionService;

  Future<ImportReviewBundle> process({
    required FileReference input,
    required bool allowCloud,
  }) async {
    final preferences = await preferencesRepository.loadPreferences();
    final preprocessed = await preprocessService.preprocess(input);
    final ocr = await ocrService.extractText(preprocessed);
    final multiline = _normalizeMultiline(ocr.lines, ocr.text);
    final classification = classifier.classify(multiline);
    final extracted = validationService.validate(
      await aiExtractionService.extract(
        classification: classification,
        normalizedText: multiline,
        sourceType: input.sourceType,
        allowCloud: allowCloud,
      ),
    );
    final stored = await documentVaultService.sealImport(input);
    final now = DateTime.now();
    final retainRaw = retentionService.shouldRetainRawOcr(preferences);
    final rawOcrExpiry = retentionService.rawOcrExpiry(preferences, now);
    final parseSucceeded =
        extracted.summary.confidence > 0 ||
        extracted.statementLineItems.isNotEmpty;
    final candidate = extracted.summary.toExtractionCandidate(
      warnings: extracted.warnings,
      quotaSnapshot: extracted.quotaSnapshot,
    );
    final issues = _buildIssues(
      classification: classification,
      extraction: extracted,
      allowCloud: allowCloud,
    );

    return ImportReviewBundle(
      document: ImportedDocument(
        id: const Uuid().v4(),
        storageRef: stored.storageRef,
        sourceType: input.sourceType,
        mimeType: input.mimeType,
        createdAt: now,
        lifecycleState: DocumentLifecycleState.processed,
        linkedDebtId: null,
        rawOcrText: retainRaw ? multiline : null,
        parseStatus: parseSucceeded ? ParseStatus.success : ParseStatus.failed,
        parseVersion: AppConstants.aiPromptVersion,
        deleted: false,
        retentionExpiresAt: retentionService.documentExpiry(
          preferences: preferences,
          parseStatus: parseSucceeded
              ? ParseStatus.success
              : ParseStatus.failed,
          now: now,
        ),
        rawOcrExpiresAt: retainRaw ? rawOcrExpiry : null,
        processedAt: now,
        linkedAt: null,
        pendingDeletionAt: null,
        purgedAt: null,
        encryptedAt: stored.encryptedAt,
        hasRawOcrText: retainRaw && multiline.isNotEmpty,
      ),
      classification: classification,
      normalizedText: multiline,
      candidate: candidate,
      summary: extracted.summary,
      statementLineItems: extracted.statementLineItems,
      issues: issues,
      reviewMode: _reviewModeFor(classification, extracted),
      errorMessage:
          extracted.errorMessage ??
          (!allowCloud ? 'Using local OCR parsing only.' : null),
    );
  }

  String _normalizeMultiline(List<String> lines, String fallbackText) {
    final normalizedLines = (lines.isEmpty ? fallbackText.split('\n') : lines)
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return normalizedLines.join('\n').trim();
  }

  ImportReviewMode _reviewModeFor(
    DocumentClassification classification,
    ImportExtractionResult extracted,
  ) {
    if (extracted.statementLineItems.isNotEmpty) {
      return ImportReviewMode.statementItems;
    }
    if (classification == DocumentClassification.unknown ||
        extracted.summary.confidence < 0.45) {
      return ImportReviewMode.manualFallback;
    }
    return ImportReviewMode.summaryOnly;
  }

  List<ImportIssue> _buildIssues({
    required DocumentClassification classification,
    required ImportExtractionResult extraction,
    required bool allowCloud,
  }) {
    final issues = <ImportIssue>[
      ...extraction.warnings.map(
        (warning) => ImportIssue(
          code: warning,
          message: _warningMessage(warning),
          isBlocking: warning == 'quota_exhausted',
        ),
      ),
    ];
    if (classification == DocumentClassification.unknown) {
      issues.add(
        const ImportIssue(
          code: 'unknown_document',
          message: 'Document type is uncertain. Review fields manually.',
        ),
      );
    }
    if (!allowCloud) {
      issues.add(
        const ImportIssue(
          code: 'local_only',
          message:
              'Cloud structuring was skipped. Local OCR results may need more manual edits.',
        ),
      );
    }
    for (final item in extraction.statementLineItems) {
      for (final warning in item.warnings) {
        issues.add(
          ImportIssue(code: warning, message: _warningMessage(warning)),
        );
      }
    }
    return issues.toSetBy((issue) => '${issue.code}:${issue.message}').toList();
  }

  String _warningMessage(String code) {
    return switch (code) {
      'low_confidence' =>
        'Extraction confidence is low. Review all fields before saving.',
      'no_amount_detected' =>
        'Amounts were not detected reliably. Manual correction is recommended.',
      'statement_items_need_review' =>
        'Statement line items were detected, but some rows need review.',
      'ambiguous_date' =>
        'Some line item dates were incomplete and were left unset.',
      'quota_exhausted' =>
        'Cloud extraction quota is exhausted. You can continue with local OCR only.',
      'backend_unavailable' =>
        'Secure cloud extraction is temporarily unavailable. Local OCR results are shown.',
      _ => code.replaceAll('_', ' '),
    };
  }
}

extension<T> on Iterable<T> {
  List<T> toSetBy(String Function(T item) keyOf) {
    final seen = <String>{};
    final values = <T>[];
    for (final item in this) {
      if (seen.add(keyOf(item))) {
        values.add(item);
      }
    }
    return values;
  }
}
