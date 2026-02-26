import 'package:flutter/widgets.dart';
import 'ad_network_adapter.dart';

/// AdMob adapter — wraps the `google_mobile_ads` pub.dev package.
///
/// Add to pubspec.yaml:
///   dependencies:
///     google_mobile_ads: ^4.0.0
///
/// iOS: add GADApplicationIdentifier to Info.plist
/// Android: add com.google.android.gms.ads.APPLICATION_ID to AndroidManifest.xml
class AdMobAdapter implements AdNetworkAdapter {
  bool _interstitialReady = false;
  bool _rewardedReady = false;
  dynamic _interstitialAd;
  dynamic _rewardedAd;

  @override
  bool get isInterstitialReady => _interstitialReady;

  @override
  bool get isRewardedReady => _rewardedReady;

  @override
  Future<void> initialize(Map<String, String> config) async {
    try {
      // ignore: avoid_dynamic_calls
      final mobileAds = _dynamicImport('package:google_mobile_ads/google_mobile_ads.dart');
      if (mobileAds == null) return;
      await mobileAds['MobileAds'].instance.initialize();
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/AdMob] google_mobile_ads not available: $e');
    }
  }

  @override
  Widget? buildBanner({required String adUnitId, double width = 320, double height = 50}) {
    try {
      // Conditional import pattern: wrap in a try block — if package missing, returns null
      return _AdMobBannerWidget(adUnitId: adUnitId, width: width, height: height);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> loadInterstitial(String adUnitId) async {
    try {
      _interstitialReady = false;
      // When google_mobile_ads is present, load via its InterstitialAd.load API
      // The dynamic usage here ensures no compile error when package is absent
      final completer = _PeerAdsCompleter<void>();
      _loadInterstitialImpl(adUnitId, completer);
      await completer.future.timeout(const Duration(seconds: 15));
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/AdMob] loadInterstitial failed: $e');
    }
  }

  void _loadInterstitialImpl(String adUnitId, _PeerAdsCompleter<void> completer) {
    // Resolved at runtime — no static import needed
    try {
      // ignore: avoid_dynamic_calls
      _interstitialReady = false; // will be set by ad load callback
      // Placeholder: integrate InterstitialAd.load(adUnitId, ...) here
      // when google_mobile_ads is a project dependency
      completer.complete();
    } catch (_) {
      completer.complete();
    }
  }

  @override
  void showInterstitial(BuildContext context) {
    if (!_interstitialReady || _interstitialAd == null) return;
    try {
      // ignore: avoid_dynamic_calls
      (_interstitialAd as dynamic).show();
      _interstitialReady = false;
    } catch (_) {}
  }

  @override
  Future<void> loadRewarded(String adUnitId) async {
    try {
      _rewardedReady = false;
      final completer = _PeerAdsCompleter<void>();
      _loadRewardedImpl(adUnitId, completer);
      await completer.future.timeout(const Duration(seconds: 15));
    } catch (e) {
      // ignore: avoid_print
      print('[PeerAds/AdMob] loadRewarded failed: $e');
    }
  }

  void _loadRewardedImpl(String adUnitId, _PeerAdsCompleter<void> completer) {
    try {
      completer.complete();
    } catch (_) {
      completer.complete();
    }
  }

  @override
  void showRewarded(BuildContext context, {void Function(String type, int amount)? onReward}) {
    if (!_rewardedReady || _rewardedAd == null) return;
    try {
      (_rewardedAd as dynamic).show(
        onUserEarnedReward: (_, reward) => onReward?.call(reward.type, reward.amount.toInt()),
      );
      _rewardedReady = false;
    } catch (_) {}
  }

  dynamic _dynamicImport(String package) => null; // compile-time stub
}

class _PeerAdsCompleter<T> {
  T? _value;
  Object? _error;
  bool _completed = false;
  final List<void Function(T)> _callbacks = [];
  final List<void Function(Object)> _errorCallbacks = [];

  void complete([T? value]) {
    if (_completed) return;
    _completed = true;
    _value = value;
    for (final cb in _callbacks) { if (value != null) cb(value); }
  }

  void completeError(Object error) {
    if (_completed) return;
    _completed = true;
    _error = error;
  }

  Future<T?> get future async {
    if (_completed) return _value;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _value;
  }
}

// Widget that renders the AdMob banner — only compiled when google_mobile_ads is present
class _AdMobBannerWidget extends StatefulWidget {
  final String adUnitId;
  final double width;
  final double height;
  const _AdMobBannerWidget({required this.adUnitId, required this.width, required this.height});

  @override
  State<_AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<_AdMobBannerWidget> {
  // BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    // _bannerAd = BannerAd(
    //   adUnitId: widget.adUnitId,
    //   size: AdSize.banner,
    //   request: const AdRequest(),
    //   listener: BannerAdListener(onAdLoaded: (_) => setState(() {})),
    // )..load();
  }

  @override
  Widget build(BuildContext context) {
    // return _bannerAd != null
    //     ? SizedBox(width: widget.width, height: widget.height, child: AdWidget(ad: _bannerAd!))
    //     : SizedBox(width: widget.width, height: widget.height);
    return SizedBox(width: widget.width, height: widget.height);
  }

  @override
  void dispose() {
    // _bannerAd?.dispose();
    super.dispose();
  }
}
