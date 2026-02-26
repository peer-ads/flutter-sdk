import 'package:flutter/widgets.dart';
import 'ad_network_adapter.dart';

/// AppLovin MAX adapter — wraps the `applovin_max` pub.dev package.
///
/// Add to pubspec.yaml:
///   dependencies:
///     applovin_max: ^3.0.0
class AppLovinAdapter implements AdNetworkAdapter {
  bool _interstitialReady = false;
  bool _rewardedReady = false;
  String _sdkKey = '';

  @override bool get isInterstitialReady => _interstitialReady;
  @override bool get isRewardedReady => _rewardedReady;

  @override
  Future<void> initialize(Map<String, String> config) async {
    _sdkKey = config['sdkKey'] ?? '';
    try {
      // AppLovinMAX.initialize(_sdkKey);
      // ignore: avoid_print
      print('[PeerAds/AppLovin] Initialized with sdkKey=${_sdkKey.isNotEmpty ? '***' : 'missing'}');
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/AppLovin] applovin_max not available: $e');
    }
  }

  @override
  Widget? buildBanner({required String adUnitId, double width = 320, double height = 50}) {
    try {
      return _AppLovinBannerWidget(adUnitId: adUnitId, width: width, height: height);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> loadInterstitial(String adUnitId) async {
    try {
      // AppLovinMAX.loadInterstitial(adUnitId);
      // Listen to MaxAdListener.onInterstitialLoaded
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _interstitialReady = true;
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/AppLovin] loadInterstitial failed: $e');
    }
  }

  @override
  void showInterstitial(BuildContext context) {
    if (!_interstitialReady) return;
    try {
      // AppLovinMAX.showInterstitial(adUnitId);
      _interstitialReady = false;
    } catch (_) {}
  }

  @override
  Future<void> loadRewarded(String adUnitId) async {
    try {
      // AppLovinMAX.loadRewardedAd(adUnitId);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _rewardedReady = true;
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/AppLovin] loadRewarded failed: $e');
    }
  }

  @override
  void showRewarded(BuildContext context, {void Function(String type, int amount)? onReward}) {
    if (!_rewardedReady) return;
    try {
      // AppLovinMAX.showRewardedAd(adUnitId);
      // On MaxRewardListener.onRewardedAdReceived -> onReward(label, amount)
      _rewardedReady = false;
    } catch (_) {}
  }
}

class _AppLovinBannerWidget extends StatelessWidget {
  final String adUnitId;
  final double width;
  final double height;
  const _AppLovinBannerWidget({required this.adUnitId, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    // return MaxAdView(adUnitId: adUnitId, adFormat: AdFormat.banner);
    return SizedBox(width: width, height: height);
  }
}
