// ══════════════════════════════════════════════════════════════
// SYNAP — Midjourney-Style Animated Splash Screen
// Features:
//   • Matrix rain animation (CustomPainter, Canvas)
//   • AI-themed scrolling words (synap, gpt, neural, tokens...)
//   • Glitch effect on logo with cyan/magenta split
//   • CRT scan lines overlay
//   • Radial vignette + bottom gradient
//   • Animated cyan glow pulse on brand
//   • Auto-transition to main app with fade-out
// ══════════════════════════════════════════════════════════════

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Animation controllers ─────────────────────────────────
  late AnimationController _rainController;      // matrix rain loop
  late AnimationController _brandController;     // logo fade in
  late AnimationController _glowController;      // pulsing glow
  late AnimationController _fadeOutController;   // exit fade

  late Animation<double> _brandFade;
  late Animation<double> _glowPulse;
  late Animation<double> _fadeOut;

  bool _glitching = false;
  Timer? _glitchTimer;
  Timer? _transitionTimer;

  // Matrix rain columns — initialized once
  List<_RainColumn>? _rainColumns;

  @override
  void initState() {
    super.initState();

    // ── Rain: runs forever (repaints via listener) ──────────
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    )..repeat();

    // ── Brand: fades in after 400ms ─────────────────────────
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _brandFade = CurvedAnimation(
      parent: _brandController,
      curve: Curves.easeOut,
    );

    // ── Glow: endless pulse ─────────────────────────────────
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // ── Fade out: before transition ─────────────────────────
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    // ── Sequence ────────────────────────────────────────────
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _brandController.forward();
    });

    // ── Periodic glitch ─────────────────────────────────────
    _glitchTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) _triggerGlitch();
    });
    // Initial glitch after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _triggerGlitch();
    });

    // ── Auto-transition after 4s (Updated) ──────────────────
    _transitionTimer = Timer(const Duration(milliseconds: 4000), () {
      if (!mounted) return;
      _fadeOutController.forward().then((_) {
        if (mounted) widget.onDone();
      });
    });
  }

  Future<void> _triggerGlitch() async {
    if (!mounted) return;
    setState(() => _glitching = true);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _glitching = false);
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    setState(() => _glitching = true);
    await Future.delayed(const Duration(milliseconds: 70));
    if (!mounted) return;
    setState(() => _glitching = false);
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    _transitionTimer?.cancel();
    _rainController.dispose();
    _brandController.dispose();
    _glowController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeOut,
        child: Stack(
          children: [
            // ── 1. Matrix Rain (full screen) ───────────────
            AnimatedBuilder(
              animation: _rainController,
              builder: (_, __) => CustomPaint(
                painter: _MatrixRainPainter(
                  columns: _getOrInitColumns(size),
                ),
                size: size,
              ),
            ),

            // ── 2. Vignette overlay ─────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Colors.transparent, Color(0xAA000000)],
                ),
              ),
            ),

            // ── 3. Bottom gradient for brand readability ────
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: size.height * 0.55,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFF000000),
                      Color(0xE6000000),
                      Color(0x80000000),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              ),
            ),

            // ── 4. CRT Scan lines ───────────────────────────
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ScanLinePainter()),
              ),
            ),

            // ── 5. Brand / Logo (centered) ──────────────────
            Center(
              child: FadeTransition(
                opacity: _brandFade,
                child: _buildBrand(),
              ),
            ),

            // ── 6. Bottom tagline ───────────────────────────
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0, right: 0,
              child: FadeTransition(
                opacity: _brandFade,
                child: Center(
                  child: Text(
                    'Discover  •  Compare  •  Optimize',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF00DCE8).withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_RainColumn> _getOrInitColumns(Size size) {
    if (_rainColumns == null) {
      // Increased column width for larger characters (22px)
      final colWidth = 24.0;
      final cols = (size.width / colWidth).floor();
      final rng = Random();
      _rainColumns = List.generate(cols, (i) => _RainColumn(
        x: i * colWidth,
        y: rng.nextDouble() * -size.height,
        // Increased speed range (3.0 to 9.0)
        speed: 3.0 + rng.nextDouble() * 6.0,
        colorType: rng.nextDouble() < 0.55 ? 0 : rng.nextDouble() < 0.8 ? 1 : 2,
        word: rng.nextDouble() < 0.2
            ? _aiWords[rng.nextInt(_aiWords.length)]
            : null,
        height: size.height,
        rng: rng,
      ));
    }
    return _rainColumns!;
  }

  // ─────────────────────────────────────────────────────────
  // BRAND WIDGET — Logo Image + Glitch Name + Subtitle
  // ─────────────────────────────────────────────────────────
  Widget _buildBrand() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Logo image with glow (Updated: Changed from Text to Svg) ──────────
        AnimatedBuilder(
          animation: _glowPulse,
          builder: (_, __) => Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.black,
              border: Border.all(
                color: const Color(0xFF00DCE8).withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 220, 232, _glowPulse.value),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  width: 48,
                  height: 48,
                  placeholderBuilder: (context) => const Text('⚡', style: TextStyle(fontSize: 32)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Glitch brand name ──────────────────────────────
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 50),
          style: GoogleFonts.syne(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            letterSpacing: -2,
            color: Colors.white,
            shadows: _glitching
                ? [
                    const Shadow(color: Color(0xFFFF0080), offset: Offset(-3, 0), blurRadius: 0),
                    const Shadow(color: Color(0xFF00FFFF), offset: Offset(3, 0), blurRadius: 0),
                    Shadow(color: const Color(0xFF00DCE8).withValues(alpha: 0.6), blurRadius: 40),
                  ]
                : [
                    Shadow(color: const Color(0xFF00DCE8).withValues(alpha: 0.5), blurRadius: 40),
                    Shadow(color: const Color(0xFF00DCE8).withValues(alpha: 0.2), blurRadius: 80),
                  ],
          ),
          child: const Text('Synap'),
        ),

        const SizedBox(height: 8),

        // ── Subtitle ───────────────────────────────────────
        Text(
          'AI TOOLS DISCOVERY',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            letterSpacing: 5,
            color: const Color(0xFF00DCE8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── AI-themed words for matrix rain ─────────────────────
  static const _aiWords = [
    'imagine', 'generate', 'prompt', 'model', 'neural', 'diffuse',
    'tokens', 'context', 'embed', 'latent', 'synap', 'discover',
    'gpt', 'llm', 'vector', 'inference', 'weights', 'attention',
    'openai', 'claude', 'gemini', 'vision', 'audio', 'code',
    'tools', 'free', 'paid', 'api', 'train', 'search',
  ];
}

// ══════════════════════════════════════════════════════════════
// MATRIX RAIN PAINTER
// AI-themed words + random chars, multi-speed/color columns
// ══════════════════════════════════════════════════════════════
class _MatrixRainPainter extends CustomPainter {
  final List<_RainColumn> columns;
  static DateTime _lastUpdate = DateTime.now();

  _MatrixRainPainter({required this.columns});

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final dt = (now.difference(_lastUpdate).inMicroseconds / 16667).clamp(0.5, 3.0);
    _lastUpdate = now;

    // Subtle fade trail (creates the fading tail effect)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0x15000000),
    );

    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (final col in columns) {
      col.update(dt, size.height);

      // ── Draw trailing chars with fade ──────────────────
      final trailLen = col.trail.length;
      for (int t = 0; t < trailLen; t++) {
        // Increased character vertical spacing due to size (24px)
        final charY = col.y - (trailLen - t) * 24.0;
        if (charY < -24 || charY > size.height) continue;

        final alpha = (t / trailLen);
        final Color c;
        switch (col.colorType) {
          case 0: // Cyan
            c = Color.fromRGBO(100, 230, 255, alpha * 0.75);
            break;
          case 1: // Teal
            c = Color.fromRGBO(0, 190, 170, alpha * 0.65);
            break;
          default: // Soft white
            c = Color.fromRGBO(180, 220, 230, alpha * 0.45);
        }

        tp.text = TextSpan(
          text: col.trail[t],
          style: TextStyle(
            fontSize: 22, // Increased from 13
            color: c,
            fontFamily: 'monospace',
            height: 1.0,
          ),
        );
        tp.layout();
        tp.paint(canvas, Offset(col.x, charY));
      }

      // ── Draw head char — brightest ─────────────────────
      if (col.y >= 0 && col.y <= size.height) {
        final Color headColor;
        switch (col.colorType) {
          case 0:
            headColor = const Color(0xFFAAF0FF);
            break;
          case 1:
            headColor = const Color(0xFF00DCBA);
            break;
          default:
            headColor = const Color(0xFFCCE8F0);
        }

        tp.text = TextSpan(
          text: col.headChar,
          style: TextStyle(
            fontSize: 22, // Increased from 13
            color: headColor,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        );
        tp.layout();
        tp.paint(canvas, Offset(col.x, col.y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Single rain column data ─────────────────────────────────
class _RainColumn {
  final double x;
  double y;
  final double speed;
  final int colorType; // 0=cyan, 1=teal, 2=white
  final String? word;
  final double height;
  final Random rng;

  final List<String> trail = [];
  String headChar = ' ';
  double _accumulator = 0;

  static const String _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:,./<>?';

  _RainColumn({
    required this.x,
    required this.y,
    required this.speed,
    required this.colorType,
    required this.word,
    required this.height,
    required this.rng,
  }) {
    headChar = _nextChar(0);
  }

  String _nextChar(int trailIdx) {
    if (word != null && trailIdx < word!.length) {
      return word![trailIdx];
    }
    return _chars[rng.nextInt(_chars.length)];
  }

  void update(double dt, double screenHeight) {
    y += speed * dt;
    _accumulator += dt;

    // Occasionally randomize head char
    if (rng.nextDouble() < 0.12) {
      headChar = _nextChar(trail.length);
    }

    // Add to trail every ~1 frame
    if (_accumulator >= 1.0 && trail.length < 18) { // Slightly shorter trail for larger chars
      trail.add(headChar);
      _accumulator = 0;
    }

    // Reset when below screen
    if (y > screenHeight + 100) {
      y = rng.nextDouble() * -screenHeight * 0.4;
      trail.clear();
      _accumulator = 0;
      headChar = _nextChar(0);
    }
  }
}

// ══════════════════════════════════════════════════════════════
// CRT SCAN LINE PAINTER
// Thin horizontal lines for retro-tech feel
// ══════════════════════════════════════════════════════════════
class _ScanLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x0A000000);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
