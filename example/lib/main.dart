/// PeerAds Flutter SDK — Demo App
///
/// Demonstrates: Banner, Interstitial, Rewarded ads + DAU reporting.
///
/// Run:
///   cd example
///   flutter pub get
///   flutter run

import 'package:flutter/material.dart';
import 'package:peerads/peerads.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialise SDK (once, before runApp)
  await PeerAds.initialize(
    PAAdConfig(
      apiKey: 'pk_test_REPLACE_ME', // ← replace with your test key
      environment: PAEnvironment.test,
      testMode: true,
      peerPromotionPercent: 90,
    ),
  );

  runApp(const PeerAdsDemoApp());
}

// ---------------------------------------------------------------------------
// App shell
// ---------------------------------------------------------------------------
class PeerAdsDemoApp extends StatelessWidget {
  const PeerAdsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeerAds Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6366F1),
        useMaterial3: true,
      ),
      home: const DemoHome(),
    );
  }
}

// ---------------------------------------------------------------------------
// Main screen with bottom nav
// ---------------------------------------------------------------------------
class DemoHome extends StatefulWidget {
  const DemoHome({super.key});

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    _BannerPage(),
    _InterstitialPage(),
    _RewardedPage(),
    _SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.view_agenda), label: 'Banner'),
          NavigationDestination(icon: Icon(Icons.fullscreen), label: 'Interstitial'),
          NavigationDestination(icon: Icon(Icons.card_giftcard), label: 'Rewarded'),
          NavigationDestination(icon: Icon(Icons.info_outline), label: 'Info'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1 — Banner Ads
// ---------------------------------------------------------------------------
class _BannerPage extends StatefulWidget {
  const _BannerPage();

  @override
  State<_BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<_BannerPage> {
  PAAdSize _size = PAAdSize.banner;
  final List<String> _log = [];

  void _addLog(String msg) => setState(() => _log.insert(0, msg));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner Ad')),
      body: Column(
        children: [
          // Size selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<PAAdSize>(
              segments: const [
                ButtonSegment(value: PAAdSize.banner,          label: Text('320×50')),
                ButtonSegment(value: PAAdSize.largeBanner,     label: Text('320×100')),
                ButtonSegment(value: PAAdSize.mediumRectangle, label: Text('300×250')),
              ],
              selected: {_size},
              onSelectionChanged: (s) => setState(() => _size = s.first),
            ),
          ),

          // Banner widget
          PABannerAd(
            size: _size,
            onAdLoaded:         () => _addLog('✅ Banner loaded (${_size.name})'),
            onAdFailedToLoad: (e) => _addLog('❌ Banner error: $e'),
            onAdClicked:         () => _addLog('👆 Banner clicked'),
          ),

          // Log
          Expanded(child: _LogView(entries: _log)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 2 — Interstitial Ad
// ---------------------------------------------------------------------------
class _InterstitialPage extends StatefulWidget {
  const _InterstitialPage();

  @override
  State<_InterstitialPage> createState() => _InterstitialPageState();
}

class _InterstitialPageState extends State<_InterstitialPage> {
  PAInterstitialAd? _ad;
  bool _loading = false;
  bool _ready   = false;
  final List<String> _log = [];

  void _addLog(String msg) => setState(() => _log.insert(0, msg));

  Future<void> _load() async {
    setState(() { _loading = true; _ready = false; });
    try {
      _ad = PAInterstitialAd();
      await _ad!.load();
      setState(() => _ready = true);
      _addLog('✅ Interstitial ready');
    } catch (e) {
      _addLog('❌ Load error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _show() async {
    if (_ad == null) return;
    try {
      await _ad!.show(context, onDismissed: () => _addLog('ℹ️ Interstitial dismissed'));
      setState(() => _ready = false); // consumed
    } catch (e) {
      _addLog('❌ Show error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interstitial Ad')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Interstitial ads cover the full screen. Preload the ad, then show it at a '
              'natural break point (e.g. between game levels).',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _loading ? null : _load,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download),
              label: const Text('Preload Interstitial'),
            ),

            const SizedBox(height: 12),

            FilledButton.tonal(
              onPressed: _ready ? _show : null,
              child: const Text('Show Interstitial'),
            ),

            const Divider(height: 32),
            Expanded(child: _LogView(entries: _log)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 3 — Rewarded Ad
// ---------------------------------------------------------------------------
class _RewardedPage extends StatefulWidget {
  const _RewardedPage();

  @override
  State<_RewardedPage> createState() => _RewardedPageState();
}

class _RewardedPageState extends State<_RewardedPage> {
  bool _loading = false;
  int  _coins   = 0;
  final List<String> _log = [];

  void _addLog(String msg) => setState(() => _log.insert(0, msg));

  Future<void> _watchAd() async {
    setState(() => _loading = true);
    try {
      final ad = await PeerAds.loadRewarded();
      _addLog('✅ Rewarded loaded  source=${ad.source}');
      PeerAds.showRewarded(
        context,
        ad,
        onReward: (type, amount) {
          setState(() => _coins += amount);
          _addLog('🎁 Reward: +$amount $type (total: $_coins)');
        },
      );
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewarded Ad')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Coin display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFFF59E0B), size: 32),
                  const SizedBox(width: 12),
                  Text('$_coins coins',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Tap the button to watch a rewarded ad. The SDK loads a peer/bid/self ad '
              'and triggers onReward when the user completes viewing.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _loading ? null : _watchAd,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.play_circle_outline),
              label: const Text('Watch Rewarded Ad (+10 coins)'),
            ),

            const Divider(height: 32),
            Expanded(child: _LogView(entries: _log)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 4 — SDK Info / DAU reporting
// ---------------------------------------------------------------------------
class _SettingsPage extends StatefulWidget {
  const _SettingsPage();

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool _dauReported = false;
  final List<String> _log = [];

  void _addLog(String msg) => setState(() => _log.insert(0, msg));

  Future<void> _reportDau() async {
    try {
      await PeerAds.reportDau(5000);
      setState(() => _dauReported = true);
      _addLog('✅ DAU reported: 5 000');
    } catch (e) {
      _addLog('❌ DAU error: $e');
    }
  }

  Future<void> _manualRequest() async {
    try {
      final ad = await PeerAds.requestAd('banner', 'slot-001');
      _addLog('✅ Ad: source=${ad.source} network=${ad.network} id=${ad.id}');
      PeerAds.track(ad.id, 'impression');
      _addLog('ℹ️ Impression tracked');
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SDK Info')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoTile('SDK Version', '0.1.0'),
            _InfoTile('Environment', PeerAds.environment.name),
            _InfoTile('Peer %', '${PeerAds.config.peerPromotionPercent}%'),
            const Divider(height: 24),

            FilledButton.icon(
              onPressed: _dauReported ? null : _reportDau,
              icon: Icon(_dauReported ? Icons.check : Icons.bar_chart),
              label: Text(_dauReported ? 'DAU Reported ✓' : 'Report DAU (5 000)'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _manualRequest,
              icon: const Icon(Icons.ads_click),
              label: const Text('Manual Ad Request'),
            ),

            const Divider(height: 24),
            Expanded(child: _LogView(entries: _log)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------
class _InfoTile extends StatelessWidget {
  const _InfoTile(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,  style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LogView extends StatelessWidget {
  const _LogView({required this.entries});
  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('No events yet', style: TextStyle(color: Colors.grey)));
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (_, i) => Text(
          entries[i],
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: entries[i].startsWith('❌')
                ? const Color(0xFFF87171)
                : entries[i].startsWith('✅') || entries[i].startsWith('🎁')
                    ? const Color(0xFF34D399)
                    : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
