import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/services/vault_services.dart';
import '../enums/app_enums.dart';
import '../models/debt.dart';
import '../models/import_models.dart';
import '../models/payment.dart';
import '../models/strategy_models.dart';
import '../models/subscription_state.dart';
import '../models/user_preferences.dart';
import 'local/app_database.dart';

abstract class DebtsRepository {
  Stream<List<Debt>> watchDebts({bool includeArchived = false});
  Stream<Debt?> watchDebt(String id);
  Future<List<Debt>> loadDebts({bool includeArchived = false});
  Future<void> saveDebt(Debt debt);
  Future<void> deleteDebt(String id);
  Future<void> archiveDebt(String id);
  Future<void> restoreDebt(String id);
  Future<void> markPaidOff(String id);
}

abstract class PaymentsRepository {
  Stream<List<Payment>> watchPaymentsForDebt(String debtId);
  Stream<List<Payment>> watchRecentPayments({int limit = 10});
  Future<List<Payment>> loadPaymentsForDebt(String debtId);
  Future<List<Payment>> loadAllPayments();
  Future<void> savePayment(Payment payment);
  Future<void> deletePayment(String id);
}

abstract class PreferencesRepository {
  Stream<UserPreferences> watchPreferences();
  Future<UserPreferences> loadPreferences();
  Future<void> savePreferences(UserPreferences preferences);
}

abstract class DocumentsRepository {
  Stream<List<ImportedDocument>> watchDocuments({String? debtId});
  Future<List<ImportedDocument>> loadDocuments({String? debtId});
  Future<void> saveDocument(ImportedDocument document);
  Future<void> saveParsedExtraction(ParsedExtraction extraction);
  Future<void> markDeleted(String documentId);
  Future<void> linkDocument(String documentId, String? debtId);
  Future<int> countSuccessfulScansInMonth(DateTime month);
  Future<void> purgeDocument(String documentId);
  Future<void> purgeExpiredDocuments(DateTime now);
  Future<void> trimRawOcr(String documentId);
  Future<void> purgeAllDocuments();
  Future<void> purgeAllRawOcr();
  Future<Uint8List?> readDocumentBytes(String documentId);
}

abstract class ScenariosRepository {
  Stream<List<Scenario>> watchScenarios();
  Future<void> saveScenario(Scenario scenario);
  Future<void> deleteScenario(String scenarioId);
}

abstract class SubscriptionRepository {
  Stream<SubscriptionState> watchSubscription();
  Future<SubscriptionState> loadSubscription();
  Future<void> saveSubscription(SubscriptionState state);
}

class DriftDebtsRepository implements DebtsRepository {
  DriftDebtsRepository(this.database, this.vaultService);

  final AppDatabase database;
  final SecureDocumentVaultService vaultService;

  @override
  Stream<List<Debt>> watchDebts({bool includeArchived = false}) {
    final query = database.select(database.debtsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.updatedAt, mode: OrderingMode.desc),
      ]);
    if (!includeArchived) {
      query.where((table) => table.status.isNotValue(DebtStatus.archived.name));
    }
    return query.watch().map((rows) => rows.map(_mapDebt).toList());
  }

  @override
  Stream<Debt?> watchDebt(String id) {
    final query = database.select(database.debtsTable)
      ..where((table) => table.id.equals(id));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _mapDebt(row),
    );
  }

  @override
  Future<List<Debt>> loadDebts({bool includeArchived = false}) async {
    final query = database.select(database.debtsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.updatedAt, mode: OrderingMode.desc),
      ]);
    if (!includeArchived) {
      query.where((table) => table.status.isNotValue(DebtStatus.archived.name));
    }
    return (await query.get()).map(_mapDebt).toList();
  }

  @override
  Future<void> saveDebt(Debt debt) {
    return database
        .into(database.debtsTable)
        .insertOnConflictUpdate(
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
            status: debt.status.name,
            remindersEnabled: Value(debt.remindersEnabled),
            customPriority: Value(debt.customPriority),
          ),
        );
  }

  @override
  Future<void> deleteDebt(String id) async {
    final documents = await (database.select(
      database.importedDocumentsTable,
    )..where((tbl) => tbl.linkedDebtId.equals(id))).get();
    await _purgeDocumentRows(
      database: database,
      vaultService: vaultService,
      rows: documents,
    );
    await (database.delete(
      database.paymentsTable,
    )..where((tbl) => tbl.debtId.equals(id))).go();
    await (database.delete(
      database.debtsTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> archiveDebt(String id) => _updateStatus(id, DebtStatus.archived);

  @override
  Future<void> restoreDebt(String id) => _updateStatus(id, DebtStatus.active);

  @override
  Future<void> markPaidOff(String id) => _updateStatus(id, DebtStatus.paidOff);

  Future<void> _updateStatus(String id, DebtStatus status) {
    return (database.update(
      database.debtsTable,
    )..where((tbl) => tbl.id.equals(id))).write(
      DebtsTableCompanion(
        status: Value(status.name),
        updatedAt: Value(DateTime.now()),
        currentBalance: status == DebtStatus.paidOff
            ? const Value(0)
            : const Value.absent(),
      ),
    );
  }

  Debt _mapDebt(DebtsTableData row) {
    return Debt(
      id: row.id,
      title: row.title,
      creditorName: row.creditorName,
      type: DebtType.values.byName(row.type),
      currency: row.currency,
      originalBalance: row.originalBalance,
      currentBalance: row.currentBalance,
      apr: row.apr,
      minimumPayment: row.minimumPayment,
      dueDate: row.dueDate,
      paymentFrequency: PaymentFrequency.values.byName(row.paymentFrequency),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      notes: row.notes,
      tags: database.decodeStringList(row.tagsJson),
      status: DebtStatus.values.byName(row.status),
      remindersEnabled: row.remindersEnabled,
      customPriority: row.customPriority,
    );
  }
}

class DriftPaymentsRepository implements PaymentsRepository {
  const DriftPaymentsRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<Payment>> watchPaymentsForDebt(String debtId) {
    final query = database.select(database.paymentsTable)
      ..where((table) => table.debtId.equals(debtId))
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.date, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(_mapPayment).toList());
  }

  @override
  Stream<List<Payment>> watchRecentPayments({int limit = 10}) {
    final query = database.select(database.paymentsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.date, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.watch().map((rows) => rows.map(_mapPayment).toList());
  }

  @override
  Future<List<Payment>> loadPaymentsForDebt(String debtId) async {
    final query = database.select(database.paymentsTable)
      ..where((table) => table.debtId.equals(debtId));
    return (await query.get()).map(_mapPayment).toList();
  }

  @override
  Future<List<Payment>> loadAllPayments() async {
    return (await database.select(database.paymentsTable).get())
        .map(_mapPayment)
        .toList();
  }

  @override
  Future<void> savePayment(Payment payment) async {
    await database
        .into(database.paymentsTable)
        .insertOnConflictUpdate(
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
    await _recalculateDebtBalance(payment.debtId);
  }

  @override
  Future<void> deletePayment(String id) async {
    final payment = await (database.select(
      database.paymentsTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    await (database.delete(
      database.paymentsTable,
    )..where((tbl) => tbl.id.equals(id))).go();
    if (payment != null) {
      await _recalculateDebtBalance(payment.debtId);
    }
  }

  Future<void> _recalculateDebtBalance(String debtId) async {
    final debtRow = await (database.select(
      database.debtsTable,
    )..where((tbl) => tbl.id.equals(debtId))).getSingleOrNull();
    if (debtRow == null) {
      return;
    }
    final payments = await loadPaymentsForDebt(debtId);
    final totalPaid = payments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );
    final nextBalance = (debtRow.originalBalance - totalPaid).clamp(
      0,
      debtRow.originalBalance,
    );
    final nextStatus = nextBalance == 0
        ? DebtStatus.paidOff
        : DebtStatus.values.byName(debtRow.status);
    await (database.update(
      database.debtsTable,
    )..where((tbl) => tbl.id.equals(debtId))).write(
      DebtsTableCompanion(
        currentBalance: Value(nextBalance.toDouble()),
        status: Value(nextStatus.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Payment _mapPayment(PaymentsTableData row) {
    return Payment(
      id: row.id,
      debtId: row.debtId,
      amount: row.amount,
      date: row.date,
      method: row.method,
      sourceType: PaymentSourceType.values.byName(row.sourceType),
      notes: row.notes,
      tags: database.decodeStringList(row.tagsJson),
      createdAt: row.createdAt,
    );
  }
}

class DriftPreferencesRepository implements PreferencesRepository {
  const DriftPreferencesRepository(this.database);

  final AppDatabase database;

  @override
  Stream<UserPreferences> watchPreferences() {
    return database
        .select(database.appPreferencesTable)
        .watchSingleOrNull()
        .map((row) {
          return row == null ? UserPreferences.defaults() : _map(row);
        });
  }

  @override
  Future<UserPreferences> loadPreferences() async {
    final row = await database
        .select(database.appPreferencesTable)
        .getSingleOrNull();
    return row == null ? UserPreferences.defaults() : _map(row);
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) {
    return database
        .into(database.appPreferencesTable)
        .insertOnConflictUpdate(
          AppPreferencesTableCompanion.insert(
            themeMode: Value(preferences.themeMode.name),
            currencyCode: Value(preferences.currencyCode),
            localeCode: Value(preferences.localeCode),
            defaultStrategy: Value(preferences.defaultStrategy.name),
            hideBalances: Value(preferences.hideBalances),
            appLockEnabled: Value(preferences.appLockEnabled),
            aiConsentEnabled: Value(preferences.aiConsentEnabled),
            notificationsEnabled: Value(preferences.notificationsEnabled),
            onboardingCompleted: Value(preferences.onboardingCompleted),
            weeklySummaryEnabled: Value(preferences.weeklySummaryEnabled),
            rawOcrRetentionEnabled: Value(preferences.rawOcrRetentionEnabled),
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
  }

  UserPreferences _map(AppPreferencesTableData row) {
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
}

class DriftDocumentsRepository implements DocumentsRepository {
  DriftDocumentsRepository(this.database, this.vaultService);

  final AppDatabase database;
  final SecureDocumentVaultService vaultService;

  @override
  Stream<List<ImportedDocument>> watchDocuments({String? debtId}) {
    final query = database.select(database.importedDocumentsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ]);
    query.where((table) => table.deleted.equals(false));
    if (debtId != null) {
      query.where((table) => table.linkedDebtId.equals(debtId));
    }
    return query.watch().map((rows) => rows.map(_mapDocument).toList());
  }

  @override
  Future<List<ImportedDocument>> loadDocuments({String? debtId}) async {
    final query = database.select(database.importedDocumentsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ]);
    query.where((table) => table.deleted.equals(false));
    if (debtId != null) {
      query.where((table) => table.linkedDebtId.equals(debtId));
    }
    return (await query.get()).map(_mapDocument).toList();
  }

  @override
  Future<void> saveDocument(ImportedDocument document) {
    return database
        .into(database.importedDocumentsTable)
        .insertOnConflictUpdate(
          ImportedDocumentsTableCompanion.insert(
            id: document.id,
            localPath: const Value(''),
            storageRef: Value(document.storageRef),
            sourceType: document.sourceType.name,
            mimeType: document.mimeType,
            createdAt: document.createdAt,
            linkedDebtId: Value(document.linkedDebtId),
            rawOcrText: Value(document.rawOcrText),
            parseStatus: document.parseStatus.name,
            parseVersion: document.parseVersion,
            deleted: Value(document.deleted),
            retentionExpiresAt: Value(document.retentionExpiresAt),
            rawOcrExpiresAt: Value(document.rawOcrExpiresAt),
            purgedAt: Value(document.purgedAt),
            encryptedAt: Value(document.encryptedAt),
            hasRawOcrText: Value(document.hasRawOcrText),
          ),
        );
  }

  @override
  Future<void> saveParsedExtraction(ParsedExtraction extraction) {
    return database
        .into(database.parsedExtractionsTable)
        .insertOnConflictUpdate(
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

  @override
  Future<void> markDeleted(String documentId) {
    return purgeDocument(documentId);
  }

  @override
  Future<void> linkDocument(String documentId, String? debtId) {
    return (database.update(database.importedDocumentsTable)
          ..where((tbl) => tbl.id.equals(documentId)))
        .write(ImportedDocumentsTableCompanion(linkedDebtId: Value(debtId)));
  }

  @override
  Future<int> countSuccessfulScansInMonth(DateTime month) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final countExp = database.importedDocumentsTable.id.count();
    final query = database.selectOnly(database.importedDocumentsTable)
      ..addColumns([countExp])
      ..where(
        database.importedDocumentsTable.createdAt.isBetweenValues(start, end),
      )
      ..where(
        database.importedDocumentsTable.parseStatus.equals(
          ParseStatus.success.name,
        ),
      );
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  @override
  Future<void> purgeDocument(String documentId) async {
    final row = await (database.select(
      database.importedDocumentsTable,
    )..where((tbl) => tbl.id.equals(documentId))).getSingleOrNull();
    if (row == null) {
      return;
    }
    await _purgeDocumentRows(
      database: database,
      vaultService: vaultService,
      rows: [row],
    );
  }

  @override
  Future<void> purgeExpiredDocuments(DateTime now) async {
    final rows = await (database.select(
      database.importedDocumentsTable,
    )..where((tbl) => tbl.retentionExpiresAt.isSmallerThanValue(now))).get();
    await _purgeDocumentRows(
      database: database,
      vaultService: vaultService,
      rows: rows,
    );
  }

  @override
  Future<void> trimRawOcr(String documentId) {
    return (database.update(
      database.importedDocumentsTable,
    )..where((tbl) => tbl.id.equals(documentId))).write(
      const ImportedDocumentsTableCompanion(
        rawOcrText: Value(null),
        hasRawOcrText: Value(false),
        rawOcrExpiresAt: Value(null),
      ),
    );
  }

  @override
  Future<void> purgeAllDocuments() async {
    final rows = await database.select(database.importedDocumentsTable).get();
    await _purgeDocumentRows(
      database: database,
      vaultService: vaultService,
      rows: rows,
    );
  }

  @override
  Future<void> purgeAllRawOcr() async {
    await database
        .update(database.importedDocumentsTable)
        .write(
          const ImportedDocumentsTableCompanion(
            rawOcrText: Value(null),
            hasRawOcrText: Value(false),
            rawOcrExpiresAt: Value(null),
          ),
        );
  }

  @override
  Future<Uint8List?> readDocumentBytes(String documentId) async {
    final row = await (database.select(
      database.importedDocumentsTable,
    )..where((tbl) => tbl.id.equals(documentId))).getSingleOrNull();
    return vaultService.readDocumentBytes(row?.storageRef);
  }

  ImportedDocument _mapDocument(ImportedDocumentsTableData row) {
    return ImportedDocument(
      id: row.id,
      storageRef: row.storageRef,
      sourceType: DocumentSourceType.values.byName(row.sourceType),
      mimeType: row.mimeType,
      createdAt: row.createdAt,
      linkedDebtId: row.linkedDebtId,
      rawOcrText: row.rawOcrText,
      parseStatus: ParseStatus.values.byName(row.parseStatus),
      parseVersion: row.parseVersion,
      deleted: row.deleted,
      retentionExpiresAt: row.retentionExpiresAt,
      rawOcrExpiresAt: row.rawOcrExpiresAt,
      purgedAt: row.purgedAt,
      encryptedAt: row.encryptedAt,
      hasRawOcrText: row.hasRawOcrText,
    );
  }
}

class DriftScenariosRepository implements ScenariosRepository {
  const DriftScenariosRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<Scenario>> watchScenarios() {
    final query = database.select(database.scenariosTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(_map).toList());
  }

  @override
  Future<void> saveScenario(Scenario scenario) {
    return database
        .into(database.scenariosTable)
        .insertOnConflictUpdate(
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

  @override
  Future<void> deleteScenario(String scenarioId) {
    return (database.delete(
      database.scenariosTable,
    )..where((tbl) => tbl.id.equals(scenarioId))).go();
  }

  Scenario _map(ScenariosTableData row) {
    return Scenario(
      id: row.id,
      strategyType: StrategyType.values.byName(row.strategyType),
      extraPayment: row.extraPayment,
      budget: row.budget,
      createdAt: row.createdAt,
      label: row.label,
      baselineInterest: row.baselineInterest,
      optimizedInterest: row.optimizedInterest,
      monthsToPayoff: row.monthsToPayoff,
    );
  }
}

class DriftSubscriptionRepository implements SubscriptionRepository {
  const DriftSubscriptionRepository(this.database);

  final AppDatabase database;

  @override
  Stream<SubscriptionState> watchSubscription() {
    return database
        .select(database.subscriptionStateTable)
        .watchSingleOrNull()
        .map((row) {
          return row == null ? SubscriptionState.free() : _map(row);
        });
  }

  @override
  Future<SubscriptionState> loadSubscription() async {
    final row = await database
        .select(database.subscriptionStateTable)
        .getSingleOrNull();
    return row == null ? SubscriptionState.free() : _map(row);
  }

  @override
  Future<void> saveSubscription(SubscriptionState state) {
    return database
        .into(database.subscriptionStateTable)
        .insertOnConflictUpdate(
          SubscriptionStateTableCompanion.insert(
            isPremium: Value(state.isPremium),
            expiresAt: Value(state.expiresAt),
            unlockedFeaturesJson: Value(
              jsonEncode(
                state.unlockedFeatures.map((feature) => feature.name).toList(),
              ),
            ),
          ),
        );
  }

  SubscriptionState _map(SubscriptionStateTableData row) {
    final features = (jsonDecode(row.unlockedFeaturesJson) as List<dynamic>)
        .map((item) => PremiumFeature.values.byName(item.toString()))
        .toSet();
    return SubscriptionState(
      isPremium: row.isPremium,
      expiresAt: row.expiresAt,
      unlockedFeatures: features,
    );
  }
}

Future<void> _purgeDocumentRows({
  required AppDatabase database,
  required SecureDocumentVaultService vaultService,
  required List<ImportedDocumentsTableData> rows,
}) async {
  for (final row in rows) {
    await vaultService.purgeStoredDocument(row.storageRef);
    await vaultService.purgeLegacyPlaintext(
      row.localPath.isEmpty ? null : row.localPath,
    );
    await database.transaction(() async {
      await (database.delete(
        database.parsedExtractionsTable,
      )..where((tbl) => tbl.documentId.equals(row.id))).go();
      await (database.delete(
        database.importedDocumentsTable,
      )..where((tbl) => tbl.id.equals(row.id))).go();
    });
  }
}
