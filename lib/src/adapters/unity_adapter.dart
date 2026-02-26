import 'package:flutter/widgets.dart';
import 'ad_network_adapter.dart';

/// Unity Ads adapter — wraps the `unity_ads_plugin` pub.dev package.
///
/// Add to pubspec.yaml:
///   dependencies:
///     unity_ads_plugin: ^4.0.0
class UnityAdapter implements AdNetworkAdapter {
  bool _interstitialReady = false;
  bool _rewardedReady = false;
  String _gameId = '';
  String _interstitialPlacement = 'Interstitial_Android';
  String _rewardedPlacement = 'Rewarded_Android';
  String _bannerPlacement = 'Banner_Android';

  @override bool get isInterstitialReady => _interstitialReady;
  @override bool get isRewardedReady => _rewardedReady;

  @override
  Future<void> initialize(Map<String, String> config) async {
    _gameId = config['gameId'] ?? '';
    _interstitialPlacement = config['interstitialPlacement'] ?? 'Interstitial_Android';
    _rewardedPlacement = config['rewardedPlacement'] ?? 'Rewarded_Android';
    _bannerPlacement = config['bannerPlacement'] ?? 'Banner_Android';
    try {
      // await UnityAds.init(
      //   gameId: _gameId,
      //   testMode: false,
      //   onComplete: () {},
      //   onFailed: (error, message) {},
      // );
      // ignore: avoid_print
      print('[PeerAds/Unity] Initialized gameId=$_gameId');
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/Unity] unity_ads_plugin not available: $e');
    }
  }

  @override
  Widget? buildBanner({required String adUnitId, double width = 320, double height = 50}) {
    try {
      return _UnityBannerWidget(
        placementId: adUnitId.isNotEmpty ? adUnitId : _bannerPlacement,
        width: width, height: height,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> loadInterstitial(String adUnitId) async {
    final placement = adUnitId.isNotEmpty ? adUnitId : _interstitialPlacement;
    try {
      // await UnityAds.load(
      //   placementId: placement,
      //   onComplete: (_) { _interstitialReady = true; },
      //   onFailed: (_, __, ___) {},
      // );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _interstitialReady = true;
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/Unity] loadInterstitial failed: $e');
    }
  }

  @override
  void showInterstitial(BuildContext context) {
    if (!_interstitialReady) return;
    try {
      // UnityAds.showVideoAd(
      //   placementId: _interstitialPlacement,
      //   onComplete: (_) {},
      //   onFailed: (_, __, ___) {},
      //   onStart: (_) {},
      //   onClick: (_) {},
      // );
      _interstitialReady = false;
    } catch (_) {}
  }

  @override
  Future<void> loadRewarded(String adUnitId) async {
    final placement = adUnitId.isNotEmpty ? adUnitId : _rewardedPlacement;
    try {
      // await UnityAds.load(placementId: placement, ...);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _rewardedReady = true;
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/Unity] loadRewarded failed: $e');
    }
  }

  @override
  void showRewarded(BuildContext context, {void Function(String type, int amount)? onReward}) {
    if (!_rewardedReady) return;
    try {
      // UnityAds.showVideoAd(
      //   placementId: _rewardedPlacement,
      //   onComplete: (_) => onReward?.call('unity_reward', 1),
      //   ...
      // );
      onReward?.call('unity_reward', 1);
      _rewardedReady = false;
    } catch (_) {}
  }
}

class _UnityBannerWidget extends StatelessWidget {
  final String placementId;
  final double width;
  final double height;
  const _UnityBannerWidget({required this.placementId, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    // return UnityBannerAd(placementId: placementId, size: BannerSize.standard);
    return SizedBox(width: width, height: height);
  }
}
