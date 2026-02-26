import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'models/pa_ad_config.dart';
import 'adapters/adapter_manager.dart';

class PAAdResponse {
  final String id;
  final String type;
  final String source;
  final String network;
  final String adUnitId;
  final Map<String, dynamic> creative;
  final String trackingUrl;
  final String environment; // 'test' | 'live'

  PAAdResponse({
    required this.id,
    required this.type,
    required this.source,
    required this.network,
    required this.adUnitId,
    required this.creative,
    required this.trackingUrl,
    required this.environment,
  });

  factory PAAdResponse.fromJson(Map<String, dynamic> ad, String env) => PAAdResponse(
        id: ad['id'] as String,
        type: ad['type'] as String,
        source: ad['source'] as String,
        network: (ad['network'] as String?) ?? '',
        adUnitId: (ad['adUnitId'] as String?) ?? '',
        creative: (ad['creative'] as Map<String, dynamic>?) ?? {},
        trackingUrl: (ad['trackingUrl'] as String?) ?? '',
        environment: env,
      );
}

class PeerAds {
  static PAAdConfig? _config;
  static AdapterManager? _adapterManager;

  static Future<void> initialize(PAAdConfig config) async {
    _config = config;
    if (config.networks.isNotEmpty) {
      _adapterManager = AdapterManager();
      await _adapterManager!.initializeAll(config.networks);
    }
    if (config.testMode || config.environment == PAEnvironment.test) {
      // ignore: avoid_print
      print('[PeerAds] Initialized (${config.environment.name}) appId: ${config.apiKey}');
    }
  }

  static PAAdConfig get config {
    assert(_config != null, '[PeerAds] Call PeerAds.initialize() before using the SDK');
    return _config!;
  }

  static AdapterManager? get adapterManager => _adapterManager;
  static PAEnvironment get environment => config.environment;

  static Future<PAAdResponse> requestAd(String type, String slotId) async {
    final cfg = config;
    final res = await http.post(
      Uri.parse('${cfg.apiUrl}/ads/serve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'apiKey': cfg.activeApiKey, 'slotType': type, 'platform': 'flutter'}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final env = (body['environment'] as String?) ?? 'live';
    return PAAdResponse.fromJson(body['ad'] as Map<String, dynamic>, env);
  }

  static void track(String adId, String event) {
    http.post(
      Uri.parse('${config.apiUrl}/ads/track'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'adId': adId, 'event': event}),
    ).catchError((_) {});
  }

  /// Report DAU to PeerAds via secret key.
  /// Must be called from your server-side code, not from the Flutter app bundle.
  static Future<void> reportDau(int dau) async {
    final cfg = config;
    final sk = cfg.activeSecretKey;
    assert(sk != null, '[PeerAds] secretKey or testSecretKey required to call reportDau()');
    await http.post(
      Uri.parse('${cfg.apiUrl}/apps/dau'),
      headers: {'Content-Type': 'application/json', 'X-PeerAds-Secret-Key': sk!},
      body: jsonEncode({'dau': dau}),
    );
  }

  static Future<PAAdResponse> loadInterstitial({String adUnitId = ''}) async {
    final ad = await requestAd('interstitial', 'interstitial');
    if (ad.source == 'self' && ad.network.isNotEmpty && _adapterManager != null) {
      await _adapterManager!.loadInterstitial(ad.network, ad.adUnitId.isNotEmpty ? ad.adUnitId : adUnitId);
    }
    return ad;
  }

  static void showInterstitial(BuildContext context, PAAdResponse ad) {
    if (ad.source == 'self' && ad.network.isNotEmpty && _adapterManager != null) {
      _adapterManager!.showInterstitial(ad.network, context);
      track(ad.id, 'impression');
    }
  }

  static Future<PAAdResponse> loadRewarded({String adUnitId = ''}) async {
    final ad = await requestAd('rewarded', 'rewarded');
    if (ad.source == 'self' && ad.network.isNotEmpty && _adapterManager != null) {
      await _adapterManager!.loadRewarded(ad.network, ad.adUnitId.isNotEmpty ? ad.adUnitId : adUnitId);
    }
    return ad;
  }

  static void showRewarded(BuildContext context, PAAdResponse ad, {void Function(String, int)? onReward}) {
    if (ad.source == 'self' && ad.network.isNotEmpty && _adapterManager != null) {
      _adapterManager!.showRewarded(ad.network, context, onReward: onReward);
      track(ad.id, 'impression');
    }
  }
}
