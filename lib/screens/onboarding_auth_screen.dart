import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ── COLORS ───────────────────────────────────────────────────
class OnboardingColors {
  static const voidColor = Color(0xFF000508);
  static const deep = Color(0xFF020B12);
  static const cyan = Color(0xFF00D2F0);
  static const teal = Color(0xFF00FFD1);
  static const text = Color(0xFFE8F4FA);
  static const muted = Color(0x7F8CB4C8); // rgba(140,180,200,0.5)
  static const dead = Color(0x593C6478);  // rgba(60,100,120,0.35)
  static const glass = Color(0x8C04121C); // rgba(4,18,28,0.55)
  static const rim = Color(0x2E00D2F0);   // rgba(0,210,240,0.18)
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late PageController _pageController;

  // Animation controller for background drifts
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingColors.voidColor,
      body: Stack(
        children: [
          _buildCosmosBackground(),
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _SplashView(onGetStarted: () => _goTo(1), onContinueGuest: () => _goTo(2)),
              _AuthView(onBack: () => _goTo(0), onSuccess: () => _goTo(3)),
              _GuestView(onBack: () => _goTo(0), onSignUp: () => _goTo(1), onSuccess: () => _goTo(3)),
              const _SuccessView(),
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
              color: OnboardingColors.cyan.withValues(alpha: 0.12),
              baseOffset: const Offset(-50, -50),
              driftOffset: const Offset(60, 40),
              size: const Size(500, 300),
            ),
            _AuroraDrift(
              controller: _auroraController,
              color: OnboardingColors.teal.withValues(alpha: 0.07),
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

class _SplashView extends StatefulWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onContinueGuest;
  const _SplashView({required this.onGetStarted, required this.onContinueGuest});

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 52),
      child: Column(
        children: [
          const Spacer(flex: 2),
          _buildLogoZone(),
          const Spacer(flex: 3),
          Column(
            children: [
              _PremiumButton(
                text: 'Get Started',
                onPressed: widget.onGetStarted,
                isPrimary: true,
              ),
              const SizedBox(height: 12),
              _PremiumButton(
                text: 'Continue as Guest',
                onPressed: widget.onContinueGuest,
                isPrimary: false,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  text: 'By continuing you agree to our ',
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(color: OnboardingColors.cyan.withValues(alpha: 0.6)),
                    ),
                    const TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: OnboardingColors.cyan.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: OnboardingColors.dead,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoZone() {
    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _logoController,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              RotationTransition(
                turns: Tween(begin: 1.0, end: 0.0).animate(_logoController),
                child: Container(
                  width: 106,
                  height: 106,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.18)),
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.black,
                  border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: OnboardingColors.cyan.withValues(alpha: 0.12),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                    width: 44,
                    height: 44,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Synap',
          style: GoogleFonts.syne(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -2,
          ),
        ),
        Text(
          'DISCOVER · TRACK · CREATE',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: OnboardingColors.muted,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;

  const _PremiumButton({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFF00D2F0), Color(0xFF009AB8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isPrimary ? Colors.white.withValues(alpha: 0.04) : null,
        border: !isPrimary ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: OnboardingColors.cyan.withValues(alpha: 0.28),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: OnboardingColors.text.withValues(alpha: 0.7), size: 18),
                  const SizedBox(width: 10),
                ],
                Text(
                  text,
                  style: GoogleFonts.syne(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isPrimary ? OnboardingColors.deep : OnboardingColors.text.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSuccess;
  const _AuthView({required this.onBack, required this.onSuccess});

  @override
  State<_AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<_AuthView> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  late AnimationController _cardController;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0, left: 0, right: 0, height: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildMiniLogo(),
              const SizedBox(height: 4),
              Text('Synap', style: GoogleFonts.syne(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 40),
            ],
          ),
        ),
        Positioned(
          top: 60, left: 20,
          child: _IconButton(icon: Icons.arrow_back, onTap: widget.onBack),
        ),
        _buildGlassCard(),
      ],
    );
  }

  Widget _buildMiniLogo() {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black,
        border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.25)),
      ),
      child: Center(
        child: SvgPicture.asset('assets/logo.svg', width: 14),
      ),
    );
  }

  Widget _buildGlassCard() {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        final slide = 1.0 - CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic).value;
        return Transform.translate(
          offset: Offset(0, slide * 600),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 620,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF04101A).withValues(alpha: 0.75),
                    const Color(0xFF020A12).withValues(alpha: 0.85),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 40),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 18), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(2)))),
                          Text.rich(TextSpan(text: _isLogin ? 'Welcome ' : 'Create ', children: [TextSpan(text: _isLogin ? 'back' : 'account', style: TextStyle(color: OnboardingColors.cyan))]), style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(_isLogin ? 'Sign in to your Synap account' : 'Join 50,000+ AI explorers', style: GoogleFonts.dmSans(fontSize: 12, color: OnboardingColors.muted)),
                          const SizedBox(height: 22),
                          _AuthSegment(isLogin: _isLogin, onChanged: (v) => setState(() => _isLogin = v)),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(child: _SocialButton(text: 'Google', icon: 'G', onTap: widget.onSuccess)),
                              const SizedBox(width: 10),
                              Expanded(child: _SocialButton(text: 'Apple', icon: 'A', onTap: widget.onSuccess)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildDivider(),
                          const SizedBox(height: 18),
                          _AuthFields(isLogin: _isLogin),
                          const SizedBox(height: 12),
                          _PremiumButton(text: _isLogin ? 'Sign In' : 'Create Account', onPressed: widget.onSuccess, isPrimary: true),
                          const SizedBox(height: 12),
                          _GuestRow(onTap: () => widget.onSuccess()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withValues(alpha: 0.06), Colors.transparent])))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('OR CONTINUE WITH EMAIL', style: TextStyle(fontSize: 10, color: OnboardingColors.dead, letterSpacing: 0.5))),
        Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withValues(alpha: 0.06), Colors.transparent])))),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Icon(icon, color: OnboardingColors.muted, size: 18),
      ),
    );
  }
}

class _AuthSegment extends StatelessWidget {
  final bool isLogin;
  final Function(bool) onChanged;
  const _AuthSegment({required this.isLogin, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: LinearGradient(colors: [OnboardingColors.cyan.withValues(alpha: 0.18), OnboardingColors.cyan.withValues(alpha: 0.08)]),
                  border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.25)),
                  boxShadow: [BoxShadow(color: OnboardingColors.cyan.withValues(alpha: 0.08), blurRadius: 20)],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: GestureDetector(onTap: () => onChanged(true), child: Container(height: 38, alignment: Alignment.center, child: Text('Sign In', style: TextStyle(color: isLogin ? OnboardingColors.cyan : OnboardingColors.muted.withValues(alpha: 0.4), fontWeight: FontWeight.bold, fontSize: 13))))),
              Expanded(child: GestureDetector(onTap: () => onChanged(false), child: Container(height: 38, alignment: Alignment.center, child: Text('Sign Up', style: TextStyle(color: !isLogin ? OnboardingColors.cyan : OnboardingColors.muted.withValues(alpha: 0.4), fontWeight: FontWeight.bold, fontSize: 13))))),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback onTap;
  const _SocialButton({required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        backgroundColor: Colors.white.withValues(alpha: 0.035),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.dmSans(color: OnboardingColors.text.withValues(alpha: 0.75), fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _AuthFields extends StatelessWidget {
  final bool isLogin;
  const _AuthFields({required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isLogin) ...[
          Row(
            children: [
              Expanded(child: _InputField(hint: 'First name', icon: Icons.person_outline)),
              const SizedBox(width: 8),
              Expanded(child: _InputField(hint: 'Last name', icon: Icons.person_outline)),
            ],
          ),
          const SizedBox(height: 10),
        ],
        _InputField(hint: 'Email address', icon: Icons.mail_outline),
        const SizedBox(height: 10),
        _InputField(hint: 'Password', icon: Icons.lock_outline, isPassword: true),
        if (!isLogin) ...[
          const SizedBox(height: 10),
          _InputField(hint: 'Confirm password', icon: Icons.lock_outline, isPassword: true),
        ],
        if (isLogin) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () {}, child: Text('Forgot password?', style: TextStyle(color: OnboardingColors.cyan.withValues(alpha: 0.45), fontSize: 11))),
          ),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  const _InputField({required this.hint, required this.icon, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: OnboardingColors.muted.withValues(alpha: 0.3), size: 18),
          hintStyle: TextStyle(color: OnboardingColors.muted.withValues(alpha: 0.4), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}

class _GuestRow extends StatelessWidget {
  final VoidCallback onTap;
  const _GuestRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
          color: Colors.white.withValues(alpha: 0.02),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: OnboardingColors.dead, size: 14),
            const SizedBox(width: 8),
            Text('Continue without account', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: OnboardingColors.dead.withValues(alpha: 0.5))),
            const Spacer(),
            const Icon(Icons.arrow_forward, color: OnboardingColors.dead, size: 12),
          ],
        ),
      ),
    );
  }
}

class _GuestView extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSignUp;
  final VoidCallback onSuccess;
  const _GuestView({required this.onBack, required this.onSignUp, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
      child: Column(
        children: [
          Align(alignment: Alignment.topLeft, child: _IconButton(icon: Icons.arrow_back, onTap: onBack)),
          const SizedBox(height: 30),
          _buildCrystalAvatar(),
          const SizedBox(height: 22),
          Text.rich(TextSpan(text: 'Guest ', children: [TextSpan(text: 'Mode', style: TextStyle(color: OnboardingColors.cyan))]), style: GoogleFonts.syne(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Explore 200+ AI tools freely. Your favorites are saved right here on this device — no account needed.', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 13, color: OnboardingColors.muted, height: 1.7)),
          const SizedBox(height: 28),
          _buildFeatStack(),
          const SizedBox(height: 28),
          _PremiumButton(text: 'Continue as Guest', onPressed: onSuccess, isPrimary: true),
          const SizedBox(height: 9),
          _PremiumButton(text: 'Create Free Account →', onPressed: onSignUp, isPrimary: false),
        ],
      ),
    );
  }

  Widget _buildCrystalAvatar() {
    return SizedBox(
      width: 110, height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130, height: 130,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.15))),
          ),
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [OnboardingColors.cyan.withValues(alpha: 0.12), const Color(0xFF001E2D).withValues(alpha: 0.8), OnboardingColors.teal.withValues(alpha: 0.06)]),
              border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.2)),
              boxShadow: [BoxShadow(color: OnboardingColors.cyan.withValues(alpha: 0.12), blurRadius: 60)],
            ),
            child: const Center(child: Text('👤', style: TextStyle(fontSize: 42))),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatStack() {
    return Column(
      children: [
        const _FeatCard(icon: '🔍', title: 'Explore AI Tools', sub: 'Discover & filter 200+ free AI tools'),
        const SizedBox(height: 8),
        const _FeatCard(icon: '❤️', title: 'Save Favorites', sub: 'Stored on your device, always available'),
        const SizedBox(height: 8),
        const _FeatCard(icon: '🎙️', title: 'Voice Search', sub: 'Ask in Hindi or English'),
        const SizedBox(height: 8),
        const _FeatCard(icon: '🔒', title: 'Sign up to unlock', sub: 'Tracker, sync, cloud favorites & more', isLocked: true),
      ],
    );
  }
}

class _FeatCard extends StatelessWidget {
  final String icon;
  final String title;
  final String sub;
  final bool isLocked;
  const _FeatCard({required this.icon, required this.title, required this.sub, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [isLocked ? OnboardingColors.cyan.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)]),
        border: Border.all(color: isLocked ? OnboardingColors.cyan.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: OnboardingColors.cyan.withValues(alpha: 0.08), border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.15)), borderRadius: BorderRadius.circular(13)), child: Center(child: Text(icon, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: isLocked ? OnboardingColors.cyan : Colors.white)), Text(sub, style: GoogleFonts.dmSans(fontSize: 11, color: OnboardingColors.muted))])),
          if (isLocked) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: OnboardingColors.cyan.withValues(alpha: 0.08), border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(7)), child: const Text('PRO', style: TextStyle(color: OnboardingColors.cyan, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _SuccessView extends StatefulWidget {
  const _SuccessView();
  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final t = (_pulseController.value - (i * 0.2)).clamp(0.0, 1.0);
                return Opacity(
                  opacity: 1.0 - t,
                  child: Container(
                    width: 80 + t * 270,
                    height: 80 + t * 270,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.15))),
                  ),
                );
              },
            );
          }),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [OnboardingColors.cyan.withValues(alpha: 0.15), OnboardingColors.teal.withValues(alpha: 0.08)]), border: Border.all(color: OnboardingColors.cyan.withValues(alpha: 0.35)), boxShadow: [BoxShadow(color: OnboardingColors.cyan.withValues(alpha: 0.2), blurRadius: 60)]), child: const Center(child: Text('✦', style: TextStyle(fontSize: 36, color: Colors.white)))),
              const SizedBox(height: 24),
              Text("You're in!", style: GoogleFonts.syne(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Opening Synap...', style: GoogleFonts.dmSans(fontSize: 13, color: OnboardingColors.muted)),
              const SizedBox(height: 12),
              Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => _DotAnim(delay: i * 0.15))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotAnim extends StatefulWidget {
  final double delay;
  const _DotAnim({required this.delay});
  @override State<_DotAnim> createState() => _DotAnimState();
}

class _DotAnimState extends State<_DotAnim> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _c, builder: (context, child) => Container(width: 6, height: 6, margin: const EdgeInsets.symmetric(horizontal: 3), decoration: BoxDecoration(shape: BoxShape.circle, color: OnboardingColors.cyan.withValues(alpha: sin((_c.value + widget.delay) * pi).clamp(0.2, 1.0)))));
  }
}
