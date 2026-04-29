import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:debt_destroyer/core/services/vault_services.dart';
import 'package:debt_destroyer/features/scan_import/domain/import_services.dart';
import 'package:debt_destroyer/features/scan_import/presentation/scan_screens.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/import_models.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

void main() {
  testWidgets('processing screen prepares review without persisting documents', (
    tester,
  ) async {
    final coordinator = _SuccessfulImportCoordinator();
    final documentsRepository = _RecordingDocumentsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          importCoordinatorProvider.overrideWith((_) => coordinator),
          documentsRepositoryProvider.overrideWithValue(documentsRepository),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => OCRProcessingScreen(
                  fileReference: const FileReference(
                    path: 'test.png',
                    sourceType: DocumentSourceType.gallery,
                    mimeType: 'image/png',
                  ),
                  allowCloud: false,
                ),
              ),
              GoRoute(
                path: '/scan/review',
                builder: (context, state) => const Scaffold(
                  body: Text('Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(documentsRepository.savedDocuments, isEmpty);
  });

  testWidgets('processing screen shows retry state after OCR failure', (
    tester,
  ) async {
    final coordinator = _FailingImportCoordinator();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          importCoordinatorProvider.overrideWith((_) => coordinator),
          documentsRepositoryProvider.overrideWithValue(
            _NoopDocumentsRepository(),
          ),
        ],
        child: MaterialApp(
          home: OCRProcessingScreen(
            fileReference: const FileReference(
              path: 'test.png',
              sourceType: DocumentSourceType.gallery,
              mimeType: 'image/png',
            ),
            allowCloud: false,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text('OCR failed. Try another document or enter the debt manually.'),
      findsOneWidget,
    );
    expect(coordinator.calls, 1);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(coordinator.calls, 2);
  });
}

class _FailingImportCoordinator extends ImportCoordinator {
  _FailingImportCoordinator()
    : super(
        documentVaultService: _DummyVaultService(),
        preprocessService: _DummyPreprocessService(),
        ocrService: _DummyOcrService(),
        classifier: DocumentClassifier(),
        aiExtractionService: _DummyAiExtractionService(),
        validationService: ParseValidationService(),
        preferencesRepository: _DummyPreferencesRepository(),
        retentionService: const DataRetentionService(),
      );

  int calls = 0;

  @override
  Future<ImportReviewBundle> process({
    required FileReference input,
    required bool allowCloud,
  }) async {
    calls += 1;
    throw StateError('OCR engine failed');
  }
}

class _SuccessfulImportCoordinator extends ImportCoordinator {
  _SuccessfulImportCoordinator()
    : super(
        documentVaultService: _DummyVaultService(),
        preprocessService: _DummyPreprocessService(),
        ocrService: _DummyOcrService(),
        classifier: DocumentClassifier(),
        aiExtractionService: _DummyAiExtractionService(),
        validationService: ParseValidationService(),
        preferencesRepository: _DummyPreferencesRepository(),
        retentionService: const DataRetentionService(),
      );

  @override
  Future<ImportReviewBundle> process({
    required FileReference input,
    required bool allowCloud,
  }) async {
    return ImportReviewBundle(
      document: ImportedDocument(
        id: 'doc-processing-success',
        storageRef: 'vault-processing-success',
        sourceType: input.sourceType,
        mimeType: input.mimeType,
        createdAt: DateTime(2026, 3, 1),
        lifecycleState: DocumentLifecycleState.processed,
        linkedDebtId: null,
        rawOcrText: null,
        parseStatus: ParseStatus.success,
        parseVersion: 'v1',
        deleted: false,
        retentionExpiresAt: null,
        rawOcrExpiresAt: null,
        processedAt: DateTime(2026, 3, 1),
        linkedAt: null,
        pendingDeletionAt: null,
        purgedAt: null,
        encryptedAt: DateTime(2026, 3, 1),
        hasRawOcrText: false,
      ),
      classification: DocumentClassification.creditCardStatement,
      normalizedText: 'ACME CREDIT CARD STATEMENT',
      candidate: const ExtractionCandidate(
        title: 'Imported debt',
        creditorName: 'Acme Bank',
        debtType: DebtType.creditCard,
        currentBalance: 500,
        confidence: 0.9,
      ),
      summary: const StatementSummaryCandidate(
        title: 'Imported debt',
        creditorName: 'Acme Bank',
        debtType: DebtType.creditCard,
        currentBalance: 500,
        confidence: 0.9,
      ),
      statementLineItems: const [],
      issues: const [],
      reviewMode: ImportReviewMode.summaryOnly,
      errorMessage: null,
    );
  }
}

class _NoopDocumentsRepository implements DocumentsRepository {
  @override
  Future<int> countSuccessfulScansInMonth(DateTime month) async => 0;

  @override
  Future<List<ImportedDocument>> loadDocuments({String? debtId}) async =>
      const [];

  @override
  Future<void> linkDocument(String documentId, String? debtId) async {}

  @override
  Future<void> markDeleted(String documentId) async {}

  @override
  Future<void> purgeAllDocuments() async {}

  @override
  Future<void> purgeAllRawOcr() async {}

  @override
  Future<void> purgeDocument(String documentId) async {}

  @override
  Future<void> purgeExpiredDocuments(DateTime now) async {}

  @override
  Future<Uint8List?> readDocumentBytes(String documentId) async => null;

  @override
  Future<void> saveDocument(ImportedDocument document) async {}

  @override
  Future<void> saveParsedExtraction(ParsedExtraction extraction) async {}

  @override
  Future<void> trimRawOcr(String documentId) async {}

  @override
  Stream<List<ImportedDocument>> watchDocuments({String? debtId}) =>
      Stream.value(const <ImportedDocument>[]);
}

class _RecordingDocumentsRepository extends _NoopDocumentsRepository {
  final List<ImportedDocument> savedDocuments = [];

  @override
  Future<void> saveDocument(ImportedDocument document) async {
    savedDocuments.add(document);
  }
}

class _DummyVaultService extends SecureDocumentVaultService {
  _DummyVaultService() : super(_DummyKeyService());
}

class _DummyKeyService extends LocalVaultKeyService {}

class _DummyPreprocessService implements ImagePreprocessService {
  @override
  Future<FileReference> preprocess(FileReference input) async => input;
}

class _DummyOcrService implements OcrService {
  @override
  Future<OcrResult> extractText(FileReference file) async =>
      const OcrResult(text: '', lines: []);
}

class _DummyAiExtractionService implements AiExtractionService {
  @override
  Future<ImportExtractionResult> extract({
    required DocumentClassification classification,
    required String normalizedText,
    required DocumentSourceType sourceType,
    required bool allowCloud,
  }) async {
    return const ImportExtractionResult(
      summary: StatementSummaryCandidate(confidence: 0),
      statementLineItems: [],
      warnings: [],
      documentSignals: [],
      errorMessage: null,
      quotaSnapshot: null,
    );
  }
}

class _DummyPreferencesRepository implements PreferencesRepository {
  @override
  Future<UserPreferences> loadPreferences() async => UserPreferences.defaults();

  @override
  Future<void> savePreferences(UserPreferences preferences) async {}

  @override
  Stream<UserPreferences> watchPreferences() =>
      Stream.value(UserPreferences.defaults());
}
