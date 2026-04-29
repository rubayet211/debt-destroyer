import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_services.dart';
import '../../../shared/enums/app_enums.dart';
import '../../../shared/providers/app_providers.dart';

class BiometricUnlockScreen extends StatelessWidget {
  const BiometricUnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const UnlockPane(),
            ),
          ),
        ),
      ),
    );
  }
}

class UnlockPane extends ConsumerStatefulWidget {
  const UnlockPane({super.key, this.onUnlocked, this.isFullscreen = true});

  final VoidCallback? onUnlocked;
  final bool isFullscreen;

  @override
  ConsumerState<UnlockPane> createState() => _UnlockPaneState();
}

class _UnlockPaneState extends ConsumerState<UnlockPane> {
  bool _unlocking = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlock your ledger',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Use biometrics or device credentials before financial data is displayed.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _unlocking ? null : _unlock,
              icon: const Icon(Icons.fingerprint),
              label: Text(_unlocking ? 'Unlocking...' : 'Unlock'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
    return widget.isFullscreen ? Center(child: card) : card;
  }

  Future<void> _unlock() async {
    setState(() {
      _unlocking = true;
      _message = null;
    });
    final result = await ref
        .read(appSecurityCoordinatorProvider.notifier)
        .unlock();
    if (!mounted) {
      return;
    }
    setState(() => _unlocking = false);
    if (result.isSuccess) {
      widget.onUnlocked?.call();
      if (widget.onUnlocked == null && widget.isFullscreen) {
        context.go('/dashboard');
      }
      return;
    }
    setState(() => _message = _messageFor(result));
  }

  String _messageFor(AuthResult result) {
    if (result.message != null && result.message!.isNotEmpty) {
      return result.message!;
    }
    return switch (result.outcome) {
      AuthOutcome.cancelled => 'Authentication was not completed.',
      AuthOutcome.unavailable =>
        'Device authentication is unavailable on this device.',
      AuthOutcome.temporaryLockout =>
        'Authentication is temporarily locked. Try again shortly.',
      AuthOutcome.permanentLockout =>
        'Biometrics are locked. Unlock your device, then return here.',
      AuthOutcome.error => 'Authentication failed.',
      AuthOutcome.success => '',
    };
  }
}
