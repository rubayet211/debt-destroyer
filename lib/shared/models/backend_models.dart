class BackendConfig {
  const BackendConfig({
    required this.baseUrl,
    required this.environment,
    required this.playIntegrityCloudProjectNumber,
    required this.playIntegrityPackageName,
    required this.debugAttestationSecret,
    required this.requestTimeout,
    required this.premiumProductId,
    required this.premiumMonthlyBasePlanId,
    required this.premiumYearlyBasePlanId,
  });

  final String baseUrl;
  final String environment;
  final String? playIntegrityCloudProjectNumber;
  final String playIntegrityPackageName;
  final String? debugAttestationSecret;
  final Duration requestTimeout;
  final String premiumProductId;
  final String premiumMonthlyBasePlanId;
  final String premiumYearlyBasePlanId;

  bool get isConfigured => baseUrl.isNotEmpty;

  BackendConfig copyWith({
    String? baseUrl,
    String? environment,
    String? playIntegrityCloudProjectNumber,
    String? playIntegrityPackageName,
    String? debugAttestationSecret,
    Duration? requestTimeout,
    String? premiumProductId,
    String? premiumMonthlyBasePlanId,
    String? premiumYearlyBasePlanId,
  }) {
    return BackendConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      environment: environment ?? this.environment,
      playIntegrityCloudProjectNumber:
          playIntegrityCloudProjectNumber ??
          this.playIntegrityCloudProjectNumber,
      playIntegrityPackageName:
          playIntegrityPackageName ?? this.playIntegrityPackageName,
      debugAttestationSecret:
          debugAttestationSecret ?? this.debugAttestationSecret,
      requestTimeout: requestTimeout ?? this.requestTimeout,
      premiumProductId: premiumProductId ?? this.premiumProductId,
      premiumMonthlyBasePlanId:
          premiumMonthlyBasePlanId ?? this.premiumMonthlyBasePlanId,
      premiumYearlyBasePlanId:
          premiumYearlyBasePlanId ?? this.premiumYearlyBasePlanId,
    );
  }
}

class InstallSession {
  const InstallSession({
    required this.installId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.attestationStatus,
  });

  final String installId;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String attestationStatus;

  bool get isExpired => expiresAt.isBefore(DateTime.now());
}

class BackendQuotaSnapshot {
  const BackendQuotaSnapshot({
    required this.allowed,
    required this.remainingFreeScans,
    required this.premiumRequired,
    required this.resetAt,
  });

  final bool allowed;
  final int remainingFreeScans;
  final bool premiumRequired;
  final DateTime? resetAt;
}

class BackendEntitlement {
  const BackendEntitlement({
    required this.isPremium,
    required this.planId,
    required this.status,
    required this.validUntil,
    required this.features,
    required this.lastVerifiedAt,
    required this.productId,
    required this.billingProvider,
  });

  final bool isPremium;
  final String? planId;
  final String status;
  final DateTime? validUntil;
  final List<String> features;
  final DateTime? lastVerifiedAt;
  final String? productId;
  final String? billingProvider;
}

class BackendExtractionResponse {
  const BackendExtractionResponse({
    required this.extraction,
    required this.summary,
    required this.lineItems,
    required this.documentSignals,
    required this.warnings,
    required this.quota,
    required this.requestId,
    required this.provider,
    required this.model,
    required this.durationMs,
  });

  final Map<String, dynamic> extraction;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> lineItems;
  final List<String> documentSignals;
  final List<String> warnings;
  final BackendQuotaSnapshot quota;
  final String requestId;
  final String provider;
  final String model;
  final int durationMs;
}

class BackendCapabilities {
  const BackendCapabilities({
    required this.premium,
    required this.features,
    required this.freeScanRemaining,
    required this.rateLimitState,
    required this.entitlement,
  });

  final bool premium;
  final List<String> features;
  final int freeScanRemaining;
  final String rateLimitState;
  final BackendEntitlement? entitlement;
}
