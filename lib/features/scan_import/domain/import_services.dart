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
      return OcrResult(
        text: text,
        lines: text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList(),
      );
    }

    final recognized = await _recognizer.processImage(
      InputImage.fromFilePath(file.path),
    );
    return OcrResult(
      text: recognized.text,
      lines: recognized.blocks
          .expand((block) => block.lines)
          .map((line) => line.text)
          .where((line) => line.trim().isNotEmpty)
          .toList(),
    );
  }
}

class DocumentClassifier {
  DocumentClassification classify(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('statement') && normalized.contains('credit')) {
      return DocumentClassification.creditCardStatement;
    }
    if (normalized.contains('loan') || normalized.contains('installment')) {
      return DocumentClassification.loanStatement;
    }
    if (normalized.contains('klarna') || normalized.contains('afterpay')) {
      return DocumentClassification.bnplDashboard;
    }
    if (normalized.contains('receipt') || normalized.contains('subtotal')) {
      return DocumentClassification.receipt;
    }
    if (normalized.contains('due date') ||
        normalized.contains('minimum payment')) {
      return DocumentClassification.genericBill;
    }
    if (normalized.contains('balance') || normalized.contains('payment')) {
      return DocumentClassification.genericFinanceScreenshot;
    }
    return DocumentClassification.unknown;
  }
}

class ParseValidationService {
  ExtractionCandidate validate(ExtractionCandidate candidate) {
    return candidate.copyWith(
      currentBalance: _clampPositive(candidate.currentBalance),
      originalBalance: _clampPositive(candidate.originalBalance),
      minimumPayment: _clampPositive(candidate.minimumPayment),
      paymentAmount: _clampPositive(candidate.paymentAmount),
      currency: candidate.currency?.toUpperCase(),
    );
  }

  double? _clampPositive(double? value) {
    if (value == null) {
      return null;
    }
    return value.isNegative ? 0 : value;
  }
}

abstract class AiExtractionService {
  Future<ExtractionCandidate> extract({
    required DocumentClassification classification,
    required String normalizedText,
    required DocumentSourceType sourceType,
    required bool allowCloud,
  });
}

class HeuristicExtractionParser {
  ExtractionCandidate parse(
    DocumentClassification classification,
    String text,
  ) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final balanceLine = lines.firstWhere(
      (line) => line.toLowerCase().contains('balance'),
      orElse: () => '',
    );
    final minimumLine = lines.firstWhere(
      (line) => line.toLowerCase().contains('minimum'),
      orElse: () => '',
    );
    final aprLine = lines.firstWhere(
      (line) =>
          line.toLowerCase().contains('apr') ||
          line.toLowerCase().contains('interest'),
      orElse: () => '',
    );
    final paymentLine = lines.firstWhere(
      (line) => line.toLowerCase().contains('payment'),
      orElse: () => '',
    );
    final dueLine = lines.firstWhere(
      (line) => line.toLowerCase().contains('due'),
      orElse: () => '',
    );

    return ExtractionCandidate(
      title: lines.isEmpty ? 'Imported debt' : lines.first,
      creditorName: lines.length > 1 ? lines[1] : null,
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
      dueDate: dueLine.isEmpty
          ? null
          : Parsers.parseDate(_tailSegment(dueLine)),
      currency: text.contains('€')
          ? 'EUR'
          : text.contains('£')
          ? 'GBP'
          : text.contains('৳')
          ? 'BDT'
          : 'USD',
      notes: 'Heuristic OCR extraction',
      confidence: classification == DocumentClassification.unknown
          ? 0.38
          : 0.63,
      labels: [
        classification.name,
        if (balanceLine.isNotEmpty) 'balance',
        if (minimumLine.isNotEmpty) 'minimum payment',
      ],
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

  String _tailSegment(String line) {
    final parts = line.split(RegExp(r'[:|-]'));
    return parts.isEmpty ? line : parts.last.trim();
  }
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
    final multiline = ocr.lines.join('\n').trim();
    final normalized = ocr.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final classification = classifier.classify(multiline);
    final candidate = validationService.validate(
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

    return ImportReviewBundle(
      document: ImportedDocument(
        id: const Uuid().v4(),
        storageRef: stored.storageRef,
        sourceType: input.sourceType,
        mimeType: input.mimeType,
        createdAt: now,
        linkedDebtId: null,
        rawOcrText: retainRaw ? normalized : null,
        parseStatus: candidate.confidence > 0
            ? ParseStatus.success
            : ParseStatus.failed,
        parseVersion: AppConstants.aiPromptVersion,
        deleted: false,
        retentionExpiresAt: retentionService.documentExpiry(
          preferences: preferences,
          parseStatus: candidate.confidence > 0
              ? ParseStatus.success
              : ParseStatus.failed,
          now: now,
        ),
        purgedAt: null,
        encryptedAt: stored.encryptedAt,
        hasRawOcrText: retainRaw && normalized.isNotEmpty,
      ),
      classification: classification,
      normalizedText: multiline,
      candidate: candidate,
      statementLineItems: const [],
      errorMessage: candidate.confidence > 0
          ? null
          : 'Cloud parse failed. Continue with manual review.',
    );
  }
}
