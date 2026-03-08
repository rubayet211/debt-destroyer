import 'dart:async';

import 'package:drift/drift.dart' as drift;

import '../../shared/data/local/app_database.dart';
import '../../shared/enums/app_enums.dart';
import '../../shared/models/data_protection_models.dart';
import '../../shared/models/user_preferences.dart';
import '../../features/scan_import/domain/import_services.dart';
import '../logging/app_logger.dart';
import 'vault_services.dart';

class DataProtectionBootstrapService {
  DataProtectionBootstrapService({
    required this.database,
    required this.keyService,
    required this.documentVaultService,
    required this.retentionService,
  });

  final AppDatabase database;
  final LocalVaultKeyService keyService;
  final SecureDocumentVaultService documentVaultService;
  final DataRetentionService retentionService;

  Future<DataProtectionState> initialize() async {
    try {
      await database.customSelect('SELECT 1').get();
      await _migrateLegacyDocuments();
      await _purgeExpiredContent();
      final shouldShowExplainer = await _shouldShowUpgradeExplainer();
      await keyService.setMigrationFailure(null);
      return DataProtectionState.ready(
        showUpgradeExplainer: shouldShowExplainer,
        statusMessage: 'Local encryption active for database and imports',
      );
    } catch (error, stackTrace) {
      await keyService.setMigrationFailure(
        'Local encryption could not be initialized.',
      );
      AppLogger.instance.error(
        'Data protection bootstrap failed',
        error,
        stackTrace,
      );
      return const DataProtectionState.failed(
        'Secure local storage could not be opened. Retry the migration or restore from a safe backup.',
      );
    }
  }

  Future<void> acknowledgeUpgradeExplainer() async {
    final current = await _loadPreferences();
    await _savePreferences(current.copyWith(dataProtectionExplainerSeen: true));
    await keyService.setUpgradeExplainerPending(false);
  }

  Future<void> purgeAllImportedDocuments() async {
    final rows = await database.select(database.importedDocumentsTable).get();
    for (final row in rows) {
      await documentVaultService.purgeStoredDocument(row.storageRef);
      await documentVaultService.purgeLegacyPlaintext(
        row.localPath.isEmpty ? null : row.localPath,
      );
      await (database.delete(
        database.parsedExtractionsTable,
      )..where((tbl) => tbl.documentId.equals(row.id))).go();
      await (database.delete(
        database.importedDocumentsTable,
      )..where((tbl) => tbl.id.equals(row.id))).go();
    }
  }

  Future<void> purgeAllStoredOcr() async {
    await database
        .update(database.importedDocumentsTable)
        .write(
          const ImportedDocumentsTableCompanion(
            rawOcrText: drift.Value(null),
            hasRawOcrText: drift.Value(false),
          ),
        );
  }

  Future<void> _migrateLegacyDocuments() async {
    final preferences = await _loadPreferences();
    final rows = await (database.select(
      database.importedDocumentsTable,
    )..where((tbl) => tbl.storageRef.isNull())).get();
    if (rows.isEmpty) {
      return;
    }

    await keyService.setMigrationStage('migrating_imported_documents');
    for (final row in rows) {
      final legacyPath = row.localPath;
      String? storageRef;
      DateTime? encryptedAt;
      if (legacyPath.isNotEmpty) {
        final encrypted = await documentVaultService.sealImport(
          FileReference(
            path: legacyPath,
            sourceType: DocumentSourceType.values.byName(row.sourceType),
            mimeType: row.mimeType,
          ),
        );
        storageRef = encrypted.storageRef;
        encryptedAt = encrypted.encryptedAt;
        await documentVaultService.purgeLegacyPlaintext(legacyPath);
      }

      final retainRaw = retentionService.shouldRetainRawOcr(preferences);
      await (database.update(
        database.importedDocumentsTable,
      )..where((tbl) => tbl.id.equals(row.id))).write(
        ImportedDocumentsTableCompanion(
          localPath: const drift.Value(''),
          storageRef: drift.Value(storageRef),
          encryptedAt: drift.Value(encryptedAt),
          retentionExpiresAt: drift.Value(
            retentionService.documentExpiry(
              preferences: preferences,
              parseStatus: ParseStatus.values.byName(row.parseStatus),
              now: DateTime.now(),
            ),
          ),
          rawOcrText: drift.Value(retainRaw ? row.rawOcrText : null),
          hasRawOcrText: drift.Value(
            retainRaw &&
                row.rawOcrText != null &&
                row.rawOcrText!.trim().isNotEmpty,
          ),
        ),
      );
    }
    await keyService.setUpgradeExplainerPending(true);
    await keyService.clearMigrationStage();
  }

  Future<void> _purgeExpiredContent() async {
    final now = DateTime.now();
    final expiredDocuments = await (database.select(
      database.importedDocumentsTable,
    )..where((tbl) => tbl.retentionExpiresAt.isSmallerThanValue(now))).get();
    for (final row in expiredDocuments) {
      await documentVaultService.purgeStoredDocument(row.storageRef);
      await (database.delete(
        database.parsedExtractionsTable,
      )..where((tbl) => tbl.documentId.equals(row.id))).go();
      await (database.delete(
        database.importedDocumentsTable,
      )..where((tbl) => tbl.id.equals(row.id))).go();
    }

    await (database.update(database.importedDocumentsTable)
          ..where((tbl) => tbl.hasRawOcrText.equals(true))
          ..where((tbl) => tbl.retentionExpiresAt.isSmallerThanValue(now)))
        .write(
          const ImportedDocumentsTableCompanion(
            rawOcrText: drift.Value(null),
            hasRawOcrText: drift.Value(false),
          ),
        );
  }

  Future<bool> _shouldShowUpgradeExplainer() async {
    final preferences = await _loadPreferences();
    return !preferences.dataProtectionExplainerSeen &&
        await keyService.isUpgradeExplainerPending();
  }

  Future<UserPreferences> _loadPreferences() async {
    final row = await database
        .select(database.appPreferencesTable)
        .getSingleOrNull();
    if (row == null) {
      return UserPreferences.defaults();
    }
    return UserPreferences(
      themeMode: ThemePreference.values.byName(row.themeMode),
      currencyCode: row.currencyCode,
      localeCode: row.localeCode,
      defaultStrategy: StrategyType.values.byName(row.defaultStrategy),
      hideBalances: row.hideBalances,
      appLockEnabled: row.appLockEnabled,
      aiConsentEnabled: row.aiConsentEnabled,
      notificationsEnabled: row.notificationsEnabled,
      onboardingCompleted: row.onboardingCompleted,
      weeklySummaryEnabled: row.weeklySummaryEnabled,
      rawOcrRetentionEnabled: row.rawOcrRetentionEnabled,
      rawOcrRetentionHours: row.rawOcrRetentionHours,
      documentRetentionMode: DocumentRetentionMode.values.byName(
        row.documentRetentionMode,
      ),
      purgeFailedImportsAfterHours: row.purgeFailedImportsAfterHours,
      dataProtectionExplainerSeen: row.dataProtectionExplainerSeen,
    );
  }

  Future<void> _savePreferences(UserPreferences preferences) {
    return database
        .into(database.appPreferencesTable)
        .insertOnConflictUpdate(
          AppPreferencesTableCompanion.insert(
            themeMode: drift.Value(preferences.themeMode.name),
            currencyCode: drift.Value(preferences.currencyCode),
            localeCode: drift.Value(preferences.localeCode),
            defaultStrategy: drift.Value(preferences.defaultStrategy.name),
            hideBalances: drift.Value(preferences.hideBalances),
            appLockEnabled: drift.Value(preferences.appLockEnabled),
            aiConsentEnabled: drift.Value(preferences.aiConsentEnabled),
            notificationsEnabled: drift.Value(preferences.notificationsEnabled),
            onboardingCompleted: drift.Value(preferences.onboardingCompleted),
            weeklySummaryEnabled: drift.Value(preferences.weeklySummaryEnabled),
            rawOcrRetentionEnabled: drift.Value(
              preferences.rawOcrRetentionEnabled,
            ),
            rawOcrRetentionHours: drift.Value(preferences.rawOcrRetentionHours),
            documentRetentionMode: drift.Value(
              preferences.documentRetentionMode.name,
            ),
            purgeFailedImportsAfterHours: drift.Value(
              preferences.purgeFailedImportsAfterHours,
            ),
            dataProtectionExplainerSeen: drift.Value(
              preferences.dataProtectionExplainerSeen,
            ),
          ),
        );
  }
}
