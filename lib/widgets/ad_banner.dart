import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../theme/app_theme.dart';

/// Real AdMob banner ad implementation.
class AdBannerPlaceholder extends StatefulWidget {
  final double height;
  const AdBannerPlaceholder({super.key, this.height = 50});

  @override
  State<AdBannerPlaceholder> createState() => _AdBannerPlaceholderState();
}

class _AdBannerPlaceholderState extends State<AdBannerPlaceholder> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      // Use test ID for development
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AdBanner failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        margin: const EdgeInsets.only(bottom: 16),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Fallback/Loading state
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: widget.height,
      decoration: BoxDecoration(
        color: SynapColors.bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SynapColors.border),
      ),
      child: const Center(
        child: Text('Sponsored', style: TextStyle(color: SynapColors.textMuted, fontSize: 11)),
      ),
    );
  }
}

/// Inline ad for use in lists.
class AdInlinePlaceholder extends StatefulWidget {
  const AdInlinePlaceholder({super.key});

  @override
  State<AdInlinePlaceholder> createState() => _AdInlinePlaceholderState();
}

class _AdInlinePlaceholderState extends State<AdInlinePlaceholder> {
  BannerAd? _inlineAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _inlineAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AdInline failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _inlineAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _inlineAd != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        width: _inlineAd!.size.width.toDouble(),
        height: _inlineAd!.size.height.toDouble(),
        child: AdWidget(ad: _inlineAd!),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 60,
      decoration: BoxDecoration(
        color: SynapColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SynapColors.border),
      ),
      child: const Center(
        child: Text('Sponsored', style: TextStyle(color: SynapColors.textMuted, fontSize: 11)),
      ),
    );
  }
}
