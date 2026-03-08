import '../enums/app_enums.dart';

class SubscriptionState {
  const SubscriptionState({
    required this.isPremium,
    required this.expiresAt,
    required this.unlockedFeatures,
  });

  factory SubscriptionState.free() => const SubscriptionState(
    isPremium: false,
    expiresAt: null,
    unlockedFeatures: {},
  );

  final bool isPremium;
  final DateTime? expiresAt;
  final Set<PremiumFeature> unlockedFeatures;

  bool hasFeature(PremiumFeature feature) {
    return isPremium || unlockedFeatures.contains(feature);
  }

  SubscriptionState copyWith({
    bool? isPremium,
    DateTime? expiresAt,
    Set<PremiumFeature>? unlockedFeatures,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      expiresAt: expiresAt ?? this.expiresAt,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
    );
  }
}
