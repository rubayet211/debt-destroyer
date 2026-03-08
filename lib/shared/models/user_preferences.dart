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
    required this.notificationsEnabled,
    required this.onboardingCompleted,
    required this.weeklySummaryEnabled,
  });

  factory UserPreferences.defaults() => const UserPreferences(
    themeMode: ThemePreference.system,
    currencyCode: 'USD',
    localeCode: 'en_US',
    defaultStrategy: StrategyType.avalanche,
    hideBalances: false,
    appLockEnabled: false,
    aiConsentEnabled: false,
    notificationsEnabled: true,
    onboardingCompleted: false,
    weeklySummaryEnabled: false,
  );

  final ThemePreference themeMode;
  final String currencyCode;
  final String localeCode;
  final StrategyType defaultStrategy;
  final bool hideBalances;
  final bool appLockEnabled;
  final bool aiConsentEnabled;
  final bool notificationsEnabled;
  final bool onboardingCompleted;
  final bool weeklySummaryEnabled;

  UserPreferences copyWith({
    ThemePreference? themeMode,
    String? currencyCode,
    String? localeCode,
    StrategyType? defaultStrategy,
    bool? hideBalances,
    bool? appLockEnabled,
    bool? aiConsentEnabled,
    bool? notificationsEnabled,
    bool? onboardingCompleted,
    bool? weeklySummaryEnabled,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      currencyCode: currencyCode ?? this.currencyCode,
      localeCode: localeCode ?? this.localeCode,
      defaultStrategy: defaultStrategy ?? this.defaultStrategy,
      hideBalances: hideBalances ?? this.hideBalances,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      aiConsentEnabled: aiConsentEnabled ?? this.aiConsentEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
    );
  }
}
