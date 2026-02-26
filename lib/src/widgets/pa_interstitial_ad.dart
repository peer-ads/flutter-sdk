import 'package:flutter/material.dart';
import '../peerads_sdk.dart';

class PAInterstitialAd {
  Map<String, dynamic>? _ad;

  Future<void> load() async {
    _ad = await PeerAds.requestAd('interstitial', 'interstitial');
  }

  Future<void> show(BuildContext context, {VoidCallback? onDismissed}) async {
    assert(_ad != null, '[PeerAds] Call load() before show()');
    PeerAds.track(_ad!['id'] as String, 'impression');

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _InterstitialDialog(
        ad: _ad!,
        onDismissed: onDismissed,
      ),
    );
  }
}

class _InterstitialDialog extends StatelessWidget {
  final Map<String, dynamic> ad;
  final VoidCallback? onDismissed;

  const _InterstitialDialog({required this.ad, this.onDismissed});

  @override
  Widget build(BuildContext context) {
    final creative = ad['creative'] as Map<String, dynamic>;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  PeerAds.track(ad['id'] as String, 'close');
                  Navigator.pop(context);
                  onDismissed?.call();
                },
              ),
            ),
            Text(creative['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            if (creative['description'] != null)
              Text(creative['description'] as String, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
              onPressed: () => PeerAds.track(ad['id'] as String, 'click'),
              child: Text(creative['ctaText'] as String? ?? 'Learn More', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
