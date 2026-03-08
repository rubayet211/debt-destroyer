import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/subscription_state.dart';
import '../../../shared/models/user_preferences.dart';
import '../../../shared/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences =
        ref.watch(userPreferencesProvider).valueOrNull ??
        UserPreferences.defaults();
    final subscription =
        ref.watch(subscriptionStateProvider).valueOrNull ??
        SubscriptionState.free();

    return AppPage(
      title: 'Settings',
      child: ListView(
        children: [
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Premium status'),
              subtitle: Text(
                subscription.isPremium ? 'Premium active' : 'Free plan',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/premium'),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                _SettingsRow(
                  label: 'Theme',
                  value: preferences.themeMode.name,
                  onTap: () => _showThemeSheet(context, ref, preferences),
                ),
                _SettingsRow(
                  label: 'Currency',
                  value: preferences.currencyCode,
                  onTap: () => _showCurrencySheet(context, ref, preferences),
                ),
                _SettingsRow(
                  label: 'Default payoff strategy',
                  value: preferences.defaultStrategy.name,
                  onTap: () => _showStrategySheet(context, ref, preferences),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                _SettingsRow(
                  label: 'Notifications',
                  value: preferences.notificationsEnabled
                      ? 'Enabled'
                      : 'Disabled',
                  onTap: () => context.push('/notifications'),
                ),
                _SettingsRow(
                  label: 'Security & privacy',
                  value: 'App lock, balance privacy, AI consent',
                  onTap: () => context.push('/security'),
                ),
                _SettingsRow(
                  label: 'Reports',
                  value: 'Charts and export',
                  onTap: () => context.push('/reports'),
                ),
                _SettingsRow(
                  label: 'Help & about',
                  value: 'Privacy, OCR, AI, roadmap',
                  onTap: () => context.push('/help'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Seed demo data'),
                  subtitle: const Text(
                    'Fill the app with realistic sample debts for local testing.',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () async {
                      await ref.read(seedDemoDataProvider)();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demo data added')),
                        );
                      }
                    },
                    child: const Text('Seed'),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Export CSV'),
                  subtitle: const Text(
                    'Premium-gated export for payments and debts.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/reports'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showThemeSheet(
    BuildContext context,
    WidgetRef ref,
    UserPreferences preferences,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: ThemePreference.values.map((theme) {
            return ListTile(
              title: Text(theme.name),
              onTap: () async {
                await ref
                    .read(preferencesRepositoryProvider)
                    .savePreferences(preferences.copyWith(themeMode: theme));
                if (context.mounted) {
                  context.pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _showCurrencySheet(
    BuildContext context,
    WidgetRef ref,
    UserPreferences preferences,
  ) {
    const currencies = ['USD', 'EUR', 'GBP', 'BDT'];
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: currencies.map((currency) {
            return ListTile(
              title: Text(currency),
              onTap: () async {
                await ref
                    .read(preferencesRepositoryProvider)
                    .savePreferences(
                      preferences.copyWith(currencyCode: currency),
                    );
                if (context.mounted) {
                  context.pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _showStrategySheet(
    BuildContext context,
    WidgetRef ref,
    UserPreferences preferences,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: StrategyType.values.map((strategy) {
            return ListTile(
              title: Text(strategy.name),
              onTap: () async {
                await ref
                    .read(preferencesRepositoryProvider)
                    .savePreferences(
                      preferences.copyWith(defaultStrategy: strategy),
                    );
                if (context.mounted) {
                  context.pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences =
        ref.watch(userPreferencesProvider).valueOrNull ??
        UserPreferences.defaults();
    return AppPage(
      title: 'Notifications',
      child: ListView(
        children: [
          SwitchListTile.adaptive(
            value: preferences.notificationsEnabled,
            title: const Text('Due date notifications'),
            subtitle: const Text(
              'Send reminders before due dates and on due day.',
            ),
            onChanged: (value) async {
              if (value) {
                await ref.read(reminderSchedulerProvider).requestPermission();
              }
              await ref
                  .read(preferencesRepositoryProvider)
                  .savePreferences(
                    preferences.copyWith(notificationsEnabled: value),
                  );
            },
          ),
          SwitchListTile.adaptive(
            value: preferences.weeklySummaryEnabled,
            title: const Text('Weekly progress summary'),
            subtitle: const Text(
              'Reserved for milestone and weekly summary reminders.',
            ),
            onChanged: (value) async {
              await ref
                  .read(preferencesRepositoryProvider)
                  .savePreferences(
                    preferences.copyWith(weeklySummaryEnabled: value),
                  );
            },
          ),
        ],
      ),
    );
  }
}

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription =
        ref.watch(subscriptionStateProvider).valueOrNull ??
        SubscriptionState.free();
    final unlocked = PremiumFeature.values
        .where((feature) => subscription.hasFeature(feature))
        .map((feature) => feature.name)
        .join(', ');
    return AppPage(
      title: 'Premium',
      child: ListView(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade for unlimited scanning and advanced payoff planning',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Premium unlocks PDF parsing, advanced reports, scenario saving, and export.',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(subscriptionRepositoryProvider)
                        .saveSubscription(
                          const SubscriptionState(
                            isPremium: true,
                            expiresAt: null,
                            unlockedFeatures: {
                              PremiumFeature.unlimitedScans,
                              PremiumFeature.pdfImport,
                              PremiumFeature.advancedReports,
                              PremiumFeature.csvExport,
                              PremiumFeature.scenarioSaving,
                              PremiumFeature.advancedStrategyComparison,
                            },
                          ),
                        );
                  },
                  child: Text(
                    subscription.isPremium
                        ? 'Premium active'
                        : 'Enable local premium demo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current unlocks'),
                const SizedBox(height: 8),
                Text(unlocked.isEmpty ? 'None yet' : unlocked),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityPrivacyScreen extends ConsumerWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences =
        ref.watch(userPreferencesProvider).valueOrNull ??
        UserPreferences.defaults();
    return AppPage(
      title: 'Security & privacy',
      child: ListView(
        children: [
          SwitchListTile.adaptive(
            value: preferences.appLockEnabled,
            title: const Text('App lock'),
            subtitle: const Text(
              'Require biometric or device authentication before viewing data.',
            ),
            onChanged: (value) async {
              await ref
                  .read(preferencesRepositoryProvider)
                  .savePreferences(preferences.copyWith(appLockEnabled: value));
            },
          ),
          SwitchListTile.adaptive(
            value: preferences.hideBalances,
            title: const Text('Hide balances on screen'),
            subtitle: const Text('Mask balances in dashboards and debt lists.'),
            onChanged: (value) async {
              await ref
                  .read(preferencesRepositoryProvider)
                  .savePreferences(preferences.copyWith(hideBalances: value));
            },
          ),
          SwitchListTile.adaptive(
            value: preferences.aiConsentEnabled,
            title: const Text('Allow cloud AI parsing'),
            subtitle: const Text(
              'This is still confirmed on each import; local OCR remains available.',
            ),
            onChanged: (value) async {
              await ref
                  .read(preferencesRepositoryProvider)
                  .savePreferences(
                    preferences.copyWith(aiConsentEnabled: value),
                  );
            },
          ),
          const SizedBox(height: 12),
          const AppCard(
            child: Text(
              'Imported screenshots are stored locally. Nothing is uploaded silently. You can delete imported documents from debt detail flows.',
            ),
          ),
        ],
      ),
    );
  }
}

class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Help & about',
      child: SingleChildScrollView(
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DEBT DESTROYER'),
              SizedBox(height: 12),
              Text(
                'Privacy-first debt tracking with local storage, on-device OCR, and optional cloud AI parsing.',
              ),
              SizedBox(height: 12),
              Text(
                'Manual fallback is always available if OCR or AI extraction fails.',
              ),
              SizedBox(height: 12),
              Text(
                'Roadmap: billing integration, encrypted backups, household mode, and richer statement parsing.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
