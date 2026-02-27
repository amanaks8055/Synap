import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen.dart';

class GuestScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSignUp;
  final VoidCallback onSuccess;
  const GuestScreen({super.key, required this.onBack, required this.onSignUp, required this.onSuccess});

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
          Text.rich(const TextSpan(text: 'Guest ', children: [TextSpan(text: 'Mode', style: TextStyle(color: AuthColors.cyan))]), style: GoogleFonts.syne(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Explore 200+ AI tools freely. Your favorites are saved right here on this device — no account needed.', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 13, color: AuthColors.muted, height: 1.7)),
          const SizedBox(height: 28),
          _buildFeatStack(),
          const SizedBox(height: 28),
          _GuestButton(text: 'Explore as Guest', onPressed: onSuccess, isPrimary: true),
          const SizedBox(height: 12),
          _GuestButton(text: 'Create Account', onPressed: onSignUp, isPrimary: false),
        ],
      ),
    );
  }

  Widget _buildCrystalAvatar() {
    return Container(
      width: 90, height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AuthColors.cyan.withValues(alpha: 0.1),
        border: Border.all(color: AuthColors.cyan.withValues(alpha: 0.2), width: 2),
        boxShadow: [BoxShadow(color: AuthColors.cyan.withValues(alpha: 0.15), blurRadius: 30)],
      ),
      child: const Center(child: Icon(Icons.person_outline, color: AuthColors.cyan, size: 40)),
    );
  }

  Widget _buildFeatStack() {
    return Column(
      children: [
        _FeatRow(icon: '📊', title: 'Local Tracking', desc: 'Monitor ChatGPT & Claude usage'),
        const SizedBox(height: 12),
        _FeatRow(icon: '⭐️', title: 'Device Favorites', desc: 'Save tools to your device'),
        const SizedBox(height: 12),
        _FeatRow(icon: '🔒', title: 'Private & Secure', desc: 'No data leaves your device'),
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
        child: Icon(icon, color: AuthColors.muted, size: 18),
      ),
    );
  }
}

class _FeatRow extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;
  const _FeatRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(icon, style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text(desc, style: GoogleFonts.dmSans(fontSize: 11, color: AuthColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _GuestButton({required this.text, required this.onPressed, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isPrimary
            ? const LinearGradient(colors: [Color(0xFF00D2F0), Color(0xFF009AB8)])
            : null,
        color: !isPrimary ? Colors.white.withValues(alpha: 0.04) : null,
        border: !isPrimary ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Text(text, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: isPrimary ? AuthColors.deep : AuthColors.text.withValues(alpha: 0.7))),
          ),
        ),
      ),
    );
  }
}
