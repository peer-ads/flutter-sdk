import 'package:flutter/material.dart';
import '../peerads_sdk.dart';
import '../models/pa_ad_size.dart';

class PABannerAd extends StatefulWidget {
  final PAAdSize size;
  final VoidCallback? onAdLoaded;
  final void Function(String error)? onAdFailedToLoad;
  final VoidCallback? onAdClicked;

  const PABannerAd({
    super.key,
    this.size = PAAdSize.banner,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
  });

  @override
  State<PABannerAd> createState() => _PABannerAdState();
}

class _PABannerAdState extends State<PABannerAd> {
  Map<String, dynamic>? _ad;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    try {
      final ad = await PeerAds.requestAd('banner', 'banner');
      setState(() { _ad = ad; _loading = false; });
      PeerAds.track(ad['id'] as String, 'impression');
      widget.onAdLoaded?.call();
    } catch (e) {
      setState(() => _loading = false);
      widget.onAdFailedToLoad?.call(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width.toDouble(),
      height: widget.size.height.toDouble(),
      child: _loading
          ? const ColoredBox(color: Color(0xFFF3F4F6))
          : _ad == null
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: () {
                    PeerAds.track(_ad!['id'] as String, 'click');
                    widget.onAdClicked?.call();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE0E7FF)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (_ad!['creative'] as Map)['title'] as String,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF4338CA), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
    );
  }
}
