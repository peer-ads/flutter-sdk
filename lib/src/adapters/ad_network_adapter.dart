import 'package:flutter/widgets.dart';

/// Base interface every ad-network adapter must implement.
abstract class AdNetworkAdapter {
  /// Initialize the network SDK. Called once from PeerAds.initialize().
  Future<void> initialize(Map<String, String> config);

  /// Return a Flutter Widget that renders a banner ad, or null if unsupported.
  Widget? buildBanner({required String adUnitId, double width = 320, double height = 50});

  /// Pre-load an interstitial ad.
  Future<void> loadInterstitial(String adUnitId);

  /// Display a pre-loaded interstitial (must be called after loadInterstitial).
  void showInterstitial(BuildContext context);

  /// Pre-load a rewarded ad.
  Future<void> loadRewarded(String adUnitId);

  /// Display a pre-loaded rewarded ad and fire [onReward] on completion.
  void showRewarded(BuildContext context, {void Function(String type, int amount)? onReward});

  bool get isInterstitialReady;
  bool get isRewardedReady;
}
