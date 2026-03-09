import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:sqlite3/open.dart' as sqlite_open;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

import '../../../core/services/vault_services.dart';
part 'app_database.g.dart';

class DebtsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get creditorName => text()();
  TextColumn get type => text()();
  TextColumn get currency => text()();
  RealColumn get originalBalance => real()();
  RealColumn get currentBalance => real()();
  RealColumn get apr => real()();
  RealColumn get minimumPayment => real()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get paymentFrequency => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get financialTermsJson =>
      text().withDefault(const Constant('{}'))();
  TextColumn get status => text()();
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get customPriority => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PaymentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get debtId => text().references(DebtsTable, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get method => text().nullable()();
  TextColumn get sourceType => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ImportedDocumentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get localPath => text().withDefault(const Constant(''))();
  TextColumn get storageRef => text().nullable()();
  TextColumn get sourceType => text()();
  TextColumn get mimeType => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get lifecycleState =>
      text().withDefault(const Constant('imported'))();
  TextColumn get linkedDebtId => text().nullable()();
  TextColumn get rawOcrText => text().nullable()();
  TextColumn get parseStatus => text()();
  TextColumn get parseVersion => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get retentionExpiresAt => dateTime().nullable()();
  DateTimeColumn get rawOcrExpiresAt => dateTime().nullable()();
  DateTimeColumn get processedAt => dateTime().nullable()();
  DateTimeColumn get linkedAt => dateTime().nullable()();
  DateTimeColumn get pendingDeletionAt => dateTime().nullable()();
  DateTimeColumn get purgedAt => dateTime().nullable()();
  DateTimeColumn get encryptedAt => dateTime().nullable()();
  BoolColumn get hasRawOcrText =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ParsedExtractionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text().references(ImportedDocumentsTable, #id)();
  TextColumn get classification => text()();
  RealColumn get confidence => real()();
  TextColumn get payloadJson => text()();
  TextColumn get ambiguityNotes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ReminderRulesTable extends Table {
  TextColumn get id => text()();
  TextColumn get debtId => text().references(DebtsTable, #id)();
  IntColumn get daysBefore => integer().withDefault(const Constant(2))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ScenariosTable extends Table {
  TextColumn get id => text()();
  TextColumn get strategyType => text()();
  RealColumn get extraPayment => real()();
  RealColumn get budget => real()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get label => text()();
  RealColumn get baselineInterest => real()();
  RealColumn get optimizedInterest => real()();
  IntColumn get monthsToPayoff => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppPreferencesTable extends Table {
  IntColumn get key => integer().withDefault(const Constant(1))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  TextColumn get localeCode => text().withDefault(const Constant('en_US'))();
  TextColumn get defaultStrategy =>
      text().withDefault(const Constant('avalanche'))();
  BoolColumn get hideBalances => boolean().withDefault(const Constant(false))();
  BoolColumn get appLockEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get aiConsentEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get weeklySummaryEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get rawOcrRetentionEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get rawOcrRetentionHours =>
      integer().withDefault(const Constant(0))();
  TextColumn get documentRetentionMode =>
      text().withDefault(const Constant('days30'))();
  IntColumn get purgeFailedImportsAfterHours =>
      integer().withDefault(const Constant(24))();
  BoolColumn get dataProtectionExplainerSeen =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class SubscriptionStateTable extends Table {
  IntColumn get key => integer().withDefault(const Constant(1))();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  TextColumn get productId => text().nullable()();
  TextColumn get planId => text().nullable()();
  TextColumn get billingProvider => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('free'))();
  DateTimeColumn get lastVerifiedAt => dateTime().nullable()();
  TextColumn get unlockedFeaturesJson =>
      text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    DebtsTable,
    PaymentsTable,
    ImportedDocumentsTable,
    ParsedExtractionsTable,
    ReminderRulesTable,
    ScenariosTable,
    AppPreferencesTable,
    SubscriptionStateTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(
          importedDocumentsTable,
          importedDocumentsTable.storageRef,
        );
        await migrator.addColumn(
          importedDocumentsTable,
          importedDocumentsTable.retentionExpiresAt,
        );
        await migrator.addColumn(
          importedDocumentsTable,
          importedDocumentsTable.purgedAt,
        );
        await migrator.addColumn(
          importedDocumentsTable,
          importedDocumentsTable.encryptedAt,
        );
        await migrator.addColumn(
          importedDocumentsTable,
          importedDocumentsTable.hasRawOcrText,
        );
        await migrator.addColumn(
          appPreferencesTable,
          appPreferencesTable.rawOcrRetentionEnabled,
        );
        await migrator.addColumn(
          appPreferencesTable,
          appPreferencesTable.rawOcrRetentionHours,
        );
        await migrator.addColumn(
          appPreferencesTable,
          appPreferencesTable.documentRetentionMode,
        );
        await migrator.addColumn(
          appPreferencesTable,
          appPreferencesTable.purgeFailedImportsAfterHours,
        );
        await migrator.addColumn(
          appPreferencesTable,
          appPreferencesTable.dataProtectionExplainerSeen,
        );
      }
      if (from < 3) {
        await migrator.addColumn(
          importedDocumentsTable,
          importedDocumentsTable.rawOcrExpiresAt,
        );
      }
      if (from < 4) {
        await customStatement(
          'alter table subscription_state_table add column product_id text null',
        );
        await customStatement(
          'alter table subscription_state_table add column plan_id text null',
        );
        await customStatement(
          'alter table subscription_state_table add column billing_provider text null',
        );
        await customStatement(
          "alter table subscription_state_table add column status text not null default 'free'",
        );
        await customStatement(
          'alter table subscription_state_table add column last_verified_at integer null',
        );
      }
      if (from < 5) {
        await customStatement(
          "alter table imported_documents_table add column lifecycle_state text not null default 'imported'",
        );
        await customStatement(
          'alter table imported_documents_table add column processed_at integer null',
        );
        await customStatement(
          'alter table imported_documents_table add column linked_at integer null',
        );
        await customStatement(
          'alter table imported_documents_table add column pending_deletion_at integer null',
        );
        await customStatement('''
          update imported_documents_table
          set lifecycle_state = case
            when purged_at is not null then 'purged'
            when deleted = 1 then 'pendingDeletion'
            when linked_debt_id is not null then 'linked'
            when parse_status = 'success' then 'processed'
            else 'imported'
          end
        ''');
        await customStatement('''
          update imported_documents_table
          set processed_at = created_at
          where lifecycle_state in ('processed', 'linked')
            and processed_at is null
        ''');
        await customStatement('''
          update imported_documents_table
          set linked_at = created_at
          where lifecycle_state = 'linked'
            and linked_at is null
        ''');
        await customStatement('''
          update imported_documents_table
          set pending_deletion_at = coalesce(pending_deletion_at, created_at)
          where lifecycle_state = 'pendingDeletion'
            and pending_deletion_at is null
        ''');
      }
      if (from < 6) {
        await migrator.addColumn(debtsTable, debtsTable.financialTermsJson);
        await customStatement('''
          update debts_table
          set financial_terms_json = '{}'
          where financial_terms_json is null or financial_terms_json = ''
        ''');
      }
    },
  );

  List<String> decodeStringList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item.toString()).toList();
  }

  String encodeStringList(List<String> value) => jsonEncode(value);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final keyService = const LocalVaultKeyService();
    final directory = await getApplicationSupportDirectory();
    final legacyDirectory = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(directory.path, 'debt_destroyer.sqlite'));
    final legacyDbFile = File(
      p.join(legacyDirectory.path, 'debt_destroyer.sqlite'),
    );
    final passphrase = await keyService.databasePassphrase();
    await _prepareEncryptedDatabase(
      dbFile: dbFile,
      legacyDbFile: legacyDbFile,
      passphrase: passphrase,
      keyService: keyService,
    );
    return NativeDatabase.createInBackground(
      dbFile,
      isolateSetup: () {
        sqlite_open.open.overrideFor(
          sqlite_open.OperatingSystem.android,
          openCipherOnAndroid,
        );
      },
      setup: (rawDb) {
        rawDb.execute("PRAGMA key = '${_escapeSql(passphrase)}';");
        rawDb.execute('PRAGMA foreign_keys = ON;');
        rawDb.execute('PRAGMA journal_mode = WAL;');
        if (kDebugMode) {
          final version = rawDb.select('PRAGMA cipher_version;');
          if (version.isEmpty || version.first.values.first == null) {
            throw StateError(
              'Encrypted SQLite support unavailable. Check SQLCipher bundling.',
            );
          }
        }
      },
    );
  });
}

Future<void> _prepareEncryptedDatabase({
  required File dbFile,
  required File legacyDbFile,
  required String passphrase,
  required LocalVaultKeyService keyService,
}) async {
  _configureCipherOpen();
  final backupFile = File('${dbFile.path}.plaintext.bak');
  final existingEncrypted = await _canOpenEncrypted(dbFile, passphrase);
  if (existingEncrypted) {
    await keyService.clearMigrationStage();
    await keyService.setMigrationFailure(null);
    if (await backupFile.exists()) {
      await backupFile.delete();
    }
    return;
  }

  if (await dbFile.exists()) {
    await keyService.setMigrationStage('encrypting_database');
    await _encryptPlaintextDatabase(
      target: dbFile,
      backup: backupFile,
      passphrase: passphrase,
    );
    await keyService.setUpgradeExplainerPending(true);
    await keyService.clearMigrationStage();
    await keyService.setMigrationFailure(null);
    return;
  }

  if (await legacyDbFile.exists()) {
    await keyService.setMigrationStage('copying_legacy_database');
    if (!await dbFile.parent.exists()) {
      await dbFile.parent.create(recursive: true);
    }
    await legacyDbFile.copy(dbFile.path);
    await _encryptPlaintextDatabase(
      target: dbFile,
      backup: backupFile,
      passphrase: passphrase,
    );
    await keyService.setUpgradeExplainerPending(true);
    await keyService.clearMigrationStage();
    await keyService.setMigrationFailure(null);
  }
}

Future<bool> _canOpenEncrypted(File file, String passphrase) async {
  if (!await file.exists()) {
    return false;
  }
  sqlite.Database? db;
  try {
    db = sqlite.sqlite3.open(file.path);
    db.execute("PRAGMA key = '${_escapeSql(passphrase)}';");
    db.select('SELECT count(*) FROM sqlite_master;');
    final cipher = db.select('PRAGMA cipher_version;');
    return cipher.isNotEmpty;
  } catch (_) {
    return false;
  } finally {
    db?.dispose();
  }
}

Future<void> _encryptPlaintextDatabase({
  required File target,
  required File backup,
  required String passphrase,
}) async {
  if (!await backup.exists()) {
    await target.copy(backup.path);
  }
  sqlite.Database? db;
  try {
    db = sqlite.sqlite3.open(target.path);
    db.execute("PRAGMA rekey = '${_escapeSql(passphrase)}';");
    db.dispose();
    db = null;
    if (!await _canOpenEncrypted(target, passphrase)) {
      throw StateError('Encrypted database verification failed');
    }
    if (await backup.exists()) {
      await backup.delete();
    }
  } catch (error) {
    if (db != null) {
      db.dispose();
    }
    if (await backup.exists()) {
      if (await target.exists()) {
        await target.delete();
      }
      await backup.copy(target.path);
    }
    await const LocalVaultKeyService().setMigrationFailure(
      'Local database protection could not be completed.',
    );
    rethrow;
  }
}

String _escapeSql(String value) => value.replaceAll("'", "''");

void _configureCipherOpen() {
  sqlite_open.open.overrideFor(
    sqlite_open.OperatingSystem.android,
    openCipherOnAndroid,
  );
}
