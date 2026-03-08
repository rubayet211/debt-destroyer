import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/app_providers.dart';

class BiometricUnlockScreen extends ConsumerStatefulWidget {
  const BiometricUnlockScreen({super.key});

  @override
  ConsumerState<BiometricUnlockScreen> createState() =>
      _BiometricUnlockScreenState();
}

class _BiometricUnlockScreenState extends ConsumerState<BiometricUnlockScreen> {
  bool _unlocking = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Unlock your ledger',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Use device authentication before financial data is displayed.',
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _unlocking ? null : _unlock,
                icon: const Icon(Icons.fingerprint),
                label: Text(_unlocking ? 'Unlocking...' : 'Unlock'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _unlock() async {
    setState(() {
      _unlocking = true;
      _error = null;
    });
    final success = await ref.read(biometricAuthServiceProvider).authenticate();
    if (mounted) {
      setState(() => _unlocking = false);
      if (success) {
        ref.read(appLockSessionProvider.notifier).state = true;
        context.go('/dashboard');
      } else {
        setState(() => _error = 'Authentication was not completed.');
      }
    }
  }
}
