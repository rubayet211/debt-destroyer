import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/core/services/ad_services.dart';
import 'package:debt_destroyer/core/widgets/monetization_widgets.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/ad_models.dart';
import 'package:debt_destroyer/shared/models/subscription_state.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

void main() {
  testWidgets('free users can see configured banner slots', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionStateProvider.overrideWith(
            (ref) => Stream.value(SubscriptionState.free()),
          ),
          adMobConfigProvider.overrideWithValue(
            const AdMobConfig(
              enabled: true,
              testMode: true,
              androidAppId: 'test-app-id',
              androidBannerAdUnitId: 'test-banner-id',
              androidInterstitialAdUnitId: 'test-interstitial-id',
            ),
          ),
          adSlotRendererProvider.overrideWithValue(const _FakeAdSlotRenderer()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PremiumAwareBannerAdSlot(placement: AdPlacement.dashboard),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('fake-banner-dashboard')), findsOneWidget);
  });

  testWidgets('premium users never see banner slots', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionStateProvider.overrideWith(
            (ref) => Stream.value(
              SubscriptionState(
                isPremium: true,
                expiresAt: DateTime.now().add(const Duration(days: 30)),
                unlockedFeatures: const {PremiumFeature.pdfImport},
                status: 'active',
              ),
            ),
          ),
          adMobConfigProvider.overrideWithValue(
            const AdMobConfig(
              enabled: true,
              testMode: true,
              androidAppId: 'test-app-id',
              androidBannerAdUnitId: 'test-banner-id',
              androidInterstitialAdUnitId: 'test-interstitial-id',
            ),
          ),
          adSlotRendererProvider.overrideWithValue(const _FakeAdSlotRenderer()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PremiumAwareBannerAdSlot(placement: AdPlacement.dashboard),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('fake-banner-dashboard')), findsNothing);
  });

  testWidgets('disabled ad config hides banner slots safely', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionStateProvider.overrideWith(
            (ref) => Stream.value(SubscriptionState.free()),
          ),
          adMobConfigProvider.overrideWithValue(
            const AdMobConfig(
              enabled: false,
              testMode: true,
              androidAppId: '',
              androidBannerAdUnitId: '',
              androidInterstitialAdUnitId: '',
            ),
          ),
          adSlotRendererProvider.overrideWithValue(const _FakeAdSlotRenderer()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PremiumAwareBannerAdSlot(placement: AdPlacement.dashboard),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SizedBox), findsWidgets);
    expect(find.byKey(const Key('fake-banner-dashboard')), findsNothing);
  });
}

class _FakeAdSlotRenderer implements AdSlotRenderer {
  const _FakeAdSlotRenderer();

  @override
  Widget buildBanner({
    required BuildContext context,
    required AdPlacement placement,
    required AdMobConfig config,
  }) {
    return Container(key: Key('fake-banner-${placement.name}'));
  }
}
