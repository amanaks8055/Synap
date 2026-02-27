import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'auth_screen.dart';

class SplashContent extends StatefulWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onContinueGuest;
  const SplashContent({super.key, required this.onGetStarted, required this.onContinueGuest});

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent> with SingleTickerProviderStateMixin {
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
                      style: TextStyle(color: AuthColors.cyan.withValues(alpha: 0.6)),
                    ),
                    const TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: AuthColors.cyan.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AuthColors.dead,
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
                    border: Border.all(color: AuthColors.cyan.withValues(alpha: 0.1)),
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
                    border: Border.all(color: AuthColors.cyan.withValues(alpha: 0.18)),
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.black,
                  border: Border.all(color: AuthColors.cyan.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AuthColors.cyan.withValues(alpha: 0.12),
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
            color: AuthColors.muted,
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
                  color: AuthColors.cyan.withValues(alpha: 0.28),
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
                  Icon(icon, color: AuthColors.text.withValues(alpha: 0.7), size: 18),
                  const SizedBox(width: 10),
                ],
                Text(
                  text,
                  style: GoogleFonts.syne(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isPrimary ? AuthColors.deep : AuthColors.text.withValues(alpha: 0.7),
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
