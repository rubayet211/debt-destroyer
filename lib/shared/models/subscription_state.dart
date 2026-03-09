import '../enums/app_enums.dart';

class SubscriptionState {
  const SubscriptionState({
    required this.isPremium,
    required this.expiresAt,
    required this.unlockedFeatures,
    this.productId,
    this.planId,
    this.billingProvider,
    this.status,
    this.lastVerifiedAt,
  });

  factory SubscriptionState.free() => const SubscriptionState(
    isPremium: false,
    expiresAt: null,
    unlockedFeatures: {},
    status: 'free',
  );

  final bool isPremium;
  final DateTime? expiresAt;
  final Set<PremiumFeature> unlockedFeatures;
  final String? productId;
  final String? planId;
  final String? billingProvider;
  final String? status;
  final DateTime? lastVerifiedAt;

  DateTime? get validUntil => expiresAt;

  bool get isActive {
    if (!isPremium) {
      return false;
    }
    return validUntil == null || validUntil!.isAfter(DateTime.now());
  }

  bool hasFeature(PremiumFeature feature) {
    return isActive && unlockedFeatures.contains(feature);
  }

  SubscriptionState copyWith({
    bool? isPremium,
    DateTime? expiresAt,
    Set<PremiumFeature>? unlockedFeatures,
    String? productId,
    String? planId,
    String? billingProvider,
    String? status,
    DateTime? lastVerifiedAt,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      expiresAt: expiresAt ?? this.expiresAt,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
      productId: productId ?? this.productId,
      planId: planId ?? this.planId,
      billingProvider: billingProvider ?? this.billingProvider,
      status: status ?? this.status,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
    );
  }
}
