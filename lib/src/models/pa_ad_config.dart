enum PAEnvironment { test, production }

class PAAdConfig {
  /// Live public key: pk_live_... — embed in production app
  final String apiKey;
  /// Live secret key: sk_live_... — server-side only, never ship in app bundle
  final String? secretKey;
  /// Test public key: pk_test_... — embed in dev/staging app
  final String? testApiKey;
  /// Test secret key: sk_test_... — server-side only
  final String? testSecretKey;
  /// [PAEnvironment.test] uses pk_test_ key and returns mock ads.
  final PAEnvironment environment;

  final String apiUrl;
  final int peerPromotionPercent;
  final bool testMode;
  final Map<String, Map<String, String>> networks;

  const PAAdConfig({
    required this.apiKey,
    this.secretKey,
    this.testApiKey,
    this.testSecretKey,
    this.environment = PAEnvironment.production,
    this.apiUrl = 'https://api.peerads.io/api/v1',
    this.peerPromotionPercent = 90,
    this.testMode = false,
    this.networks = const {},
  });

  /// The API key to use for ad requests based on [environment].
  String get activeApiKey {
    if (environment == PAEnvironment.test) {
      assert(testApiKey != null, '[PeerAds] testApiKey required when environment is test');
      return testApiKey!;
    }
    return apiKey;
  }

  /// The secret key to use for privileged server-to-server calls.
  String? get activeSecretKey =>
      environment == PAEnvironment.test ? testSecretKey : secretKey;
}
