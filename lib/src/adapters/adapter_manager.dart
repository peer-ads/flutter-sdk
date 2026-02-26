import 'package:flutter/widgets.dart';
import 'ad_network_adapter.dart';
import 'admob_adapter.dart';
import 'meta_adapter.dart';
import 'applovin_adapter.dart';
import 'unity_adapter.dart';
import 'ironsource_adapter.dart';

/// Routes ad rendering to the correct third-party adapter based on the
/// `network` string returned by the PeerAds server in `source: 'self'` responses.
class AdapterManager {
  final Map<String, AdNetworkAdapter> _adapters = {};

  AdNetworkAdapter _getOrCreate(String name) {
    return _adapters.putIfAbsent(name, () {
      switch (name) {
        case 'admob': return AdMobAdapter();
        case 'meta': return MetaAdapter();
        case 'applovin': return AppLovinAdapter();
        case 'unity': return UnityAdapter();
        case 'ironsource': return IronSourceAdapter();
        default: return AdMobAdapter(); // fallback
      }
    });
  }

  Future<void> initializeAll(Map<String, Map<String, String>> networksConfig) async {
    await Future.wait(
      networksConfig.entries.map((e) => _getOrCreate(e.key).initialize(e.value)),
    );
  }

  Widget? buildBanner(String network, {required String adUnitId, double width = 320, double height = 50}) {
    return _getOrCreate(network).buildBanner(adUnitId: adUnitId, width: width, height: height);
  }

  Future<void> loadInterstitial(String network, String adUnitId) {
    return _getOrCreate(network).loadInterstitial(adUnitId);
  }

  void showInterstitial(String network, BuildContext context) {
    _getOrCreate(network).showInterstitial(context);
  }

  Future<void> loadRewarded(String network, String adUnitId) {
    return _getOrCreate(network).loadRewarded(adUnitId);
  }

  void showRewarded(String network, BuildContext context, {void Function(String, int)? onReward}) {
    _getOrCreate(network).showRewarded(context, onReward: onReward);
  }

  bool isInterstitialReady(String network) => _adapters[network]?.isInterstitialReady ?? false;
  bool isRewardedReady(String network) => _adapters[network]?.isRewardedReady ?? false;
}
