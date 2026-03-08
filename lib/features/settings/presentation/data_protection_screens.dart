import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../shared/providers/app_providers.dart';

class PrivacyUpgradeScreen extends ConsumerWidget {
  const PrivacyUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppPage(
      title: 'Local protection upgraded',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your local debt data is now encrypted',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const AppCard(
            child: Text(
              'Balances, imported source documents, and retained OCR text are now protected with device-bound encryption. Deletion is best effort on mobile flash storage and may not guarantee forensic erasure.',
            ),
          ),
          const SizedBox(height: 16),
          const AppCard(
            child: Text(
              'Raw OCR text is no longer kept by default after review. You can change retention and purge settings later from Security & privacy.',
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () async {
              final bootstrap = ref.read(
                dataProtectionBootstrapServiceProvider,
              );
              await bootstrap.acknowledgeUpgradeExplainer();
              if (context.mounted) {
                context.go('/dashboard');
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class DataProtectionRecoveryScreen extends ConsumerWidget {
  const DataProtectionRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataProtectionBootstrapProvider);
    final message =
        state.valueOrNull?.errorMessage ??
        'Secure local storage could not be initialized.';
    return AppPage(
      title: 'Secure storage issue',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppErrorState(message: message),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ref.invalidate(dataProtectionBootstrapProvider);
              context.go('/');
            },
            child: const Text('Retry migration'),
          ),
        ],
      ),
    );
  }
}
