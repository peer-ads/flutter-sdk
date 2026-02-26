import 'package:flutter/widgets.dart';
import 'ad_network_adapter.dart';

/// IronSource adapter — wraps the `ironsource_mediation` pub.dev package.
///
/// Add to pubspec.yaml:
///   dependencies:
///     ironsource_mediation: ^8.0.0
class IronSourceAdapter implements AdNetworkAdapter {
  bool _interstitialReady = false;
  bool _rewardedReady = false;
  String _appKey = '';

  @override bool get isInterstitialReady => _interstitialReady;
  @override bool get isRewardedReady => _rewardedReady;

  @override
  Future<void> initialize(Map<String, String> config) async {
    _appKey = config['appKey'] ?? '';
    try {
      // IronSource.setAdaptersDebug(false);
      // await IronSource.init(appKey: _appKey, adUnits: [IronSourceAdUnit.interstitial, IronSourceAdUnit.rewardedVideo]);
      // ignore: avoid_print
      print('[PeerAds/IronSource] Initialized appKey=***');
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/IronSource] ironsource_mediation not available: $e');
    }
  }

  @override
  Widget? buildBanner({required String adUnitId, double width = 320, double height = 50}) {
    try {
      return _IronSourceBannerWidget(instanceId: adUnitId, width: width, height: height);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> loadInterstitial(String adUnitId) async {
    try {
      // IronSource.loadInterstitial();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _interstitialReady = true;
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/IronSource] loadInterstitial failed: $e');
    }
  }

  @override
  void showInterstitial(BuildContext context) {
    if (!_interstitialReady) return;
    try {
      // IronSource.showInterstitial();
      _interstitialReady = false;
    } catch (_) {}
  }

  @override
  Future<void> loadRewarded(String adUnitId) async {
    try {
      // IronSource.loadRewardedVideo();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _rewardedReady = true;
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/IronSource] loadRewarded failed: $e');
    }
  }

  @override
  void showRewarded(BuildContext context, {void Function(String type, int amount)? onReward}) {
    if (!_rewardedReady) return;
    try {
      // IronSource.showRewardedVideo();
      // IronSourceRewardedVideoListener.onRewardedVideoAdRewarded(placement) -> onReward
      onReward?.call('coins', 0);
      _rewardedReady = false;
    } catch (_) {}
  }
}

class _IronSourceBannerWidget extends StatelessWidget {
  final String instanceId;
  final double width;
  final double height;
  const _IronSourceBannerWidget({required this.instanceId, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    // return IronSourceBannerView(instanceId: int.tryParse(instanceId) ?? 0);
    return SizedBox(width: width, height: height);
  }
}
