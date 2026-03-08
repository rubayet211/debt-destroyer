import 'dart:io';

import 'package:camera/camera.dart';
import 'package:csv/csv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../app/router/app_router.dart';
import '../../core/services/app_services.dart';
import '../../core/services/backend_services.dart';
import '../../features/dashboard/domain/debt_metrics_service.dart';
import '../../features/scan_import/domain/import_services.dart';
import '../../features/strategy/domain/strategy_engine.dart';
import '../data/local/app_database.dart';
import '../data/repositories.dart';
import '../enums/app_enums.dart';
import '../models/backend_models.dart';
import '../models/dashboard_snapshot.dart';
import '../models/debt.dart';
import '../models/import_models.dart';
import '../models/payment.dart';
import '../models/strategy_models.dart';
import '../models/subscription_state.dart';
import '../models/user_preferences.dart';

final availableCamerasProvider = Provider<List<CameraDescription>>(
  (ref) => const [],
);
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});
final backendConfigProvider = Provider<BackendConfig>((ref) {
  return BackendConfig(
    baseUrl: dotenv.env['BACKEND_BASE_URL'] ?? '',
    environment: dotenv.env['BACKEND_ENV'] ?? 'development',
    playIntegrityProjectNumber: dotenv.env['PLAY_INTEGRITY_PROJECT_NUMBER'],
    requestTimeout: const Duration(seconds: 15),
  );
});
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
final localAuthProvider = Provider((ref) => LocalAuthentication());
final localNotificationsProvider = Provider(
  (ref) => FlutterLocalNotificationsPlugin(),
);
final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => NoopAnalyticsService(),
);
final crashReporterProvider = Provider<CrashReporter>(
  (ref) => NoopCrashReporter(),
);
final biometricAuthServiceProvider = Provider(
  (ref) => BiometricAuthService(ref.watch(localAuthProvider)),
);
final reminderSchedulerProvider = Provider((ref) {
  final scheduler = ReminderScheduler(ref.watch(localNotificationsProvider));
  scheduler.initialize();
  return scheduler;
});
final premiumServiceProvider = Provider((ref) => const PremiumService());
final csvExportServiceProvider = Provider((ref) => CsvExportService());
final attestationServiceProvider = Provider<AttestationService>(
  (ref) => PlayIntegrityAttestationService(ref.watch(backendConfigProvider)),
);
final backendAuthServiceProvider = Provider<BackendAuthService>(
  (ref) => BackendAuthService(
    storage: ref.watch(secureStorageProvider),
    httpClient: ref.watch(httpClientProvider),
    config: ref.watch(backendConfigProvider),
    attestationService: ref.watch(attestationServiceProvider),
  ),
);
final backendApiClientProvider = Provider<BackendApiClient>(
  (ref) => BackendApiClient(
    httpClient: ref.watch(httpClientProvider),
    config: ref.watch(backendConfigProvider),
    sessionManager: ref.watch(backendAuthServiceProvider),
  ),
);
final backendCapabilitiesServiceProvider = Provider<BackendCapabilitiesService>(
  (ref) => BackendCapabilitiesService(ref.watch(backendApiClientProvider)),
);
final strategyEngineProvider = Provider((ref) => const StrategyEngine());
final debtMetricsServiceProvider = Provider(
  (ref) => DebtMetricsService(ref.watch(strategyEngineProvider)),
);

final debtsRepositoryProvider = Provider<DebtsRepository>(
  (ref) => DriftDebtsRepository(ref.watch(appDatabaseProvider)),
);
final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => DriftPaymentsRepository(ref.watch(appDatabaseProvider)),
);
final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => DriftPreferencesRepository(ref.watch(appDatabaseProvider)),
);
final documentsRepositoryProvider = Provider<DocumentsRepository>(
  (ref) => DriftDocumentsRepository(ref.watch(appDatabaseProvider)),
);
final scenariosRepositoryProvider = Provider<ScenariosRepository>(
  (ref) => DriftScenariosRepository(ref.watch(appDatabaseProvider)),
);
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => DriftSubscriptionRepository(ref.watch(appDatabaseProvider)),
);

final imagePreprocessServiceProvider = Provider<ImagePreprocessService>(
  (ref) => PassthroughImagePreprocessService(),
);
final ocrServiceProvider = Provider<OcrService>((ref) => MlKitOcrService());
final documentClassifierProvider = Provider((ref) => DocumentClassifier());
final heuristicParserProvider = Provider((ref) => HeuristicExtractionParser());
final aiExtractionServiceProvider = Provider<AiExtractionService>(
  (ref) => BackendAiExtractionService(
    client: ref.watch(backendApiClientProvider),
    sessionManager: ref.watch(backendAuthServiceProvider),
    config: ref.watch(backendConfigProvider),
    parser: ref.watch(heuristicParserProvider),
  ),
);
final parseValidationServiceProvider = Provider(
  (ref) => ParseValidationService(),
);
final fileStorageServiceProvider = Provider((ref) => FileStorageService());
final importCoordinatorProvider = Provider(
  (ref) => ImportCoordinator(
    fileStorageService: ref.watch(fileStorageServiceProvider),
    preprocessService: ref.watch(imagePreprocessServiceProvider),
    ocrService: ref.watch(ocrServiceProvider),
    classifier: ref.watch(documentClassifierProvider),
    aiExtractionService: ref.watch(aiExtractionServiceProvider),
    validationService: ref.watch(parseValidationServiceProvider),
  ),
);

final userPreferencesProvider = StreamProvider<UserPreferences>(
  (ref) => ref.watch(preferencesRepositoryProvider).watchPreferences(),
);
final debtsProvider = StreamProvider<List<Debt>>(
  (ref) => ref.watch(debtsRepositoryProvider).watchDebts(),
);
final allDebtsProvider = StreamProvider<List<Debt>>(
  (ref) => ref.watch(debtsRepositoryProvider).watchDebts(includeArchived: true),
);
final subscriptionStateProvider = StreamProvider<SubscriptionState>(
  (ref) => ref.watch(subscriptionRepositoryProvider).watchSubscription(),
);
final scenariosProvider = StreamProvider<List<Scenario>>(
  (ref) => ref.watch(scenariosRepositoryProvider).watchScenarios(),
);
final recentPaymentsProvider = StreamProvider<List<Payment>>(
  (ref) => ref.watch(paymentsRepositoryProvider).watchRecentPayments(limit: 10),
);
final debtProvider = StreamProvider.family<Debt?, String>(
  (ref, id) => ref.watch(debtsRepositoryProvider).watchDebt(id),
);
final paymentsByDebtProvider = StreamProvider.family<List<Payment>, String>(
  (ref, debtId) =>
      ref.watch(paymentsRepositoryProvider).watchPaymentsForDebt(debtId),
);
final documentsByDebtProvider =
    StreamProvider.family<List<ImportedDocument>, String?>(
      (ref, debtId) =>
          ref.watch(documentsRepositoryProvider).watchDocuments(debtId: debtId),
    );

final dashboardSnapshotProvider = Provider<AsyncValue<DashboardSnapshot>>((
  ref,
) {
  final prefs = ref.watch(userPreferencesProvider);
  final debts = ref.watch(debtsProvider);
  final payments = ref.watch(recentPaymentsProvider);
  if (prefs is AsyncError<UserPreferences>) {
    return AsyncValue.error(prefs.error, prefs.stackTrace);
  }
  if (debts is AsyncError<List<Debt>>) {
    return AsyncValue.error(debts.error, debts.stackTrace);
  }
  if (payments is AsyncError<List<Payment>>) {
    return AsyncValue.error(payments.error, payments.stackTrace);
  }
  if (prefs is! AsyncData<UserPreferences> ||
      debts is! AsyncData<List<Debt>> ||
      payments is! AsyncData<List<Payment>>) {
    return const AsyncValue.loading();
  }
  return AsyncValue.data(
    ref
        .watch(debtMetricsServiceProvider)
        .buildDashboard(
          debts: debts.value,
          recentPayments: payments.value,
          strategyType: prefs.value.defaultStrategy,
        ),
  );
});

final appRouterProvider = Provider((ref) => buildRouter(ref));
final selectedDebtFilterProvider = StateProvider<String>((ref) => '');
final debtSortStrategyProvider = StateProvider<StrategyType?>((ref) => null);
final debtSortModeProvider = StateProvider<String>((ref) => 'updated');
final appLockSessionProvider = StateProvider<bool>((ref) => false);
final scanImportStateProvider =
    StateNotifierProvider<
      ScanImportController,
      AsyncValue<ImportReviewBundle?>
    >((ref) => ScanImportController(ref));

class ScanImportController
    extends StateNotifier<AsyncValue<ImportReviewBundle?>> {
  ScanImportController(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> process({
    required FileReference input,
    required bool allowCloud,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(importCoordinatorProvider)
          .process(input: input, allowCloud: allowCloud),
    );
  }

  void clear() => state = const AsyncValue.data(null);
}

final seedDemoDataProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final debtsRepository = ref.read(debtsRepositoryProvider);
    final paymentsRepository = ref.read(paymentsRepositoryProvider);
    final now = DateTime.now();
    final visaId = const Uuid().v4();
    final bnplId = const Uuid().v4();

    await debtsRepository.saveDebt(
      Debt(
        id: visaId,
        title: 'Visa Momentum',
        creditorName: 'Summit Bank',
        type: DebtType.creditCard,
        currency: 'USD',
        originalBalance: 6200,
        currentBalance: 4200,
        apr: 22.9,
        minimumPayment: 145,
        dueDate: DateTime(now.year, now.month, now.day + 6),
        paymentFrequency: PaymentFrequency.monthly,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now,
        notes: 'Primary spending card.',
        tags: const ['card', 'travel'],
        status: DebtStatus.active,
        remindersEnabled: true,
        customPriority: 2,
      ),
    );

    await debtsRepository.saveDebt(
      Debt(
        id: bnplId,
        title: 'Laptop Flex Pay',
        creditorName: 'PayLater',
        type: DebtType.bnpl,
        currency: 'USD',
        originalBalance: 1800,
        currentBalance: 760,
        apr: 0,
        minimumPayment: 95,
        dueDate: DateTime(now.year, now.month, now.day + 2),
        paymentFrequency: PaymentFrequency.monthly,
        createdAt: now.subtract(const Duration(days: 70)),
        updatedAt: now,
        notes: 'Clears this summer.',
        tags: const ['bnpl'],
        status: DebtStatus.active,
        remindersEnabled: true,
        customPriority: 1,
      ),
    );

    await paymentsRepository.savePayment(
      Payment(
        id: const Uuid().v4(),
        debtId: visaId,
        amount: 260,
        date: now.subtract(const Duration(days: 12)),
        method: 'Bank transfer',
        sourceType: PaymentSourceType.manual,
        notes: 'March payment',
        tags: const ['monthly'],
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    );
  };
});

final exportCsvProvider = Provider<Future<File> Function()>((ref) {
  return () async {
    final debts = await ref
        .read(debtsRepositoryProvider)
        .loadDebts(includeArchived: true);
    final payments = await ref
        .read(paymentsRepositoryProvider)
        .loadAllPayments();
    final rows = <List<dynamic>>[
      ['type', 'id', 'title', 'creditor', 'balance', 'apr', 'status', 'date'],
      ...debts.map(
        (debt) => [
          'debt',
          debt.id,
          debt.title,
          debt.creditorName,
          debt.currentBalance,
          debt.apr,
          debt.status.name,
          debt.updatedAt.toIso8601String(),
        ],
      ),
      ...payments.map(
        (payment) => [
          'payment',
          payment.id,
          payment.debtId,
          payment.method ?? '',
          payment.amount,
          '',
          payment.sourceType.name,
          payment.date.toIso8601String(),
        ],
      ),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, 'debt_destroyer_export.csv'));
    await file.writeAsString(csv);
    return file;
  };
});
