import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/core/services/vault_services.dart';
import 'package:debt_destroyer/features/scan_import/domain/import_services.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/import_models.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';

void main() {
  group('Import parsing', () {
    final parser = HeuristicExtractionParser();
    final validator = ParseValidationService();
    final classifier = DocumentClassifier();

    test('classifies credit card style statements', () {
      final classification = classifier.classify(
        'CREDIT CARD STATEMENT\nCurrent balance: \$1200\nMinimum payment: \$35',
      );

      expect(classification, DocumentClassification.creditCardStatement);
    });

    test('parses and sanitizes common debt fields', () {
      final candidate = validator.validate(
        parser.parse(
          DocumentClassification.creditCardStatement,
          'Acme Bank\nCurrent balance: \$1,240.55\nMinimum payment: \$75\nAPR 19.9%\nDue: 03/15/2026',
        ),
      );

      expect(candidate.summary.currentBalance, 1240.55);
      expect(candidate.summary.minimumPayment, 75);
      expect(candidate.summary.aprPercentage, 19.9);
      expect(candidate.summary.currency, 'USD');
      expect(candidate.summary.debtType, DebtType.creditCard);
    });

    test('keeps manual fallback viable when classification is unknown', () {
      final candidate = parser.parse(
        DocumentClassification.unknown,
        'random OCR text without reliable fields',
      );

      expect(candidate.summary.confidence, lessThan(0.5));
      expect(candidate.summary.title, isNotEmpty);
    });

    test('extracts multiple statement line items from tabular text', () {
      final result = validator.validate(
        parser.parse(DocumentClassification.creditCardStatement, '''
ACME BANK CREDIT CARD STATEMENT
Statement Period 02/01/2026 - 02/29/2026
02/05/2026 ONLINE PAYMENT THANK YOU 250.00
02/12/2026 AMAZON MARKETPLACE 85.42
02/15/2026 INTEREST CHARGE 12.33
Current balance: \$1,240.55
Minimum payment: \$75
'''),
      );

      expect(result.statementLineItems, hasLength(3));
      expect(
        result.statementLineItems.where((item) => item.isPaymentLike),
        hasLength(1),
      );
    });

    test('flags ambiguous statement dates without guessing silently', () {
      final result = validator.validate(
        parser.parse(DocumentClassification.creditCardStatement, '''
03/05 ONLINE PAYMENT THANK YOU 200.00
03/12 GROCERY STORE 44.50
'''),
      );

      expect(
        result.statementLineItems.any(
          (item) => item.warnings.contains('ambiguous_date'),
        ),
        true,
      );
    });

    test('does not treat generic "from" lines as statement periods', () {
      final result = validator.validate(
        parser.parse(DocumentClassification.creditCardStatement, '''
ACME CREDIT CARD STATEMENT
Payment from checking account 250.00
Current balance: \$1,240.55
Minimum payment: \$75
'''),
      );

      expect(result.summary.statementStartDate, isNull);
      expect(result.summary.statementEndDate, isNull);
      expect(result.summary.labels, isNot(contains('statement period')));
    });

    test(
      'processing keeps import artifacts in memory until final confirm',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'import_review_processing',
        );
        addTearDown(() => tempDir.delete(recursive: true));
        final source = File(
          '${tempDir.path}${Platform.pathSeparator}statement.txt',
        )..writeAsStringSync('ACME BANK CREDIT CARD STATEMENT');
        final vaultService = _SealTrackingVaultService();
        final extractionService = _RecordingAiExtractionService(
          const ImportExtractionResult(
            summary: StatementSummaryCandidate(
              title: 'Acme Statement',
              creditorName: 'Acme Bank',
              debtType: DebtType.creditCard,
              currentBalance: 1200,
              minimumPayment: 35,
              currency: 'USD',
              confidence: 0.9,
            ),
            statementLineItems: <StatementLineItemCandidate>[],
            warnings: <String>[],
            documentSignals: <String>['credit_card_statement'],
            errorMessage: null,
            quotaSnapshot: null,
          ),
        );
        final coordinator = ImportCoordinator(
          documentVaultService: vaultService,
          preprocessService: PassthroughImagePreprocessService(),
          classifier: DocumentClassifier(),
          aiExtractionService: extractionService,
          validationService: ParseValidationService(),
          preferencesRepository: _StaticPreferencesRepository(
            UserPreferences.defaults(),
          ),
          retentionService: const DataRetentionService(),
        );

        final bundle = await coordinator.process(
          input: FileReference(
            path: source.path,
            sourceType: DocumentSourceType.gallery,
            mimeType: 'text/plain',
          ),
          allowCloud: false,
        );

        expect(vaultService.sealImportCalls, 0);
        expect(extractionService.lastFile?.path, source.path);
        expect(extractionService.lastNormalizedText, isEmpty);
        expect(bundle.normalizedText, isEmpty);
        expect(bundle.document.storageRef, isNull);
        expect(bundle.document.encryptedAt, isNull);
        expect(bundle.sourcePath, source.path);
      },
    );

    test(
      'stages import files into app-controlled storage with normalized jpeg mime',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'import_stage_service',
        );
        addTearDown(() => tempDir.delete(recursive: true));
        final source = File(
          '${tempDir.path}${Platform.pathSeparator}statement.jpg',
        )..writeAsStringSync('jpeg bytes');
        final supportDir = Directory(
          '${tempDir.path}${Platform.pathSeparator}app_support',
        );
        final service = LocalImportFileStagingService(
          baseDirectoryLoader: () async => supportDir,
        );

        final staged = await service.stage(
          sourcePath: source.path,
          sourceType: DocumentSourceType.gallery,
          mimeType: service.normalizedImageMimeType(source.path),
        );

        expect(staged.mimeType, 'image/jpeg');
        expect(staged.path, isNot(source.path));
        expect(await File(staged.path).exists(), isTrue);
        expect(await File(staged.path).readAsString(), 'jpeg bytes');
      },
    );
  });
}

class _RecordingAiExtractionService implements AiExtractionService {
  _RecordingAiExtractionService(this.result);

  final ImportExtractionResult result;
  FileReference? lastFile;
  String? lastNormalizedText;

  @override
  Future<ImportExtractionResult> extract({
    required DocumentClassification classification,
    required String normalizedText,
    required FileReference file,
    required DocumentSourceType sourceType,
    required bool allowCloud,
  }) async {
    lastFile = file;
    lastNormalizedText = normalizedText;
    return result;
  }
}

class _StaticPreferencesRepository implements PreferencesRepository {
  const _StaticPreferencesRepository(this.preferences);

  final UserPreferences preferences;

  @override
  Future<UserPreferences> loadPreferences() async => preferences;

  @override
  Future<void> savePreferences(UserPreferences preferences) async {}

  @override
  Stream<UserPreferences> watchPreferences() => Stream.value(preferences);
}

class _FakeKeyService extends LocalVaultKeyService {
  _FakeKeyService();

  final Uint8List _key = Uint8List.fromList(
    List<int>.generate(32, (index) => index + 1),
  );

  @override
  Future<Uint8List> ensureRootKey() async => _key;

  @override
  Future<String> databasePassphrase() async => base64Encode(_key);

  @override
  Future<SecretKey> documentSecretKey() async => SecretKey(_key);
}

class _SealTrackingVaultService extends SecureDocumentVaultService {
  _SealTrackingVaultService() : super(_FakeKeyService());

  int sealImportCalls = 0;

  @override
  Future<StoredVaultDocument> sealImport(FileReference input) {
    sealImportCalls += 1;
    throw StateError('sealImport should not run during processing');
  }
}
