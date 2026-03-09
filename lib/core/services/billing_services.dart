import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/billing_models.dart';
import '../../shared/data/repositories.dart';
import 'backend_services.dart';

abstract class BillingService {
  Stream<List<PurchaseDetails>> get purchaseStream;

  Future<BillingCatalog> loadCatalog();
  Future<void> buyPlan(BillingPlan plan, {required String applicationUserName});
  Future<List<PurchaseAttempt>> queryOwnedPurchases();
  Future<void> completePurchase(PurchaseDetails purchaseDetails);
}

class GooglePlayBillingService implements BillingService {
  GooglePlayBillingService(
    this._inAppPurchase, {
    required String productId,
    required String monthlyBasePlanId,
    required String yearlyBasePlanId,
  }) : _productId = productId,
       _monthlyBasePlanId = monthlyBasePlanId,
       _yearlyBasePlanId = yearlyBasePlanId;

  final InAppPurchase _inAppPurchase;
  final String _productId;
  final String _monthlyBasePlanId;
  final String _yearlyBasePlanId;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;

  @override
  Future<BillingCatalog> loadCatalog() async {
    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw StateError('Google Play Billing is unavailable on this device.');
    }

    final response = await _inAppPurchase.queryProductDetails({_productId});
    if (response.error != null) {
      throw StateError(response.error!.message);
    }

    final invalidPlanErrors = <String>[];
    final plans =
        response.productDetails
            .whereType<GooglePlayProductDetails>()
            .map((details) {
              try {
                return _mapPlan(details);
              } on StateError catch (error) {
                invalidPlanErrors.add(error.message);
                return null;
              }
            })
            .whereType<BillingPlan>()
            .where(
              (plan) =>
                  plan.basePlanId == _monthlyBasePlanId ||
                  plan.basePlanId == _yearlyBasePlanId,
            )
            .toList()
          ..sort((left, right) {
            final order = {_yearlyBasePlanId: 0, _monthlyBasePlanId: 1};
            return (order[left.basePlanId] ?? 9).compareTo(
              order[right.basePlanId] ?? 9,
            );
          });

    if (plans.isEmpty) {
      throw StateError(
        invalidPlanErrors.isEmpty
            ? 'No valid Play Billing plans found for $_productId.'
            : 'No valid Play Billing plans found for $_productId. '
                  'Check Play Console offer configuration.',
      );
    }

    return BillingCatalog(plans: plans, loadedAt: DateTime.now());
  }

  @override
  Future<void> buyPlan(
    BillingPlan plan, {
    required String applicationUserName,
  }) async {
    final productDetails = plan.productDetails;
    final purchaseParam = productDetails is GooglePlayProductDetails
        ? GooglePlayPurchaseParam(
            productDetails: productDetails,
            applicationUserName: applicationUserName,
            offerToken: plan.offerToken,
          )
        : PurchaseParam(
            productDetails: productDetails,
            applicationUserName: applicationUserName,
          );
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<List<PurchaseAttempt>> queryOwnedPurchases() async {
    final addition = _inAppPurchase
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final response = await addition.queryPastPurchases();
    if (response.error != null) {
      throw StateError(response.error!.message);
    }

    return response.pastPurchases
        .where((purchase) => purchase.productID == _productId)
        .map(
          (purchase) => PurchaseAttempt(
            productId: purchase.productID,
            basePlanId: null,
            purchaseToken: purchase.verificationData.serverVerificationData,
            purchaseState: purchase.status.name,
            purchaseTime: _parsePurchaseTime(purchase.transactionDate),
          ),
        )
        .toList();
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  BillingPlan _mapPlan(GooglePlayProductDetails details) {
    final offers = details.productDetails.subscriptionOfferDetails;
    if (offers == null || offers.isEmpty) {
      throw StateError(
        'Google Play product ${details.id} is missing subscription offers.',
      );
    }
    final index = details.subscriptionIndex;
    if (index == null || index < 0 || index >= offers.length) {
      throw StateError(
        'Google Play product ${details.id} returned an invalid offer index.',
      );
    }
    final offer = offers[index];
    if (offer.pricingPhases.isEmpty) {
      throw StateError(
        'Google Play product ${details.id} offer ${offer.basePlanId} is missing pricing phases.',
      );
    }
    final offerToken = details.offerToken ?? offer.offerIdToken;
    if (offerToken.isEmpty) {
      throw StateError(
        'Google Play product ${details.id} offer ${offer.basePlanId} is missing an offer token.',
      );
    }
    return BillingPlan(
      productId: details.id,
      basePlanId: offer.basePlanId,
      offerToken: offerToken,
      title: details.title,
      description: details.description,
      priceLabel: details.price,
      currencyCode: details.currencyCode,
      rawPrice: details.rawPrice,
      billingPeriod: _formatPeriod(offer.pricingPhases.first.billingPeriod),
      isHighlighted: offer.basePlanId == _yearlyBasePlanId,
      productDetails: details,
    );
  }

  String _formatPeriod(String value) {
    switch (value) {
      case 'P1Y':
        return 'year';
      case 'P1M':
        return 'month';
      default:
        return value;
    }
  }

  DateTime? _parsePurchaseTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final epoch = int.tryParse(value);
    if (epoch == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }
}

class EntitlementSyncService {
  const EntitlementSyncService({
    required this.client,
    required this.sessionManager,
    required this.subscriptionRepository,
  });

  final BackendApiClient client;
  final BackendSessionManager sessionManager;
  final SubscriptionRepository subscriptionRepository;

  Future<EntitlementSnapshot> loadCachedEntitlement() async {
    final state = await subscriptionRepository.loadSubscription();
    return EntitlementSnapshot.fromSubscriptionState(state);
  }

  Future<EntitlementSnapshot> refreshFromCapabilities() async {
    final response = await client.getAuthorized('/v1/mobile/me/capabilities');
    final snapshot = _parseEntitlement(
      response['entitlement'] as Map<String, dynamic>?,
    );
    await subscriptionRepository.saveSubscription(
      snapshot.toSubscriptionState(),
    );
    return snapshot;
  }

  Future<EntitlementSnapshot> verifyGooglePlayPurchase({
    required PurchaseAttempt attempt,
    required String packageName,
    required String appVersion,
  }) async {
    final installId = await sessionManager.getOrCreateInstallId();
    final response = await client
        .postAuthorized('/v1/billing/google-play/verify', {
          'install_id': installId,
          'product_id': attempt.productId,
          'base_plan_id': attempt.basePlanId,
          'purchase_token': attempt.purchaseToken,
          'package_name': packageName,
          'purchase_state': attempt.purchaseState,
          'purchase_time': attempt.purchaseTime?.toIso8601String(),
          'app_version': appVersion,
        });
    final snapshot = _parseEntitlement(
      response['entitlement'] as Map<String, dynamic>?,
    );
    await subscriptionRepository.saveSubscription(
      snapshot.toSubscriptionState(),
    );
    return snapshot;
  }

  Future<EntitlementSnapshot> restoreGooglePlayPurchases({
    required List<PurchaseAttempt> purchases,
    required String packageName,
    required String appVersion,
  }) async {
    final installId = await sessionManager.getOrCreateInstallId();
    final response = await client.postAuthorized(
      '/v1/billing/google-play/restore',
      {
        'install_id': installId,
        'package_name': packageName,
        'app_version': appVersion,
        'purchases': purchases
            .map(
              (purchase) => {
                'product_id': purchase.productId,
                'base_plan_id': purchase.basePlanId,
                'purchase_token': purchase.purchaseToken,
                'purchase_state': purchase.purchaseState,
                'purchase_time': purchase.purchaseTime?.toIso8601String(),
              },
            )
            .toList(),
      },
    );
    final snapshot = _parseEntitlement(
      response['entitlement'] as Map<String, dynamic>?,
    );
    await subscriptionRepository.saveSubscription(
      snapshot.toSubscriptionState(),
    );
    return snapshot;
  }

  EntitlementSnapshot _parseEntitlement(Map<String, dynamic>? json) {
    if (json == null) {
      return EntitlementSnapshot.free();
    }
    final featureNames = (json['features'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toSet();
    return EntitlementSnapshot(
      isPremium: json['is_premium'] as bool? ?? false,
      features: decodePremiumFeatures(featureNames),
      validUntil: json['valid_until'] == null
          ? null
          : DateTime.tryParse(json['valid_until'].toString()),
      status: json['status']?.toString() ?? 'free',
      productId: json['product_id']?.toString(),
      planId: json['plan_id']?.toString(),
      billingProvider: json['billing_provider']?.toString(),
      lastVerifiedAt: json['last_verified_at'] == null
          ? null
          : DateTime.tryParse(json['last_verified_at'].toString()),
    );
  }
}

class BillingController extends StateNotifier<BillingState> {
  BillingController({
    required BillingService billingService,
    required EntitlementSyncService entitlementSyncService,
    required BackendSessionManager sessionManager,
    required String packageName,
    required String appVersion,
  }) : _billingService = billingService,
       _entitlementSyncService = entitlementSyncService,
       _sessionManager = sessionManager,
       _packageName = packageName,
       _appVersion = appVersion,
       super(const BillingState.idle()) {
    _subscription = _billingService.purchaseStream.listen(
      _handlePurchaseUpdates,
    );
    Future<void>.microtask(initialize);
  }

  final BillingService _billingService;
  final EntitlementSyncService _entitlementSyncService;
  final BackendSessionManager _sessionManager;
  final String _packageName;
  final String _appVersion;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> initialize() async {
    final cached = await _entitlementSyncService.loadCachedEntitlement();
    state = state.copyWith(entitlement: cached);
    try {
      state = state.copyWith(
        status: BillingStatus.loadingProducts,
        clearMessage: true,
      );
      final catalog = await _billingService.loadCatalog();
      EntitlementSnapshot entitlement = cached;
      try {
        entitlement = await _entitlementSyncService.refreshFromCapabilities();
      } catch (_) {}
      state = state.copyWith(
        status: BillingStatus.idle,
        catalog: catalog,
        entitlement: entitlement,
        selectedPlanId: catalog.yearlyPlan?.basePlanId,
        clearMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: BillingStatus.error,
        message: error.toString(),
      );
    }
  }

  Future<void> purchase(BillingPlan plan) async {
    state = state.copyWith(
      status: BillingStatus.purchasing,
      selectedPlanId: plan.basePlanId,
      clearMessage: true,
    );
    try {
      final installId = await _sessionManager.getOrCreateInstallId();
      await _billingService.buyPlan(plan, applicationUserName: installId);
    } catch (error) {
      state = state.copyWith(
        status: BillingStatus.error,
        message: error.toString(),
      );
    }
  }

  Future<void> restore() async {
    state = state.copyWith(status: BillingStatus.restoring, clearMessage: true);
    try {
      final purchases = await _billingService.queryOwnedPurchases();
      final entitlement = await _entitlementSyncService
          .restoreGooglePlayPurchases(
            purchases: purchases,
            packageName: _packageName,
            appVersion: _appVersion,
          );
      state = state.copyWith(
        status: entitlement.isActive
            ? BillingStatus.verified
            : BillingStatus.idle,
        entitlement: entitlement,
        message: entitlement.isActive
            ? 'Purchases restored.'
            : 'No active premium subscription found.',
      );
    } catch (error) {
      state = state.copyWith(
        status: BillingStatus.error,
        message: error.toString(),
      );
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(
            status: BillingStatus.pending,
            message: 'Purchase is pending confirmation.',
          );
          break;
        case PurchaseStatus.canceled:
          state = state.copyWith(
            status: BillingStatus.cancelled,
            message: 'Purchase cancelled.',
          );
          break;
        case PurchaseStatus.error:
          state = state.copyWith(
            status: BillingStatus.error,
            message: purchase.error?.message ?? 'Purchase failed.',
          );
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyPurchase(purchase);
          break;
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      final attempt = PurchaseAttempt(
        productId: purchase.productID,
        basePlanId: _extractBasePlanId(purchase),
        purchaseToken: purchase.verificationData.serverVerificationData,
        purchaseState: purchase.status.name,
        purchaseTime: _parsePurchaseDate(purchase.transactionDate),
      );
      final entitlement = await _entitlementSyncService
          .verifyGooglePlayPurchase(
            attempt: attempt,
            packageName: _packageName,
            appVersion: _appVersion,
          );
      await _billingService.completePurchase(purchase);
      state = state.copyWith(
        status: entitlement.isActive
            ? BillingStatus.verified
            : BillingStatus.idle,
        entitlement: entitlement,
        message: entitlement.isActive
            ? 'Premium unlocked.'
            : 'Purchase verified, but no active entitlement was returned.',
      );
    } catch (error) {
      state = state.copyWith(
        status: BillingStatus.error,
        message: error.toString(),
      );
    }
  }

  String? _extractBasePlanId(PurchaseDetails purchase) {
    if (purchase is GooglePlayPurchaseDetails) {
      return null;
    }
    return null;
  }

  DateTime? _parsePurchaseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final epoch = int.tryParse(value);
    if (epoch == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(epoch);
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
