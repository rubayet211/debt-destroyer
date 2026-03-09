import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/models/billing_models.dart';
import '../../../shared/models/subscription_state.dart';
import '../../../shared/models/user_preferences.dart';
import '../../../shared/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entitlementRefreshProvider);
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
                subscription.isActive
                    ? 'Premium ${subscription.planId ?? ''}'.trim()
                    : 'Free plan',
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
    final permission = ref.watch(notificationPermissionProvider).valueOrNull;
    return AppPage(
      title: 'Notifications',
      child: ListView(
        children: [
          if (permission == false)
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notifications_off_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notification permission is currently denied. Enable it in system settings to receive reminders.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          if (permission == false) const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: preferences.notificationsEnabled,
            title: const Text('Notifications'),
            subtitle: const Text(
              'Master switch for reminders, summaries, and milestones.',
            ),
            onChanged: (value) async {
              if (value) {
                await ref.read(reminderSchedulerProvider).requestPermission();
                ref.invalidate(notificationPermissionProvider);
              }
              await ref
                  .read(preferencesRepositoryProvider)
                  .savePreferences(
                    preferences.copyWith(notificationsEnabled: value),
                  );
            },
          ),
          SwitchListTile.adaptive(
            value: preferences.dueRemindersEnabled,
            title: const Text('Due reminders'),
            subtitle: Text(
              'Notify ${preferences.dueReminderLeadDays} day${preferences.dueReminderLeadDays == 1 ? '' : 's'} before due dates and again on due day.',
            ),
            onChanged: preferences.notificationsEnabled
                ? (value) async {
                    if (value) {
                      await ref
                          .read(reminderSchedulerProvider)
                          .requestPermission();
                      ref.invalidate(notificationPermissionProvider);
                    }
                    await ref
                        .read(preferencesRepositoryProvider)
                        .savePreferences(
                          preferences.copyWith(dueRemindersEnabled: value),
                        );
                  }
                : null,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text('Lead time'),
            subtitle: Text(
              '${preferences.dueReminderLeadDays} day${preferences.dueReminderLeadDays == 1 ? '' : 's'} before due date',
            ),
            trailing: DropdownButton<int>(
              value: preferences.dueReminderLeadDays.clamp(1, 3),
              onChanged:
                  preferences.notificationsEnabled &&
                      preferences.dueRemindersEnabled
                  ? (value) async {
                      if (value == null) {
                        return;
                      }
                      await ref
                          .read(preferencesRepositoryProvider)
                          .savePreferences(
                            preferences.copyWith(dueReminderLeadDays: value),
                          );
                    }
                  : null,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 day')),
                DropdownMenuItem(value: 2, child: Text('2 days')),
                DropdownMenuItem(value: 3, child: Text('3 days')),
              ],
            ),
          ),
          SwitchListTile.adaptive(
            value: preferences.overdueRemindersEnabled,
            title: const Text('Overdue reminders'),
            subtitle: const Text(
              'Send follow-up reminders on days 1, 3, and 7 after a missed due date.',
            ),
            onChanged: preferences.notificationsEnabled
                ? (value) async {
                    if (value) {
                      await ref
                          .read(reminderSchedulerProvider)
                          .requestPermission();
                      ref.invalidate(notificationPermissionProvider);
                    }
                    await ref
                        .read(preferencesRepositoryProvider)
                        .savePreferences(
                          preferences.copyWith(overdueRemindersEnabled: value),
                        );
                  }
                : null,
          ),
          SwitchListTile.adaptive(
            value: preferences.milestoneNotificationsEnabled,
            title: const Text('Milestone notifications'),
            subtitle: const Text(
              'Celebrate 25%, 50%, 75%, and fully paid-off progress once.',
            ),
            onChanged: preferences.notificationsEnabled
                ? (value) async {
                    if (value) {
                      await ref
                          .read(reminderSchedulerProvider)
                          .requestPermission();
                      ref.invalidate(notificationPermissionProvider);
                    }
                    await ref
                        .read(preferencesRepositoryProvider)
                        .savePreferences(
                          preferences.copyWith(
                            milestoneNotificationsEnabled: value,
                          ),
                        );
                  }
                : null,
          ),
          SwitchListTile.adaptive(
            value: preferences.weeklySummaryEnabled,
            title: const Text('Weekly progress summary'),
            subtitle: const Text(
              'Monday morning overview of upcoming dues and recent payment momentum.',
            ),
            onChanged: preferences.notificationsEnabled
                ? (value) async {
                    if (value) {
                      await ref
                          .read(reminderSchedulerProvider)
                          .requestPermission();
                      ref.invalidate(notificationPermissionProvider);
                    }
                    await ref
                        .read(preferencesRepositoryProvider)
                        .savePreferences(
                          preferences.copyWith(weeklySummaryEnabled: value),
                        );
                  }
                : null,
          ),
          if (preferences.notificationsEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Reminder content stays concise for lock-screen privacy. Reboot behavior may vary by device until the app is opened again.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
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
    ref.watch(entitlementRefreshProvider);
    final subscription =
        ref.watch(subscriptionStateProvider).valueOrNull ??
        SubscriptionState.free();
    final billingState = ref.watch(billingControllerProvider);
    final unlocked = PremiumFeature.values
        .where((feature) => subscription.hasFeature(feature))
        .map((feature) => feature.name)
        .join(', ');
    final yearly = billingState.catalog?.yearlyPlan;
    final monthly = billingState.catalog?.monthlyPlan;
    final actionBusy =
        billingState.status == BillingStatus.purchasing ||
        billingState.status == BillingStatus.pending ||
        billingState.status == BillingStatus.restoring;
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
                  'Premium unlocks PDF parsing, advanced reports, scenario saving, export, and unlimited secure scans.',
                ),
                const SizedBox(height: 16),
                if (billingState.message != null) ...[
                  Text(billingState.message!),
                  const SizedBox(height: 12),
                ],
                if (yearly != null)
                  _PlanTile(
                    title: 'Yearly',
                    subtitle: '${yearly.priceLabel} / ${yearly.billingPeriod}',
                    highlighted: true,
                    enabled: !actionBusy,
                    onPressed: subscription.isActive
                        ? null
                        : () => ref
                              .read(billingControllerProvider.notifier)
                              .purchase(yearly),
                  ),
                if (monthly != null) ...[
                  const SizedBox(height: 12),
                  _PlanTile(
                    title: 'Monthly',
                    subtitle:
                        '${monthly.priceLabel} / ${monthly.billingPeriod}',
                    highlighted: false,
                    enabled: !actionBusy,
                    onPressed: subscription.isActive
                        ? null
                        : () => ref
                              .read(billingControllerProvider.notifier)
                              .purchase(monthly),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: actionBusy
                      ? null
                      : () => ref
                            .read(billingControllerProvider.notifier)
                            .restore(),
                  child: const Text('Restore purchases'),
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
                if (subscription.validUntil != null) ...[
                  const SizedBox(height: 8),
                  Text('Valid until ${subscription.validUntil}'),
                ],
                if (subscription.status != null) ...[
                  const SizedBox(height: 8),
                  Text('Status: ${subscription.status}'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Subscriptions are managed by Google Play.'),
                SizedBox(height: 8),
                Text(
                  'New purchases and restores require backend verification before premium access is granted.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.title,
    required this.subtitle,
    required this.highlighted,
    required this.enabled,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final bool highlighted;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          FilledButton(
            onPressed: enabled ? onPressed : null,
            child: Text(highlighted ? 'Best value' : 'Choose'),
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
    final protection = ref.watch(dataProtectionBootstrapProvider).valueOrNull;
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
            onChanged: (value) =>
                _toggleAppLock(context, ref, preferences, value),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Relock timeout'),
            subtitle: Text(_relockLabel(preferences.relockTimeout)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRelockSheet(context, ref, preferences),
          ),
          SwitchListTile.adaptive(
            value: preferences.screenshotProtectionEnabled,
            title: const Text('Screenshot protection'),
            subtitle: const Text(
              'Block screenshots and recents previews on sensitive screens.',
            ),
            onChanged: (value) async {
              await ref
                  .read(preferencesRepositoryProvider)
                  .savePreferences(
                    preferences.copyWith(screenshotProtectionEnabled: value),
                  );
            },
          ),
          SwitchListTile.adaptive(
            value: preferences.privacyShieldOnAppSwitcherEnabled,
            title: const Text('Privacy shield in app switcher'),
            subtitle: const Text(
              'Obscure content when the app moves to the background.',
            ),
            onChanged: (value) async {
              await ref
                  .read(preferencesRepositoryProvider)
                  .savePreferences(
                    preferences.copyWith(
                      privacyShieldOnAppSwitcherEnabled: value,
                    ),
                  );
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
            title: const Text('Allow secure cloud extraction'),
            subtitle: const Text(
              'This is still confirmed on each import; local OCR remains available without backend access.',
            ),
            onChanged: (value) async {
              await ref
                  .read(preferencesRepositoryProvider)
                  .savePreferences(
                    preferences.copyWith(aiConsentEnabled: value),
                  );
            },
          ),
          SwitchListTile.adaptive(
            value: preferences.rawOcrRetentionEnabled,
            title: const Text('Temporarily retain OCR text'),
            subtitle: Text(
              preferences.rawOcrRetentionEnabled
                  ? 'OCR text is kept for ${preferences.rawOcrRetentionHours} hour(s) after review.'
                  : 'OCR text is removed after review by default.',
            ),
            onChanged: (value) async {
              await ref
                  .read(preferencesRepositoryProvider)
                  .savePreferences(
                    preferences.copyWith(
                      rawOcrRetentionEnabled: value,
                      rawOcrRetentionHours: value ? 24 : 0,
                    ),
                  );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Source document retention'),
            subtitle: Text(switch (preferences.documentRetentionMode) {
              DocumentRetentionMode.days7 => 'Auto-purge after 7 days',
              DocumentRetentionMode.days30 => 'Auto-purge after 30 days',
              DocumentRetentionMode.manual => 'Keep until manually deleted',
            }),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRetentionSheet(context, ref, preferences),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Purge saved OCR text now'),
            subtitle: const Text(
              'Remove retained OCR text from local storage.',
            ),
            trailing: FilledButton.tonal(
              onPressed: () async {
                await ref.read(documentsRepositoryProvider).purgeAllRawOcr();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stored OCR text removed')),
                  );
                }
              },
              child: const Text('Purge'),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Purge all imported documents now'),
            subtitle: const Text(
              'Best-effort removal of encrypted source files and metadata.',
            ),
            trailing: FilledButton.tonal(
              onPressed: () async {
                await ref.read(documentsRepositoryProvider).purgeAllDocuments();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Imported documents purged')),
                  );
                }
              },
              child: const Text('Purge'),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  protection?.statusMessage ?? 'Checking local protection...',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Imported screenshots stay local unless you explicitly allow secure server-side extraction for a single import. Nothing is uploaded silently. Deletion is best effort on device flash storage.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAppLock(
    BuildContext context,
    WidgetRef ref,
    UserPreferences preferences,
    bool value,
  ) async {
    if (!value) {
      final updated = preferences.copyWith(appLockEnabled: false);
      await ref.read(preferencesRepositoryProvider).savePreferences(updated);
      await ref
          .read(appSecurityCoordinatorProvider.notifier)
          .syncPreferences(updated);
      return;
    }
    final authResult = await ref
        .read(appSecurityCoordinatorProvider.notifier)
        .unlock();
    if (!context.mounted) {
      return;
    }
    if (!authResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authResult.message ??
                'Authentication is required before app lock can be enabled.',
          ),
        ),
      );
      return;
    }
    final updated = preferences.copyWith(appLockEnabled: true);
    await ref.read(preferencesRepositoryProvider).savePreferences(updated);
    await ref
        .read(appSecurityCoordinatorProvider.notifier)
        .syncPreferences(updated);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('App lock enabled')));
    }
  }

  String _relockLabel(AppRelockTimeout timeout) {
    return switch (timeout) {
      AppRelockTimeout.immediate => 'Lock immediately after backgrounding',
      AppRelockTimeout.seconds30 => 'Lock after 30 seconds',
      AppRelockTimeout.minutes5 => 'Lock after 5 minutes',
    };
  }

  Future<void> _showRelockSheet(
    BuildContext context,
    WidgetRef ref,
    UserPreferences preferences,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: AppRelockTimeout.values.map((timeout) {
            return ListTile(
              title: Text(_relockLabel(timeout)),
              onTap: () async {
                await ref
                    .read(preferencesRepositoryProvider)
                    .savePreferences(
                      preferences.copyWith(relockTimeout: timeout),
                    );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _showRetentionSheet(
    BuildContext context,
    WidgetRef ref,
    UserPreferences preferences,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: DocumentRetentionMode.values.map((mode) {
            final label = switch (mode) {
              DocumentRetentionMode.days7 => 'Delete after 7 days',
              DocumentRetentionMode.days30 => 'Delete after 30 days',
              DocumentRetentionMode.manual => 'Keep until manual delete',
            };
            return ListTile(
              title: Text(label),
              onTap: () async {
                await ref
                    .read(preferencesRepositoryProvider)
                    .savePreferences(
                      preferences.copyWith(documentRetentionMode: mode),
                    );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
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
                'Privacy-first debt tracking with local storage, on-device OCR, and optional secure server-side extraction.',
              ),
              SizedBox(height: 12),
              Text(
                'Manual fallback is always available if OCR or AI extraction fails.',
              ),
              SizedBox(height: 12),
              Text(
                'Roadmap: encrypted backups, household mode, and richer statement parsing.',
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
