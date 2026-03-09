import '../enums/app_enums.dart';

class UserPreferences {
  const UserPreferences({
    required this.themeMode,
    required this.currencyCode,
    required this.localeCode,
    required this.defaultStrategy,
    required this.hideBalances,
    required this.appLockEnabled,
    required this.aiConsentEnabled,
    required this.relockTimeout,
    required this.screenshotProtectionEnabled,
    required this.privacyShieldOnAppSwitcherEnabled,
    required this.notificationsEnabled,
    required this.onboardingCompleted,
    required this.weeklySummaryEnabled,
    required this.rawOcrRetentionEnabled,
    required this.rawOcrRetentionHours,
    required this.documentRetentionMode,
    required this.purgeFailedImportsAfterHours,
    required this.dataProtectionExplainerSeen,
  });

  factory UserPreferences.defaults() => const UserPreferences(
    themeMode: ThemePreference.system,
    currencyCode: 'USD',
    localeCode: 'en_US',
    defaultStrategy: StrategyType.avalanche,
    hideBalances: false,
    appLockEnabled: false,
    aiConsentEnabled: false,
    relockTimeout: AppRelockTimeout.seconds30,
    screenshotProtectionEnabled: true,
    privacyShieldOnAppSwitcherEnabled: true,
    notificationsEnabled: true,
    onboardingCompleted: false,
    weeklySummaryEnabled: false,
    rawOcrRetentionEnabled: false,
    rawOcrRetentionHours: 0,
    documentRetentionMode: DocumentRetentionMode.days30,
    purgeFailedImportsAfterHours: 24,
    dataProtectionExplainerSeen: false,
  );

  final ThemePreference themeMode;
  final String currencyCode;
  final String localeCode;
  final StrategyType defaultStrategy;
  final bool hideBalances;
  final bool appLockEnabled;
  final bool aiConsentEnabled;
  final AppRelockTimeout relockTimeout;
  final bool screenshotProtectionEnabled;
  final bool privacyShieldOnAppSwitcherEnabled;
  final bool notificationsEnabled;
  final bool onboardingCompleted;
  final bool weeklySummaryEnabled;
  final bool rawOcrRetentionEnabled;
  final int rawOcrRetentionHours;
  final DocumentRetentionMode documentRetentionMode;
  final int purgeFailedImportsAfterHours;
  final bool dataProtectionExplainerSeen;

  UserPreferences copyWith({
    ThemePreference? themeMode,
    String? currencyCode,
    String? localeCode,
    StrategyType? defaultStrategy,
    bool? hideBalances,
    bool? appLockEnabled,
    bool? aiConsentEnabled,
    AppRelockTimeout? relockTimeout,
    bool? screenshotProtectionEnabled,
    bool? privacyShieldOnAppSwitcherEnabled,
    bool? notificationsEnabled,
    bool? onboardingCompleted,
    bool? weeklySummaryEnabled,
    bool? rawOcrRetentionEnabled,
    int? rawOcrRetentionHours,
    DocumentRetentionMode? documentRetentionMode,
    int? purgeFailedImportsAfterHours,
    bool? dataProtectionExplainerSeen,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      currencyCode: currencyCode ?? this.currencyCode,
      localeCode: localeCode ?? this.localeCode,
      defaultStrategy: defaultStrategy ?? this.defaultStrategy,
      hideBalances: hideBalances ?? this.hideBalances,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      aiConsentEnabled: aiConsentEnabled ?? this.aiConsentEnabled,
      relockTimeout: relockTimeout ?? this.relockTimeout,
      screenshotProtectionEnabled:
          screenshotProtectionEnabled ?? this.screenshotProtectionEnabled,
      privacyShieldOnAppSwitcherEnabled:
          privacyShieldOnAppSwitcherEnabled ??
          this.privacyShieldOnAppSwitcherEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      rawOcrRetentionEnabled:
          rawOcrRetentionEnabled ?? this.rawOcrRetentionEnabled,
      rawOcrRetentionHours: rawOcrRetentionHours ?? this.rawOcrRetentionHours,
      documentRetentionMode:
          documentRetentionMode ?? this.documentRetentionMode,
      purgeFailedImportsAfterHours:
          purgeFailedImportsAfterHours ?? this.purgeFailedImportsAfterHours,
      dataProtectionExplainerSeen:
          dataProtectionExplainerSeen ?? this.dataProtectionExplainerSeen,
    );
  }
}
