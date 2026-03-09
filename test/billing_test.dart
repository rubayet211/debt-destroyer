import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:debt_destroyer/core/services/backend_services.dart';
import 'package:debt_destroyer/core/services/billing_services.dart';
import 'package:debt_destroyer/features/settings/presentation/settings_screens.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/backend_models.dart';
import 'package:debt_destroyer/shared/models/billing_models.dart';
import 'package:debt_destroyer/shared/models/subscription_state.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

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
}

class _StaticBillingController extends BillingController {
  _StaticBillingController(this._initial)
    : super(
        billingService: _FakeBillingService(),
        entitlementSyncService: EntitlementSyncService(
          client: BackendApiClient(
            httpClient: _NoopHttpClient(),
            config: const BackendConfig(
              baseUrl: '',
              environment: 'test',
              playIntegrityProjectNumber: null,
              debugAttestationSecret: null,
              requestTimeout: Duration(seconds: 1),
            ),
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

class _FakeSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<SubscriptionState> loadSubscription() async =>
      SubscriptionState.free();

  @override
  Future<void> saveSubscription(SubscriptionState state) async {}

  @override
  Stream<SubscriptionState> watchSubscription() =>
      Stream.value(SubscriptionState.free());
}

class _NoopHttpClient extends Fake implements http.Client {}
