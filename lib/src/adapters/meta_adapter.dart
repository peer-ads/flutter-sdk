import 'package:flutter/widgets.dart';
import 'ad_network_adapter.dart';

/// Meta Audience Network adapter.
/// Meta officially deprecated their Flutter SDK.
/// This adapter is a graceful stub that logs a warning and returns null widgets.
class MetaAdapter implements AdNetworkAdapter {
  @override bool get isInterstitialReady => false;
  @override bool get isRewardedReady => false;

  @override
  Future<void> initialize(Map<String, String> config) async {
    // ignore: avoid_print
    print('[PeerAds/Meta] Meta Audience Network does not have an official Flutter SDK. '
        'Ads assigned to Meta will fall back to PeerAds peer/bid creative.');
  }

  @override
  Widget? buildBanner({required String adUnitId, double width = 320, double height = 50}) => null;

  @override
  Future<void> loadInterstitial(String adUnitId) async {}

  @override
  void showInterstitial(BuildContext context) {}

  @override
  Future<void> loadRewarded(String adUnitId) async {}

  @override
  void showRewarded(BuildContext context, {void Function(String type, int amount)? onReward}) {}
}
