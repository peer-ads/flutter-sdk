/// Full-screen rewarded ad widget for PeerAds Flutter SDK.
///
/// Renders the shared HTML page in a [WebViewWidget] — the same visual design
/// as all other PeerAds SDK platforms (web, iOS, Android, React Native).
///
/// Behaviour:
/// - Cannot be dismissed (back button / swipe) until the countdown finishes.
/// - Timer pauses/resumes via `window.PAAd.pause/resume()` when the app is
///   backgrounded (via [WidgetsBindingObserver]).
/// - [onRewardAvailable] fires immediately when the timer hits 0.
/// - [onRewardEarned] fires when the user taps "Claim Reward".
///
/// Usage:
/// ```dart
/// await PARewardedAd.show(
///   context,
///   onRewardAvailable: (type, amount) => setState(() => _pending = amount),
///   onRewardEarned:    (type, amount) => setState(() => coins += amount),
/// );
/// ```
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../peerads_sdk.dart';
import 'pa_rewarded_ad_html.dart';

// ── PARewardedAd ──────────────────────────────────────────────────────────────

class PARewardedAd extends StatefulWidget {
  final PAAdResponse ad;
  final int          duration;
  final void Function(String type, int amount)? onRewardAvailable;
  final void Function(String type, int amount)? onRewardEarned;
  final VoidCallback? onAdClosed;

  const PARewardedAd._({
    required this.ad,
    required this.duration,
    this.onRewardAvailable,
    this.onRewardEarned,
    this.onAdClosed,
  });

  /// Load the rewarded ad and push a non-dismissible full-screen route.
  static Future<void> show(
    BuildContext context, {
    int duration = 30,
    void Function(String type, int amount)? onRewardAvailable,
    void Function(String type, int amount)? onRewardEarned,
    VoidCallback? onAdClosed,
  }) async {
    final ad = await PeerAds.loadRewarded();
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque:            true,
        barrierDismissible: false,
        fullscreenDialog:  true,
        pageBuilder: (_, __, ___) => PARewardedAd._(
          ad:               ad,
          duration:         duration,
          onRewardAvailable: onRewardAvailable,
          onRewardEarned:   onRewardEarned,
          onAdClosed:       onAdClosed,
        ),
      ),
    );
  }

  @override
  State<PARewardedAd> createState() => _PARewardedAdState();
}

// ── State ─────────────────────────────────────────────────────────────────────

class _PARewardedAdState extends State<PARewardedAd>
    with WidgetsBindingObserver {

  late final WebViewController _controller;
  bool _eligible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.onAdClosed?.call();
    super.dispose();
  }

  // ── App lifecycle — pause/resume ──────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _controller.runJavaScript('window.PAAd&&window.PAAd.pause();');
      case AppLifecycleState.resumed:
        if (!_eligible) {
          _controller.runJavaScript('window.PAAd&&window.PAAd.resume();');
        }
      case AppLifecycleState.detached:
        break;
    }
  }

  // ── WebView setup ─────────────────────────────────────────────────────────

  void _setupController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
      ..addJavaScriptChannel(
        'PeerAdsChannel',
        onMessageReceived: (msg) => _handleBridgeMessage(msg.message),
      )
      ..loadHtmlString(
        buildRewardedAdHtml(
          adId:        widget.ad.id,
          title:       (widget.ad.creative['title']       as String?) ?? '',
          description: (widget.ad.creative['description'] as String?) ?? '',
          imageUrl:    (widget.ad.creative['imageUrl']    as String?) ?? '',
          duration:    widget.duration,
        ),
      );
  }

  // ── Bridge event handler ──────────────────────────────────────────────────

  void _handleBridgeMessage(String raw) {
    final Map<String, dynamic> msg;
    try {
      msg = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final event = msg['event'] as String? ?? '';
    final data  = msg['data']  as Map<String, dynamic>? ?? {};

    switch (event) {
      case 'impression':
        PeerAds.track(widget.ad.id, 'impression');

      case 'rewardAvailable':
        setState(() => _eligible = true);
        widget.onRewardAvailable?.call(
          data['type']   as String? ?? 'coins',
          data['amount'] as int?    ?? 10,
        );

      case 'rewardEarned':
        PeerAds.track(widget.ad.id, 'complete');
        widget.onRewardEarned?.call(
          data['type']   as String? ?? 'coins',
          data['amount'] as int?    ?? 10,
        );

      case 'closed':
        if (mounted) Navigator.of(context).pop();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => PopScope(
        // Block back/swipe until user is eligible
        canPop: _eligible,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: WebViewWidget(controller: _controller),
          ),
        ),
      );
}
