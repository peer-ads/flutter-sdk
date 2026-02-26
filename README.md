# peerads (Flutter)

[![pub version](https://img.shields.io/pub/v/peerads)](https://pub.dev/packages/peerads)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Flutter SDK for [PeerAds](https://peerads.io) — unified ad mediation + peer cross-promotion for iOS and Android Flutter apps.

## Features

- **Peer network** — cross-promote with same-tier apps at zero cost (90 % of slots by default)
- **Paid campaigns** — CPM-bid waterfall fills remaining slots
- **Self network** — falls back to AdMob, AppLovin MAX, Unity Ads, or IronSource
- **Banner, Interstitial, and Rewarded** ad formats
- **Test mode** — isolated sandbox via test API keys

## Requirements

- Flutter ≥ 3.10.0
- Dart SDK ≥ 3.0.0
- iOS 15+ / Android API 21+

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  peerads: ^0.1.0

  # Add only the network SDKs you use (all optional)
  # google_mobile_ads: ^4.0.0
  # applovin_max: ^3.0.0
  # unity_ads_plugin: ^4.0.0
  # ironsource_mediation: ^8.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:peerads/peerads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PeerAds.initialize(PAAdConfig(
    apiKey: 'pk_live_YOUR_KEY',
    networks: {
      'admob': PANetworkConfig(androidAdUnitId: 'ca-app-pub-XXXX/YYYY'),
    },
  ));

  runApp(const MyApp());
}
```

## Ad Formats

### Banner

```dart
import 'package:peerads/peerads.dart';

// In your widget build():
FutureBuilder<PAAdResponse>(
  future: PeerAds.requestAd('banner', 'home_banner'),
  builder: (context, snap) {
    if (!snap.hasData) return const SizedBox.shrink();
    final ad = snap.data!;
    return PABannerWidget(ad: ad);  // built-in widget
  },
)
```

### Interstitial

```dart
// Load before showing (e.g. on level start)
final ad = await PeerAds.loadInterstitial();

// Show at a natural break point
if (mounted) PeerAds.showInterstitial(context, ad);
```

### Rewarded

```dart
final ad = await PeerAds.loadRewarded();

PeerAds.showRewarded(
  context,
  ad,
  onReward: (type, amount) {
    // Grant the reward
    addCoins(amount);
  },
);
```

## Ad Network Adapters

```dart
await PeerAds.initialize(PAAdConfig(
  apiKey: 'pk_live_...',
  networks: {
    'admob': PANetworkConfig(
      androidAdUnitId: 'ca-app-pub-XXXX/YYYY',
      iosAdUnitId:     'ca-app-pub-XXXX/ZZZZ',
    ),
    'applovin': PANetworkConfig(sdkKey: 'YOUR_APPLOVIN_KEY'),
    'unity': PANetworkConfig(
      androidAdUnitId: 'UNITY_ANDROID_GAME_ID',
      iosAdUnitId:     'UNITY_IOS_GAME_ID',
    ),
    'ironsource': PANetworkConfig(appKey: 'YOUR_IS_APP_KEY'),
  },
));
```

> **Note:** Meta Audience Network does not have an official Flutter SDK and is not supported.

## DAU Reporting

Report from your **server** using the secret key (never include `secretKey` in the app bundle).

```dart
// Server-side Dart only
await PeerAds.reportDau(15000);
```

## Test Mode

```dart
await PeerAds.initialize(PAAdConfig(
  apiKey:     'pk_live_...',
  testApiKey: 'pk_test_...',
  environment: PAEnvironment.test,
));
```

## API Reference

| Method | Description |
|--------|-------------|
| `PeerAds.initialize(config)` | Initialize the SDK. Call before `runApp()`. |
| `PeerAds.requestAd(type, slotId)` | Fetch an ad from the server. |
| `PeerAds.track(adId, event)` | Track `'impression'`, `'click'`, or `'install'`. |
| `PeerAds.loadInterstitial()` | Pre-load an interstitial. Returns `PAAdResponse`. |
| `PeerAds.showInterstitial(context, ad)` | Show a pre-loaded interstitial. |
| `PeerAds.loadRewarded()` | Pre-load a rewarded video. |
| `PeerAds.showRewarded(context, ad, onReward?)` | Show a pre-loaded rewarded video. |
| `PeerAds.reportDau(dau)` | Report DAU (server-side, secret key required). |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security

See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE) © PeerAds
