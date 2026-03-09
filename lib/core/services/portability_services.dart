import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../shared/data/local/app_database.dart';
import '../../shared/data/repositories.dart';
import '../../shared/enums/app_enums.dart';
import '../../shared/models/backup_models.dart';
import '../../shared/models/debt.dart';
import '../../shared/models/import_models.dart';
import '../../shared/models/payment.dart';
import '../../shared/models/reminder_models.dart';
import '../../shared/models/strategy_models.dart';
import '../constants/app_constants.dart';
import 'vault_services.dart';

class DataPortabilityService {
  DataPortabilityService({
    required this.database,
    required this.preferencesRepository,
    required this.documentsRepository,
    required this.vaultService,
    required this.protectedPreferencesStore,
    Future<Directory> Function()? temporaryDirectoryLoader,
  }) : _temporaryDirectoryLoader =
           temporaryDirectoryLoader ?? getTemporaryDirectory;

  static const backupFormatVersion = 1;
  static const _containerFormat = 'debt_destroyer_backup';
  static const _fileExtension = '.ddbackup';
  static const _kdfIterations = 150000;

  final AppDatabase database;
  final PreferencesRepository preferencesRepository;
  final DocumentsRepository documentsRepository;
  final SecureDocumentVaultService vaultService;
  final ProtectedPreferencesStore protectedPreferencesStore;
  final Future<Directory> Function() _temporaryDirectoryLoader;
  final Cipher _cipher = AesGcm.with256bits();

  Future<File> createFullBackup(String passphrase) async {
    _validatePassphrase(passphrase);
    final payload = await _buildPayload();
    final documentBytes = <String, Uint8List>{};
    for (final document in payload.documents) {
      final bytes = await documentsRepository.readDocumentBytes(document.id);
      if (document.storageRef != null && document.storageRef!.isNotEmpty) {
        if (bytes == null) {
          throw StateError(
            'Document bytes are missing for ${document.id}. Delete the broken document and try again.',
          );
        }
        documentBytes[document.id] = bytes;
      }
    }
    final archiveBytes = _encodeZip(payload, documentBytes);
    final encrypted = await _encryptArchive(
      zipBytes: archiveBytes,
      passphrase: passphrase,
    );
    final directory = await _temporaryDirectoryLoader();
    final filename =
        'debt_destroyer_backup_${DateTime.now().toUtc().toIso8601String().replaceAll(':', '-')}$_fileExtension';
    final file = File(p.join(directory.path, filename));
    await file.writeAsBytes(encrypted, flush: true);
    return file;
  }

  Future<BackupValidationResult> inspectBackup(
    File file,
    String passphrase,
  ) async {
    try {
      _validatePassphrase(passphrase);
      if (!await file.exists()) {
        return const BackupValidationResult(
          isValid: false,
          errors: ['Backup file could not be found.'],
        );
      }
      final decoded = await _decodeBackup(file, passphrase);
      return BackupValidationResult(
        isValid: true,
        errors: const [],
        preview: decoded.payload.toPreview(),
      );
    } on FormatException catch (error) {
      return BackupValidationResult(isValid: false, errors: [error.message]);
    } on SecretBoxAuthenticationError {
      return const BackupValidationResult(
        isValid: false,
        errors: [
          'Backup decryption failed. Check the passphrase and try again.',
        ],
      );
    } on StateError catch (error) {
      return BackupValidationResult(isValid: false, errors: [error.message]);
    } catch (error) {
      return BackupValidationResult(
        isValid: false,
        errors: ['Backup validation failed: $error'],
      );
    }
  }

  Future<BackupPreview> restoreBackup(File file, String passphrase) async {
    _validatePassphrase(passphrase);
    final decoded = await _decodeBackup(file, passphrase);
    final oldDocuments = await database
        .select(database.importedDocumentsTable)
        .get();
    final stagedStorageRefs = <String>[];
    try {
      final restoredDocuments = <ImportedDocument>[];
      for (final document in decoded.payload.documents) {
        final bytes = decoded.documentBytes[document.id];
        if (bytes != null) {
          final stored = await vaultService.sealBytes(bytes);
          stagedStorageRefs.add(stored.storageRef);
          restoredDocuments.add(
            document.copyWith(
              storageRef: stored.storageRef,
              encryptedAt: stored.encryptedAt,
            ),
          );
        } else {
          restoredDocuments.add(
            document.copyWith(storageRef: null, encryptedAt: null),
          );
        }
      }

      await database.transaction(() async {
        await database.delete(database.parsedExtractionsTable).go();
        await database.delete(database.importedDocumentsTable).go();
        await database.delete(database.paymentsTable).go();
        await database.delete(database.debtsTable).go();
        await database.delete(database.scenariosTable).go();
        await database.delete(database.reminderEventsTable).go();
        await database.delete(database.reminderRulesTable).go();
        await database.delete(database.appPreferencesTable).go();

        for (final debt in decoded.payload.debts) {
          await database
              .into(database.debtsTable)
              .insert(
                DebtsTableCompanion.insert(
                  id: debt.id,
                  title: debt.title,
                  creditorName: debt.creditorName,
                  type: debt.type.name,
                  currency: debt.currency,
                  originalBalance: debt.originalBalance,
                  currentBalance: debt.currentBalance,
                  apr: debt.apr,
                  minimumPayment: debt.minimumPayment,
                  dueDate: Value(debt.dueDate),
                  paymentFrequency: debt.paymentFrequency.name,
                  createdAt: debt.createdAt,
                  updatedAt: debt.updatedAt,
                  notes: Value(debt.notes),
                  tagsJson: Value(database.encodeStringList(debt.tags)),
                  financialTermsJson: Value(
                    jsonEncode(debt.financialTerms.toJson()),
                  ),
                  status: debt.status.name,
                  remindersEnabled: Value(debt.remindersEnabled),
                  customPriority: Value(debt.customPriority),
                ),
              );
        }

        for (final payment in decoded.payload.payments) {
          await database
              .into(database.paymentsTable)
              .insert(
                PaymentsTableCompanion.insert(
                  id: payment.id,
                  debtId: payment.debtId,
                  amount: payment.amount,
                  date: payment.date,
                  method: Value(payment.method),
                  sourceType: payment.sourceType.name,
                  notes: Value(payment.notes),
                  tagsJson: Value(database.encodeStringList(payment.tags)),
                  createdAt: payment.createdAt,
                ),
              );
        }

        for (final document in restoredDocuments) {
          await database
              .into(database.importedDocumentsTable)
              .insert(
                ImportedDocumentsTableCompanion.insert(
                  id: document.id,
                  localPath: const Value(''),
                  storageRef: Value(document.storageRef),
                  sourceType: document.sourceType.name,
                  mimeType: document.mimeType,
                  createdAt: document.createdAt,
                  lifecycleState: Value(document.lifecycleState.name),
                  linkedDebtId: Value(document.linkedDebtId),
                  rawOcrText: Value(document.rawOcrText),
                  parseStatus: document.parseStatus.name,
                  parseVersion: document.parseVersion,
                  deleted: Value(document.deleted),
                  retentionExpiresAt: Value(document.retentionExpiresAt),
                  rawOcrExpiresAt: Value(document.rawOcrExpiresAt),
                  processedAt: Value(document.processedAt),
                  linkedAt: Value(document.linkedAt),
                  pendingDeletionAt: Value(document.pendingDeletionAt),
                  purgedAt: Value(document.purgedAt),
                  encryptedAt: Value(document.encryptedAt),
                  hasRawOcrText: Value(document.hasRawOcrText),
                ),
              );
        }

        for (final extraction in decoded.payload.parsedExtractions) {
          await database
              .into(database.parsedExtractionsTable)
              .insert(
                ParsedExtractionsTableCompanion.insert(
                  id: extraction.id,
                  documentId: extraction.documentId,
                  classification: extraction.classification.name,
                  confidence: extraction.confidence,
                  payloadJson: extraction.payloadJson,
                  ambiguityNotes: Value(extraction.ambiguityNotes),
                  createdAt: extraction.createdAt,
                ),
              );
        }

        for (final scenario in decoded.payload.scenarios) {
          await database
              .into(database.scenariosTable)
              .insert(
                ScenariosTableCompanion.insert(
                  id: scenario.id,
                  strategyType: scenario.strategyType.name,
                  extraPayment: scenario.extraPayment,
                  budget: scenario.budget,
                  createdAt: scenario.createdAt,
                  label: scenario.label,
                  baselineInterest: scenario.baselineInterest,
                  optimizedInterest: scenario.optimizedInterest,
                  monthsToPayoff: scenario.monthsToPayoff,
                ),
              );
        }

        for (final event in decoded.payload.reminderEvents) {
          await database
              .into(database.reminderEventsTable)
              .insert(
                ReminderEventsTableCompanion.insert(
                  id: event.id,
                  debtId: Value(event.debtId),
                  kind: event.kind.name,
                  createdAt: event.createdAt,
                ),
              );
        }

        final preferences = decoded.payload.preferences;
        await database
            .into(database.appPreferencesTable)
            .insert(
              AppPreferencesTableCompanion.insert(
                themeMode: Value(preferences.themeMode.name),
                currencyCode: Value(preferences.currencyCode),
                localeCode: Value(preferences.localeCode),
                defaultStrategy: Value(preferences.defaultStrategy.name),
                hideBalances: const Value(false),
                appLockEnabled: const Value(false),
                aiConsentEnabled: const Value(false),
                notificationsEnabled: Value(preferences.notificationsEnabled),
                dueRemindersEnabled: Value(preferences.dueRemindersEnabled),
                overdueRemindersEnabled: Value(
                  preferences.overdueRemindersEnabled,
                ),
                milestoneNotificationsEnabled: Value(
                  preferences.milestoneNotificationsEnabled,
                ),
                onboardingCompleted: Value(preferences.onboardingCompleted),
                weeklySummaryEnabled: Value(preferences.weeklySummaryEnabled),
                dueReminderLeadDays: Value(
                  preferences.dueReminderLeadDays.clamp(1, 3),
                ),
                rawOcrRetentionEnabled: Value(
                  preferences.rawOcrRetentionEnabled,
                ),
                rawOcrRetentionHours: Value(preferences.rawOcrRetentionHours),
                documentRetentionMode: Value(
                  preferences.documentRetentionMode.name,
                ),
                purgeFailedImportsAfterHours: Value(
                  preferences.purgeFailedImportsAfterHours,
                ),
                dataProtectionExplainerSeen: Value(
                  preferences.dataProtectionExplainerSeen,
                ),
              ),
            );
      });

      await protectedPreferencesStore.write(
        ProtectedPreferenceValues(
          hideBalances: decoded.payload.preferences.hideBalances,
          appLockEnabled: decoded.payload.preferences.appLockEnabled,
          aiConsentEnabled: decoded.payload.preferences.aiConsentEnabled,
          relockTimeout: decoded.payload.preferences.relockTimeout,
          screenshotProtectionEnabled:
              decoded.payload.preferences.screenshotProtectionEnabled,
          privacyShieldOnAppSwitcherEnabled:
              decoded.payload.preferences.privacyShieldOnAppSwitcherEnabled,
        ),
      );

      for (final row in oldDocuments) {
        await vaultService.purgeStoredDocument(row.storageRef);
        await vaultService.purgeLegacyPlaintext(
          row.localPath.isEmpty ? null : row.localPath,
        );
      }

      return decoded.payload.toPreview();
    } catch (_) {
      for (final storageRef in stagedStorageRefs) {
        await vaultService.purgeStoredDocument(storageRef);
      }
      rethrow;
    }
  }

  Future<BackupPayloadV1> _buildPayload() async {
    final debts = await database
        .select(database.debtsTable)
        .get()
        .then((rows) => rows.map(_mapDebt).toList());
    final payments = await database
        .select(database.paymentsTable)
        .get()
        .then((rows) => rows.map(_mapPayment).toList());
    final documents =
        await (database.select(database.importedDocumentsTable)..where(
              (tbl) => tbl.lifecycleState.isIn([
                DocumentLifecycleState.imported.name,
                DocumentLifecycleState.processed.name,
                DocumentLifecycleState.linked.name,
              ]),
            ))
            .get()
            .then((rows) => rows.map(_mapDocument).toList());
    final documentIds = documents.map((item) => item.id).toSet();
    final parsedExtractions =
        await (database.select(database.parsedExtractionsTable)
              ..where((tbl) => tbl.documentId.isIn(documentIds)))
            .get()
            .then((rows) => rows.map(_mapParsedExtraction).toList());
    final scenarios = await database
        .select(database.scenariosTable)
        .get()
        .then((rows) => rows.map(_mapScenario).toList());
    final reminderEvents = await database
        .select(database.reminderEventsTable)
        .get()
        .then((rows) => rows.map(_mapReminderEvent).toList());
    final preferences = await preferencesRepository.loadPreferences();
    final manifest = BackupManifest(
      backupFormatVersion: backupFormatVersion,
      createdAt: DateTime.now().toUtc(),
      createdByAppVersion: AppConstants.appVersion,
      createdBySchemaVersion: database.schemaVersion,
      containsDocuments: documents.any(
        (item) => item.storageRef != null && item.storageRef!.isNotEmpty,
      ),
      debtCount: debts.length,
      paymentCount: payments.length,
      documentCount: documents.length,
      parsedExtractionCount: parsedExtractions.length,
      scenarioCount: scenarios.length,
      reminderEventCount: reminderEvents.length,
    );
    return BackupPayloadV1(
      manifest: manifest,
      debts: debts,
      payments: payments,
      documents: documents,
      parsedExtractions: parsedExtractions,
      scenarios: scenarios,
      reminderEvents: reminderEvents,
      preferences: preferences,
    );
  }

  Uint8List _encodeZip(
    BackupPayloadV1 payload,
    Map<String, Uint8List> documentBytes,
  ) {
    final archive = Archive();
    archive.addFile(
      ArchiveFile.string(
        'manifest.json',
        jsonEncode(payload.manifest.toJson()),
      ),
    );
    archive.addFile(
      ArchiveFile.string(
        'debts.json',
        jsonEncode(payload.debts.map(debtToJson).toList()),
      ),
    );
    archive.addFile(
      ArchiveFile.string(
        'payments.json',
        jsonEncode(payload.payments.map(paymentToJson).toList()),
      ),
    );
    archive.addFile(
      ArchiveFile.string(
        'documents.json',
        jsonEncode(payload.documents.map(documentToJson).toList()),
      ),
    );
    archive.addFile(
      ArchiveFile.string(
        'parsed_extractions.json',
        jsonEncode(
          payload.parsedExtractions.map(parsedExtractionToJson).toList(),
        ),
      ),
    );
    archive.addFile(
      ArchiveFile.string(
        'scenarios.json',
        jsonEncode(payload.scenarios.map(scenarioToJson).toList()),
      ),
    );
    archive.addFile(
      ArchiveFile.string(
        'reminder_events.json',
        jsonEncode(payload.reminderEvents.map(reminderEventToJson).toList()),
      ),
    );
    archive.addFile(
      ArchiveFile.string(
        'preferences.json',
        jsonEncode(preferencesToJson(payload.preferences)),
      ),
    );
    for (final entry in documentBytes.entries) {
      archive.addFile(
        ArchiveFile(
          'documents/${entry.key}.bin',
          entry.value.length,
          entry.value,
        ),
      );
    }
    final bytes = ZipEncoder().encode(archive);
    return Uint8List.fromList(bytes);
  }

  Future<Uint8List> _encryptArchive({
    required Uint8List zipBytes,
    required String passphrase,
  }) async {
    final salt = _randomBytes(16);
    final key = await _deriveKey(passphrase, salt);
    final secretBox = await _cipher.encrypt(
      zipBytes,
      secretKey: key,
      nonce: _randomBytes(12),
    );
    final wrapper = jsonEncode({
      'format': _containerFormat,
      'version': backupFormatVersion,
      'kdf': 'pbkdf2-sha256',
      'iterations': _kdfIterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'ciphertext': base64Encode(secretBox.cipherText),
    });
    return Uint8List.fromList(utf8.encode(wrapper));
  }

  Future<_DecodedBackupPackage> _decodeBackup(
    File file,
    String passphrase,
  ) async {
    final wrapperBytes = await file.readAsBytes();
    final wrapper = jsonDecode(utf8.decode(wrapperBytes));
    if (wrapper is! Map<String, dynamic>) {
      throw const FormatException('Backup container is malformed.');
    }
    if (wrapper['format'] != _containerFormat) {
      throw const FormatException('Backup file format is not supported.');
    }
    final version = wrapper['version'];
    if (version is! int) {
      throw const FormatException('Backup version is missing.');
    }
    if (version > backupFormatVersion) {
      throw FormatException(
        'Backup format v$version is newer than this app supports.',
      );
    }
    final iterations =
        (wrapper['iterations'] as num?)?.toInt() ?? _kdfIterations;
    final salt = base64Decode(wrapper['salt']?.toString() ?? '');
    final nonce = base64Decode(wrapper['nonce']?.toString() ?? '');
    final mac = base64Decode(wrapper['mac']?.toString() ?? '');
    final cipherText = base64Decode(wrapper['ciphertext']?.toString() ?? '');
    final key = await _deriveKey(passphrase, salt, iterations: iterations);
    final zipBytes = await _cipher.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
      secretKey: key,
    );
    final archive = ZipDecoder().decodeBytes(zipBytes, verify: true);
    return _parseArchive(archive);
  }

  _DecodedBackupPackage _parseArchive(Archive archive) {
    final manifest = BackupManifest.fromJson(
      _decodeMapFile(archive, 'manifest.json'),
    );
    if (manifest.backupFormatVersion > backupFormatVersion) {
      throw FormatException(
        'Backup payload v${manifest.backupFormatVersion} is newer than this app supports.',
      );
    }
    final debts = _decodeListFile(
      archive,
      'debts.json',
    ).map(debtFromJson).toList();
    final payments = _decodeListFile(
      archive,
      'payments.json',
    ).map(paymentFromJson).toList();
    final documents = _decodeListFile(
      archive,
      'documents.json',
    ).map(documentFromJson).toList();
    final parsedExtractions = _decodeListFile(
      archive,
      'parsed_extractions.json',
    ).map(parsedExtractionFromJson).toList();
    final scenarios = _decodeListFile(
      archive,
      'scenarios.json',
    ).map(scenarioFromJson).toList();
    final reminderEvents = _decodeListFile(
      archive,
      'reminder_events.json',
    ).map(reminderEventFromJson).toList();
    final preferences = preferencesFromJson(
      _decodeMapFile(archive, 'preferences.json'),
    );

    final payload = BackupPayloadV1(
      manifest: manifest,
      debts: debts,
      payments: payments,
      documents: documents,
      parsedExtractions: parsedExtractions,
      scenarios: scenarios,
      reminderEvents: reminderEvents,
      preferences: preferences,
    );
    _validatePayload(payload);

    final documentBytes = <String, Uint8List>{};
    for (final document in documents) {
      final entryName = 'documents/${document.id}.bin';
      final file = archive.findFile(entryName);
      if (document.storageRef != null && document.storageRef!.isNotEmpty) {
        if (file == null) {
          throw FormatException(
            'Backup is missing source document bytes for ${document.id}.',
          );
        }
        documentBytes[document.id] = Uint8List.fromList(
          _archiveFileBytes(file),
        );
      } else if (file != null) {
        documentBytes[document.id] = Uint8List.fromList(
          _archiveFileBytes(file),
        );
      }
    }

    return _DecodedBackupPackage(
      payload: payload,
      documentBytes: documentBytes,
    );
  }

  void _validatePayload(BackupPayloadV1 payload) {
    final manifest = payload.manifest;
    if (manifest.debtCount != payload.debts.length ||
        manifest.paymentCount != payload.payments.length ||
        manifest.documentCount != payload.documents.length ||
        manifest.parsedExtractionCount != payload.parsedExtractions.length ||
        manifest.scenarioCount != payload.scenarios.length ||
        manifest.reminderEventCount != payload.reminderEvents.length) {
      throw const FormatException(
        'Backup manifest counts do not match payload.',
      );
    }

    _ensureUnique(payload.debts.map((item) => item.id), 'debt');
    _ensureUnique(payload.payments.map((item) => item.id), 'payment');
    _ensureUnique(payload.documents.map((item) => item.id), 'document');
    _ensureUnique(
      payload.parsedExtractions.map((item) => item.id),
      'parsed extraction',
    );
    _ensureUnique(payload.scenarios.map((item) => item.id), 'scenario');
    _ensureUnique(
      payload.reminderEvents.map((item) => item.id),
      'reminder event',
    );

    final debtIds = payload.debts.map((item) => item.id).toSet();
    final documentIds = payload.documents.map((item) => item.id).toSet();

    for (final payment in payload.payments) {
      if (!debtIds.contains(payment.debtId)) {
        throw FormatException(
          'Payment ${payment.id} references missing debt ${payment.debtId}.',
        );
      }
    }
    for (final document in payload.documents) {
      if (document.linkedDebtId != null &&
          !debtIds.contains(document.linkedDebtId)) {
        throw FormatException(
          'Document ${document.id} references missing debt ${document.linkedDebtId}.',
        );
      }
    }
    for (final extraction in payload.parsedExtractions) {
      if (!documentIds.contains(extraction.documentId)) {
        throw FormatException(
          'Parsed extraction ${extraction.id} references missing document ${extraction.documentId}.',
        );
      }
    }
  }

  void _ensureUnique(Iterable<String> ids, String label) {
    final seen = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) {
        throw FormatException('Backup contains duplicate $label id: $id');
      }
    }
  }

  Map<String, Object?> _decodeMapFile(Archive archive, String name) {
    final file = archive.findFile(name);
    if (file == null) {
      throw FormatException('Backup is missing $name.');
    }
    final decoded = jsonDecode(utf8.decode(_archiveFileBytes(file)));
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('$name is malformed.');
    }
    return decoded.map((key, value) => MapEntry(key, value as Object?));
  }

  List<Map<String, Object?>> _decodeListFile(Archive archive, String name) {
    final file = archive.findFile(name);
    if (file == null) {
      throw FormatException('Backup is missing $name.');
    }
    final decoded = jsonDecode(utf8.decode(_archiveFileBytes(file)));
    if (decoded is! List) {
      throw FormatException('$name is malformed.');
    }
    return decoded.map((item) {
      if (item is! Map) {
        throw FormatException('$name contains malformed entries.');
      }
      return item.map(
        (key, value) => MapEntry(key.toString(), value as Object?),
      );
    }).toList();
  }

  List<int> _archiveFileBytes(ArchiveFile file) {
    return file.content as List<int>;
  }

  Future<SecretKey> _deriveKey(
    String passphrase,
    List<int> salt, {
    int iterations = _kdfIterations,
  }) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    return pbkdf2.deriveKeyFromPassword(password: passphrase, nonce: salt);
  }

  void _validatePassphrase(String passphrase) {
    if (passphrase.trim().isEmpty) {
      throw const FormatException('A backup passphrase is required.');
    }
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  Debt _mapDebt(DebtsTableData row) {
    return debtFromJson({
      'id': row.id,
      'title': row.title,
      'creditorName': row.creditorName,
      'type': row.type,
      'currency': row.currency,
      'originalBalance': row.originalBalance,
      'currentBalance': row.currentBalance,
      'apr': row.apr,
      'minimumPayment': row.minimumPayment,
      'dueDate': row.dueDate?.toIso8601String(),
      'paymentFrequency': row.paymentFrequency,
      'createdAt': row.createdAt.toIso8601String(),
      'updatedAt': row.updatedAt.toIso8601String(),
      'notes': row.notes,
      'tags': database.decodeStringList(row.tagsJson),
      'status': row.status,
      'remindersEnabled': row.remindersEnabled,
      'customPriority': row.customPriority,
      'financialTerms':
          jsonDecode(row.financialTermsJson) as Map<String, dynamic>,
    });
  }

  Payment _mapPayment(PaymentsTableData row) {
    return paymentFromJson({
      'id': row.id,
      'debtId': row.debtId,
      'amount': row.amount,
      'date': row.date.toIso8601String(),
      'method': row.method,
      'sourceType': row.sourceType,
      'notes': row.notes,
      'tags': database.decodeStringList(row.tagsJson),
      'createdAt': row.createdAt.toIso8601String(),
    });
  }

  ImportedDocument _mapDocument(ImportedDocumentsTableData row) {
    return documentFromJson({
      'id': row.id,
      'storageRef': row.storageRef,
      'sourceType': row.sourceType,
      'mimeType': row.mimeType,
      'createdAt': row.createdAt.toIso8601String(),
      'lifecycleState': row.lifecycleState,
      'linkedDebtId': row.linkedDebtId,
      'rawOcrText': row.rawOcrText,
      'parseStatus': row.parseStatus,
      'parseVersion': row.parseVersion,
      'deleted': row.deleted,
      'retentionExpiresAt': row.retentionExpiresAt?.toIso8601String(),
      'rawOcrExpiresAt': row.rawOcrExpiresAt?.toIso8601String(),
      'processedAt': row.processedAt?.toIso8601String(),
      'linkedAt': row.linkedAt?.toIso8601String(),
      'pendingDeletionAt': row.pendingDeletionAt?.toIso8601String(),
      'purgedAt': row.purgedAt?.toIso8601String(),
      'encryptedAt': row.encryptedAt?.toIso8601String(),
      'hasRawOcrText': row.hasRawOcrText,
    });
  }

  ParsedExtraction _mapParsedExtraction(ParsedExtractionsTableData row) {
    return parsedExtractionFromJson({
      'id': row.id,
      'documentId': row.documentId,
      'classification': row.classification,
      'confidence': row.confidence,
      'payloadJson': row.payloadJson,
      'ambiguityNotes': row.ambiguityNotes,
      'createdAt': row.createdAt.toIso8601String(),
    });
  }

  Scenario _mapScenario(ScenariosTableData row) {
    return scenarioFromJson({
      'id': row.id,
      'strategyType': row.strategyType,
      'extraPayment': row.extraPayment,
      'budget': row.budget,
      'createdAt': row.createdAt.toIso8601String(),
      'label': row.label,
      'baselineInterest': row.baselineInterest,
      'optimizedInterest': row.optimizedInterest,
      'monthsToPayoff': row.monthsToPayoff,
    });
  }

  ReminderEventRecord _mapReminderEvent(ReminderEventsTableData row) {
    return reminderEventFromJson({
      'id': row.id,
      'debtId': row.debtId,
      'kind': row.kind,
      'createdAt': row.createdAt.toIso8601String(),
    });
  }
}

class _DecodedBackupPackage {
  const _DecodedBackupPackage({
    required this.payload,
    required this.documentBytes,
  });

  final BackupPayloadV1 payload;
  final Map<String, Uint8List> documentBytes;
}
