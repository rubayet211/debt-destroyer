enum AdPlacement { dashboard, debtsList, reports }

class AdMobConfig {
  const AdMobConfig({
    required this.enabled,
    required this.testMode,
    required this.androidAppId,
    required this.androidBannerAdUnitId,
    required this.androidInterstitialAdUnitId,
  });

  factory AdMobConfig.fromEnvironment(Map<String, String> env) {
    return AdMobConfig(
      enabled: _parseBool(env['ADMOB_ENABLED'], fallback: false),
      testMode: _parseBool(env['ADMOB_TEST_MODE'], fallback: true),
      androidAppId: env['ADMOB_ANDROID_APP_ID'] ?? '',
      androidBannerAdUnitId: env['ADMOB_ANDROID_BANNER_AD_UNIT_ID'] ?? '',
      androidInterstitialAdUnitId:
          env['ADMOB_ANDROID_INTERSTITIAL_AD_UNIT_ID'] ?? '',
    );
  }

  final bool enabled;
  final bool testMode;
  final String androidAppId;
  final String androidBannerAdUnitId;
  final String androidInterstitialAdUnitId;

  bool get isReadyForBanners =>
      enabled && androidAppId.isNotEmpty && androidBannerAdUnitId.isNotEmpty;

  bool allowsPlacement(AdPlacement placement) {
    return switch (placement) {
      AdPlacement.dashboard ||
      AdPlacement.debtsList ||
      AdPlacement.reports => true,
    };
  }

  static bool _parseBool(String? value, {required bool fallback}) {
    switch (value?.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'on':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'off':
        return false;
      default:
        return fallback;
    }
  }
}
