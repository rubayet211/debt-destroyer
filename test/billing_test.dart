import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';

import 'package:debt_destroyer/core/constants/app_constants.dart';
import 'package:debt_destroyer/core/services/backend_services.dart';
import 'package:debt_destroyer/core/services/billing_services.dart';
import 'package:debt_destroyer/features/settings/presentation/settings_screens.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/backend_models.dart';
import 'package:debt_destroyer/shared/models/billing_models.dart';
import 'package:debt_destroyer/shared/models/subscription_state.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

const _backendConfig = BackendConfig(
  baseUrl: 'https://example.test',
  environment: 'test',
  playIntegrityCloudProjectNumber: null,
  playIntegrityPackageName: 'com.debtdestroyer.app',
  debugAttestationSecret: null,
  requestTimeout: Duration(seconds: 1),
  premiumProductId: AppConstants.premiumProductId,
  premiumMonthlyBasePlanId: AppConstants.premiumMonthlyBasePlanId,
  premiumYearlyBasePlanId: AppConstants.premiumYearlyBasePlanId,
);

void main() {
  test('expired entitlement disables premium feature access offline', () {
    final expired = SubscriptionState(
      isPremium: true,
      expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      unlockedFeatures: const {PremiumFeature.pdfImport},
      status: 'expired',
    );

    expect(expired.isActive, isFalse);
    expect(expired.hasFeature(PremiumFeature.pdfImport), isFalse);
  });

  testWidgets('premium screen shows monthly/yearly plans and restore action', (
    tester,
  ) async {
    final controller = _StaticBillingController(
      BillingState(
        status: BillingStatus.idle,
        catalog: BillingCatalog(
          plans: [
            BillingPlan(
              productId: 'premium',
              basePlanId: 'yearly',
              offerToken: 'yearly-token',
              title: 'Premium',
              description: 'Yearly plan',
              priceLabel: '\$49.99',
              currencyCode: 'USD',
              rawPrice: 49.99,
              billingPeriod: 'year',
              isHighlighted: true,
              productDetails: ProductDetails(
                id: 'premium',
                title: 'Premium',
                description: 'Yearly plan',
                price: '\$49.99',
                rawPrice: 49.99,
                currencyCode: 'USD',
              ),
            ),
            BillingPlan(
              productId: 'premium',
              basePlanId: 'monthly',
              offerToken: 'monthly-token',
              title: 'Premium',
              description: 'Monthly plan',
              priceLabel: '\$5.99',
              currencyCode: 'USD',
              rawPrice: 5.99,
              billingPeriod: 'month',
              isHighlighted: false,
              productDetails: ProductDetails(
                id: 'premium',
                title: 'Premium',
                description: 'Monthly plan',
                price: '\$5.99',
                rawPrice: 5.99,
                currencyCode: 'USD',
              ),
            ),
          ],
          loadedAt: DateTime(2026, 3, 9),
        ),
        entitlement: EntitlementSnapshot.free(),
        message: null,
        selectedPlanId: 'yearly',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionStateProvider.overrideWith(
            (ref) => Stream.value(SubscriptionState.free()),
          ),
          entitlementRefreshProvider.overrideWith(
            (ref) async => EntitlementSnapshot.free(),
          ),
          billingControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: PremiumScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Restore purchases'), findsOneWidget);
  });

  testWidgets('premium screen shows retryable error message', (tester) async {
    final controller = _StaticBillingController(
      BillingState(
        status: BillingStatus.error,
        catalog: null,
        entitlement: EntitlementSnapshot.free(),
        message: 'Billing is temporarily unavailable.',
        selectedPlanId: null,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionStateProvider.overrideWith(
            (ref) => Stream.value(SubscriptionState.free()),
          ),
          entitlementRefreshProvider.overrideWith(
            (ref) async => EntitlementSnapshot.free(),
          ),
          billingControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: PremiumScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Billing is temporarily unavailable.'), findsOneWidget);
  });

  testWidgets('premium screen disables restore while purchase is pending', (
    tester,
  ) async {
    final controller = _StaticBillingController(
      BillingState(
        status: BillingStatus.pending,
        catalog: BillingCatalog(
          plans: const [],
          loadedAt: DateTime(2026, 3, 9),
        ),
        entitlement: EntitlementSnapshot.free(),
        message: 'Waiting for Google Play confirmation.',
        selectedPlanId: null,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionStateProvider.overrideWith(
            (ref) => Stream.value(SubscriptionState.free()),
          ),
          entitlementRefreshProvider.overrideWith(
            (ref) async => EntitlementSnapshot.free(),
          ),
          billingControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: PremiumScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final restoreButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Restore purchases'),
    );
    expect(restoreButton.onPressed, isNull);
    expect(find.text('Waiting for Google Play confirmation.'), findsOneWidget);
  });

  test('capabilities refresh ignores unknown backend feature names', () async {
    final subscriptionRepository = _MemorySubscriptionRepository();
    final sessionManager = _FixedSessionManager();
    final service = EntitlementSyncService(
      client: BackendApiClient(
        httpClient: _JsonHttpClient((request) async {
          expect(request.headers['Authorization'], 'Bearer access-token');
          return http.Response(
            jsonEncode({
              'premium': true,
              'features': ['pdfImport', 'futureFlag'],
              'free_scan_remaining': 0,
              'rate_limit_state': 'ok',
              'entitlement': {
                'is_premium': true,
                'features': ['pdfImport', 'futureFlag'],
                'valid_until': '2026-04-09T00:00:00.000Z',
                'status': 'active',
                'product_id': 'premium',
                'plan_id': 'yearly',
                'billing_provider': 'google_play',
                'last_verified_at': '2026-03-09T00:00:00.000Z',
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        config: _backendConfig,
        sessionManager: sessionManager,
      ),
      sessionManager: sessionManager,
      subscriptionRepository: subscriptionRepository,
    );

    final snapshot = await service.refreshFromCapabilities();
    expect(snapshot.features, {PremiumFeature.pdfImport});

    final cached = await subscriptionRepository.loadSubscription();
    expect(cached.unlockedFeatures, {PremiumFeature.pdfImport});
  });

  test(
    'billing catalog fails clearly when no valid premium plans are returned',
    () async {
      final inAppPurchase = _MockInAppPurchase();
      when(() => inAppPurchase.isAvailable()).thenAnswer((_) async => true);
      when(
        () =>
            inAppPurchase.queryProductDetails({AppConstants.premiumProductId}),
      ).thenAnswer(
        (_) async => ProductDetailsResponse(
          productDetails: [
            ProductDetails(
              id: 'premium',
              title: 'Premium',
              description: 'Misconfigured product',
              price: '\$4.99',
              rawPrice: 4.99,
              currencyCode: 'USD',
            ),
          ],
          notFoundIDs: const [],
        ),
      );

      final service = GooglePlayBillingService(
        inAppPurchase,
        productId: AppConstants.premiumProductId,
        monthlyBasePlanId: AppConstants.premiumMonthlyBasePlanId,
        yearlyBasePlanId: AppConstants.premiumYearlyBasePlanId,
      );

      await expectLater(
        service.loadCatalog(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('No valid Play Billing plans found'),
          ),
        ),
      );
    },
  );

  test('billing service uses configured Play product ids', () async {
    final inAppPurchase = _MockInAppPurchase();
    when(() => inAppPurchase.isAvailable()).thenAnswer((_) async => true);
    when(
      () => inAppPurchase.queryProductDetails({'custom-premium'}),
    ).thenAnswer(
      (_) async => ProductDetailsResponse(
        productDetails: const [],
        notFoundIDs: const [],
      ),
    );

    final service = GooglePlayBillingService(
      inAppPurchase,
      productId: 'custom-premium',
      monthlyBasePlanId: 'm-plan',
      yearlyBasePlanId: 'y-plan',
    );

    await expectLater(service.loadCatalog(), throwsA(isA<StateError>()));
    verify(
      () => inAppPurchase.queryProductDetails({'custom-premium'}),
    ).called(1);
  });

  test(
    'purchase verification does not use selected plan state as base plan id',
    () async {
      final billingService = _StreamingBillingService();
      final syncService = _CapturingEntitlementSyncService();
      final controller = BillingController(
        billingService: billingService,
        entitlementSyncService: syncService,
        sessionManager: _FakeSessionManager(),
        packageName: 'com.debtdestroyer.app',
        appVersion: '1.0.0+1',
      );
      addTearDown(controller.dispose);
      addTearDown(billingService.dispose);

      await Future<void>.delayed(Duration.zero);
      expect(controller.state.selectedPlanId, 'yearly');

      billingService.emitPurchases([
        PurchaseDetails(
          productID: 'premium',
          verificationData: PurchaseVerificationData(
            localVerificationData: '{}',
            serverVerificationData: 'purchase-token',
            source: 'google_play',
          ),
          transactionDate: '1741478400000',
          status: PurchaseStatus.purchased,
        ),
      ]);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(syncService.lastAttempt, isNotNull);
      expect(syncService.lastAttempt!.basePlanId, isNull);
      expect(controller.state.status, BillingStatus.verified);
    },
  );
}

class _StaticBillingController extends BillingController {
  _StaticBillingController(this._initial)
    : super(
        billingService: _FakeBillingService(),
        entitlementSyncService: EntitlementSyncService(
          client: BackendApiClient(
            httpClient: _NoopHttpClient(),
            config: _backendConfig.copyWith(baseUrl: ''),
            sessionManager: _FakeSessionManager(),
          ),
          sessionManager: _FakeSessionManager(),
          subscriptionRepository: _FakeSubscriptionRepository(),
        ),
        sessionManager: _FakeSessionManager(),
        packageName: 'com.debtdestroyer.app',
        appVersion: '1.0.0+1',
      );

  final BillingState _initial;

  @override
  Future<void> initialize() async {
    state = _initial;
  }
}

class _FakeBillingService implements BillingService {
  @override
  Stream<List<PurchaseDetails>> get purchaseStream => const Stream.empty();

  @override
  Future<void> buyPlan(
    BillingPlan plan, {
    required String applicationUserName,
  }) async {}

  @override
  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {}

  @override
  Future<BillingCatalog> loadCatalog() async =>
      BillingCatalog(plans: const [], loadedAt: DateTime(2026, 3, 9));

  @override
  Future<List<PurchaseAttempt>> queryOwnedPurchases() async => const [];
}

class _StreamingBillingService implements BillingService {
  final StreamController<List<PurchaseDetails>> _controller =
      StreamController<List<PurchaseDetails>>.broadcast();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<void> buyPlan(
    BillingPlan plan, {
    required String applicationUserName,
  }) async {}

  @override
  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {}

  @override
  Future<BillingCatalog> loadCatalog() async => BillingCatalog(
    plans: [
      BillingPlan(
        productId: 'premium',
        basePlanId: 'yearly',
        offerToken: 'yearly-token',
        title: 'Premium',
        description: 'Yearly plan',
        priceLabel: '\$49.99',
        currencyCode: 'USD',
        rawPrice: 49.99,
        billingPeriod: 'year',
        isHighlighted: true,
        productDetails: ProductDetails(
          id: 'premium',
          title: 'Premium',
          description: 'Yearly plan',
          price: '\$49.99',
          rawPrice: 49.99,
          currencyCode: 'USD',
        ),
      ),
    ],
    loadedAt: DateTime(2026, 3, 9),
  );

  @override
  Future<List<PurchaseAttempt>> queryOwnedPurchases() async => const [];

  void emitPurchases(List<PurchaseDetails> purchases) {
    _controller.add(purchases);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class _FakeSessionManager implements BackendSessionManager {
  @override
  Future<void> clearSession() async {}

  @override
  Future<InstallSession?> ensureSession() async => null;

  @override
  Future<String> getOrCreateInstallId() async => 'install-1';

  @override
  Future<InstallSession> refreshSession() {
    throw UnimplementedError();
  }
}

class _FixedSessionManager implements BackendSessionManager {
  const _FixedSessionManager();

  @override
  Future<void> clearSession() async {}

  @override
  Future<InstallSession?> ensureSession() async => InstallSession(
    installId: 'install-1',
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    attestationStatus: 'verified',
  );

  @override
  Future<String> getOrCreateInstallId() async => 'install-1';

  @override
  Future<InstallSession> refreshSession() async {
    throw UnimplementedError();
  }
}

class _MemorySubscriptionRepository implements SubscriptionRepository {
  final StreamController<SubscriptionState> _controller =
      StreamController<SubscriptionState>.broadcast();
  SubscriptionState _state = SubscriptionState.free();

  @override
  Future<SubscriptionState> loadSubscription() async => _state;

  @override
  Future<void> saveSubscription(SubscriptionState state) async {
    _state = state;
    _controller.add(state);
  }

  @override
  Stream<SubscriptionState> watchSubscription() async* {
    yield _state;
    yield* _controller.stream;
  }
}

class _FakeSubscriptionRepository extends _MemorySubscriptionRepository {}

class _CapturingEntitlementSyncService extends EntitlementSyncService {
  factory _CapturingEntitlementSyncService() {
    final repository = _MemorySubscriptionRepository();
    return _CapturingEntitlementSyncService._(repository);
  }

  _CapturingEntitlementSyncService._(this._repository)
    : super(
        client: BackendApiClient(
          httpClient: _NoopHttpClient(),
          config: _backendConfig.copyWith(baseUrl: ''),
          sessionManager: const _FixedSessionManager(),
        ),
        sessionManager: const _FixedSessionManager(),
        subscriptionRepository: _repository,
      );

  final _MemorySubscriptionRepository _repository;
  PurchaseAttempt? lastAttempt;

  @override
  Future<EntitlementSnapshot> loadCachedEntitlement() async =>
      EntitlementSnapshot.free();

  @override
  Future<EntitlementSnapshot> refreshFromCapabilities() async =>
      EntitlementSnapshot.free();

  @override
  Future<EntitlementSnapshot> verifyGooglePlayPurchase({
    required PurchaseAttempt attempt,
    required String packageName,
    required String appVersion,
  }) async {
    lastAttempt = attempt;
    const snapshot = EntitlementSnapshot(
      isPremium: true,
      features: {PremiumFeature.pdfImport},
      validUntil: null,
      status: 'active',
      productId: 'premium',
      planId: 'yearly',
      billingProvider: 'google_play',
      lastVerifiedAt: null,
    );
    await _repository.saveSubscription(snapshot.toSubscriptionState());
    return snapshot;
  }
}

class _MockInAppPurchase extends Mock implements InAppPurchase {}

class _NoopHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream.value(utf8.encode('{}')), 200);
  }
}

class _JsonHttpClient extends http.BaseClient {
  _JsonHttpClient(this._handler);

  final Future<http.Response> Function(http.BaseRequest request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      request: request,
    );
  }
}
