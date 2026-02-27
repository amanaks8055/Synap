import 'package:flutter/material.dart';
import 'dart:math';
import 'splash_content.dart';
import 'login_card.dart';
import 'guest_screen.dart';

// ── COLORS ───────────────────────────────────────────────────
class AuthColors {
  static const voidColor = Color(0xFF000508);
  static const deep = Color(0xFF020B12);
  static const cyan = Color(0xFF00D2F0);
  static const teal = Color(0xFF00FFD1);
  static const text = Color(0xFFE8F4FA);
  static const muted = Color(0x7F8CB4C8);
  static const dead = Color(0x593C6478);
  static const glass = Color(0x8C04121C);
  static const rim = Color(0x2E00D2F0);
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _auroraController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _auroraController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    if (!mounted) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onSuccess() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.voidColor,
      body: Stack(
        children: [
          _buildCosmosBackground(),
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SplashContent(
                onGetStarted: () => _goTo(1),
                onContinueGuest: () => _goTo(2),
              ),
              LoginCard(
                onBack: () => _goTo(0),
                onSuccess: _onSuccess,
              ),
              GuestScreen(
                onBack: () => _goTo(0),
                onSignUp: () => _goTo(1),
                onSuccess: _onSuccess,
              ),
              _SuccessView(onComplete: _onSuccess),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCosmosBackground() {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.6, -0.4),
                  radius: 1.2,
                  colors: [Color(0xFF003C5A), Colors.transparent],
                ),
              ),
            ),
            _AuroraDrift(
              controller: _auroraController,
              color: AuthColors.cyan.withValues(alpha: 0.12),
              baseOffset: const Offset(-50, -50),
              driftOffset: const Offset(60, 40),
              size: const Size(500, 300),
            ),
            _AuroraDrift(
              controller: _auroraController,
              color: AuthColors.teal.withValues(alpha: 0.07),
              baseOffset: const Offset(50, 400),
              driftOffset: const Offset(-50, -60),
              size: const Size(400, 400),
              alignment: Alignment.bottomRight,
            ),
            const _StarField(),
          ],
        );
      },
    );
  }
}

class _AuroraDrift extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final Offset baseOffset;
  final Offset driftOffset;
  final Size size;
  final Alignment alignment;

  const _AuroraDrift({
    required this.controller,
    required this.color,
    required this.baseOffset,
    required this.driftOffset,
    required this.size,
    this.alignment = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final offset = Offset(
          baseOffset.dx + driftOffset.dx * t,
          baseOffset.dy + driftOffset.dy * t,
        );

        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: offset,
            child: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color, Colors.transparent],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(),
      size: Size.infinite,
    );
  }
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars = List.generate(
    180,
    (index) => _Star(
      x: Random().nextDouble(),
      y: Random().nextDouble(),
      size: Random().nextDouble() * 0.9 + 0.1,
      alpha: Random().nextDouble() * 0.5 + 0.1,
      speed: Random().nextDouble() * 0.01 + 0.003,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (var star in stars) {
      final alpha = star.alpha * (0.6 + 0.4 * sin(time * 2 * pi * star.speed * 10));
      paint.color = const Color(0xFFB4E6F5).withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Star {
  final double x, y, size, alpha, speed;
  _Star({required this.x, required this.y, required this.size, required this.alpha, required this.speed});
}

class _SuccessView extends StatefulWidget {
  final VoidCallback onComplete;
  const _SuccessView({required this.onComplete});

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 + _controller.value * 2.0;
          final opacity = (1.0 - _controller.value).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AuthColors.cyan.withValues(alpha: 0.3),
                  boxShadow: [BoxShadow(color: AuthColors.cyan.withValues(alpha: 0.5), blurRadius: 40)],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
