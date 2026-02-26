## 0.1.0

- Initial release of the PeerAds Flutter SDK.
- `PeerAds.initialize()` — SDK initialisation with `PAAdConfig` (live/test key pairs, environment, networks).
- `PeerAds.requestAd()` — fetch a `PAAdResponse` from the mediation server.
- `PeerAds.track()` — fire `impression`, `click`, and `install` events.
- `PeerAds.loadInterstitial()` / `showInterstitial()` — pre-load and display interstitial ads.
- `PeerAds.loadRewarded()` / `showRewarded()` — pre-load and display rewarded video ads with `onReward` callback.
- `PeerAds.reportDau()` — DAU reporting via secret key (server-side only).
- `PABannerWidget` — drop-in Flutter widget for banner ads.
- `AdapterManager` — delegates ad load/show to installed network SDKs.
- Optional network adapters: `google_mobile_ads`, `applovin_max`, `unity_ads_plugin`, `ironsource_mediation`.
- `PAEnvironment.test` mode with `testApiKey` and visual `[TEST]` label.
- Supports iOS 15+ and Android API 21+.
