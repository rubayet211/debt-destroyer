class BackendConfig {
  const BackendConfig({
    required this.baseUrl,
    required this.environment,
    required this.playIntegrityProjectNumber,
    required this.debugAttestationSecret,
    required this.requestTimeout,
  });

  final String baseUrl;
  final String environment;
  final String? playIntegrityProjectNumber;
  final String? debugAttestationSecret;
  final Duration requestTimeout;

  bool get isConfigured => baseUrl.isNotEmpty;
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

class BackendExtractionResponse {
  const BackendExtractionResponse({
    required this.extraction,
    required this.warnings,
    required this.quota,
    required this.requestId,
    required this.provider,
    required this.model,
    required this.durationMs,
  });

  final Map<String, dynamic> extraction;
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
  });

  final bool premium;
  final List<String> features;
  final int freeScanRemaining;
  final String rateLimitState;
}
