import 'package:in_app_purchase/in_app_purchase.dart';

import '../enums/app_enums.dart';
import 'subscription_state.dart';

enum BillingStatus {
  idle,
  loadingProducts,
  purchasing,
  pending,
  verified,
  cancelled,
  error,
  restoring,
}

class BillingPlan {
  const BillingPlan({
    required this.productId,
    required this.basePlanId,
    required this.offerToken,
    required this.title,
    required this.description,
    required this.priceLabel,
    required this.currencyCode,
    required this.rawPrice,
    required this.billingPeriod,
    required this.isHighlighted,
    required this.productDetails,
  });

  final String productId;
  final String basePlanId;
  final String offerToken;
  final String title;
  final String description;
  final String priceLabel;
  final String currencyCode;
  final double rawPrice;
  final String billingPeriod;
  final bool isHighlighted;
  final ProductDetails productDetails;
}

class BillingCatalog {
  const BillingCatalog({required this.plans, required this.loadedAt});

  final List<BillingPlan> plans;
  final DateTime loadedAt;

  BillingPlan? get yearlyPlan => _byBasePlan('yearly');
  BillingPlan? get monthlyPlan => _byBasePlan('monthly');

  BillingPlan? _byBasePlan(String value) {
    for (final plan in plans) {
      if (plan.basePlanId == value) {
        return plan;
      }
    }
    return null;
  }
}

class PurchaseAttempt {
  const PurchaseAttempt({
    required this.productId,
    required this.basePlanId,
    required this.purchaseToken,
    required this.purchaseState,
    required this.purchaseTime,
  });

  final String productId;
  final String? basePlanId;
  final String purchaseToken;
  final String purchaseState;
  final DateTime? purchaseTime;
}

class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.isPremium,
    required this.features,
    required this.validUntil,
    required this.status,
    required this.productId,
    required this.planId,
    required this.billingProvider,
    required this.lastVerifiedAt,
  });

  factory EntitlementSnapshot.free() => const EntitlementSnapshot(
    isPremium: false,
    features: {},
    validUntil: null,
    status: 'free',
    productId: null,
    planId: null,
    billingProvider: null,
    lastVerifiedAt: null,
  );

  final bool isPremium;
  final Set<PremiumFeature> features;
  final DateTime? validUntil;
  final String status;
  final String? productId;
  final String? planId;
  final String? billingProvider;
  final DateTime? lastVerifiedAt;

  bool get isActive =>
      isPremium && (validUntil == null || validUntil!.isAfter(DateTime.now()));

  SubscriptionState toSubscriptionState() {
    return SubscriptionState(
      isPremium: isPremium,
      expiresAt: validUntil,
      unlockedFeatures: features,
      productId: productId,
      planId: planId,
      billingProvider: billingProvider,
      status: status,
      lastVerifiedAt: lastVerifiedAt,
    );
  }

  static EntitlementSnapshot fromSubscriptionState(SubscriptionState state) {
    return EntitlementSnapshot(
      isPremium: state.isPremium,
      features: state.unlockedFeatures,
      validUntil: state.validUntil,
      status: state.status ?? 'free',
      productId: state.productId,
      planId: state.planId,
      billingProvider: state.billingProvider,
      lastVerifiedAt: state.lastVerifiedAt,
    );
  }
}

class BillingState {
  const BillingState({
    required this.status,
    required this.catalog,
    required this.entitlement,
    required this.message,
    required this.selectedPlanId,
  });

  const BillingState.idle()
    : status = BillingStatus.idle,
      catalog = null,
      entitlement = null,
      message = null,
      selectedPlanId = null;

  final BillingStatus status;
  final BillingCatalog? catalog;
  final EntitlementSnapshot? entitlement;
  final String? message;
  final String? selectedPlanId;

  BillingState copyWith({
    BillingStatus? status,
    BillingCatalog? catalog,
    EntitlementSnapshot? entitlement,
    String? message,
    String? selectedPlanId,
    bool clearMessage = false,
  }) {
    return BillingState(
      status: status ?? this.status,
      catalog: catalog ?? this.catalog,
      entitlement: entitlement ?? this.entitlement,
      message: clearMessage ? null : (message ?? this.message),
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
    );
  }
}
