import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/ad_models.dart';
import '../../shared/providers/app_providers.dart';

class PremiumAwareBannerAdSlot extends ConsumerWidget {
  const PremiumAwareBannerAdSlot({
    super.key,
    required this.placement,
    this.margin = const EdgeInsets.only(top: 16),
  });

  final AdPlacement placement;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionStateProvider);
    final subscription = subscriptionState.valueOrNull;
    final config = ref.watch(adMobConfigProvider);
    if (subscription == null ||
        subscription.isActive ||
        !config.isReadyForBanners ||
        !config.allowsPlacement(placement)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: margin,
      child: ref
          .watch(adSlotRendererProvider)
          .buildBanner(context: context, placement: placement, config: config),
    );
  }
}

Future<void> showPremiumUpsellSheet(
  BuildContext context, {
  required String title,
  required String message,
  String primaryActionLabel = 'View premium plans',
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.push('/premium');
              },
              icon: const Icon(Icons.workspace_premium_outlined),
              label: Text(primaryActionLabel),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.push('/premium');
              },
              child: const Text('Restore existing purchase'),
            ),
          ],
        ),
      ),
    ),
  );
}
