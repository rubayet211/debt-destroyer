import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  TextColumn get localPath => text()();
  TextColumn get sourceType => text()();
  TextColumn get mimeType => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get linkedDebtId => text().nullable()();
  TextColumn get rawOcrText => text().nullable()();
  TextColumn get parseStatus => text()();
  TextColumn get parseVersion => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

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

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class SubscriptionStateTable extends Table {
  IntColumn get key => integer().withDefault(const Constant(1))();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  DateTimeColumn get expiresAt => dateTime().nullable()();
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
  int get schemaVersion => 1;

  List<String> decodeStringList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item.toString()).toList();
  }

  String encodeStringList(List<String> value) => jsonEncode(value);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(directory.path, 'debt_destroyer.sqlite'));
    return NativeDatabase.createInBackground(dbFile);
  });
}
