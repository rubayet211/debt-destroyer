import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../shared/models/ad_models.dart';

class AdMobBootstrap {
  const AdMobBootstrap._();

  static Future<void> initialize(AdMobConfig config) async {
    if (!Platform.isAndroid || !config.enabled || config.androidAppId.isEmpty) {
      return;
    }
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.pg,
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
      ),
    );
    await MobileAds.instance.initialize();
  }
}

abstract class AdSlotRenderer {
  const AdSlotRenderer();

  Widget buildBanner({
    required BuildContext context,
    required AdPlacement placement,
    required AdMobConfig config,
  });
}

class GoogleMobileBannerAdSlotRenderer implements AdSlotRenderer {
  const GoogleMobileBannerAdSlotRenderer();

  @override
  Widget buildBanner({
    required BuildContext context,
    required AdPlacement placement,
    required AdMobConfig config,
  }) {
    return _BannerAdSlot(
      key: ValueKey('banner-slot-${placement.name}'),
      adUnitId: config.androidBannerAdUnitId,
    );
  }
}

class _BannerAdSlot extends StatefulWidget {
  const _BannerAdSlot({super.key, required this.adUnitId});

  final String adUnitId;

  @override
  State<_BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<_BannerAdSlot> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _failedToLoad = false;
  int? _lastWidth;

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.truncate()
            : MediaQuery.sizeOf(context).width.truncate();
        if (width > 0 && width != _lastWidth) {
          _lastWidth = width;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadBanner(width);
            }
          });
        }

        if (_failedToLoad) {
          return const SizedBox.shrink();
        }
        if (!_isLoaded || _bannerAd == null) {
          return const SizedBox(
            height: 56,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return SizedBox(
          height: _bannerAd!.size.height.toDouble(),
          width: _bannerAd!.size.width.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }

  Future<void> _loadBanner(int width) async {
    _bannerAd?.dispose();
    setState(() {
      _bannerAd = null;
      _isLoaded = false;
      _failedToLoad = false;
    });

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (!mounted || size == null) {
      if (mounted) {
        setState(() => _failedToLoad = true);
      }
      return;
    }

    final banner = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _failedToLoad = false;
          });
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (!mounted) {
            return;
          }
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
            _failedToLoad = true;
          });
        },
      ),
    );
    banner.load();
  }
}
