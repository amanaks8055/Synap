import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'auth_screen.dart';

class LoginCard extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSuccess;
  const LoginCard({super.key, required this.onBack, required this.onSuccess});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> with SingleTickerProviderStateMixin {
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
        border: Border.all(color: AuthColors.cyan.withValues(alpha: 0.25)),
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
                          Text.rich(TextSpan(text: _isLogin ? 'Welcome ' : 'Create ', children: [TextSpan(text: _isLogin ? 'back' : 'account', style: const TextStyle(color: AuthColors.cyan))]), style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(_isLogin ? 'Sign in to your Synap account' : 'Join 50,000+ AI explorers', style: GoogleFonts.dmSans(fontSize: 12, color: AuthColors.muted)),
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
                          _BigButton(text: _isLogin ? 'Sign In' : 'Create Account', onPressed: widget.onSuccess, isPrimary: true),
                          const SizedBox(height: 12),
                          _GuestRow(onTap: widget.onSuccess),
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
        const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('OR CONTINUE WITH EMAIL', style: TextStyle(fontSize: 10, color: AuthColors.dead, letterSpacing: 0.5))),
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
        child: Icon(icon, color: AuthColors.muted, size: 18),
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
                  gradient: LinearGradient(colors: [AuthColors.cyan.withValues(alpha: 0.18), AuthColors.cyan.withValues(alpha: 0.08)]),
                  border: Border.all(color: AuthColors.cyan.withValues(alpha: 0.25)),
                  boxShadow: [BoxShadow(color: AuthColors.cyan.withValues(alpha: 0.08), blurRadius: 20)],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: GestureDetector(onTap: () => onChanged(true), child: Container(height: 38, alignment: Alignment.center, child: Text('Sign In', style: TextStyle(color: isLogin ? AuthColors.cyan : AuthColors.muted.withValues(alpha: 0.4), fontWeight: FontWeight.bold, fontSize: 13))))),
              Expanded(child: GestureDetector(onTap: () => onChanged(false), child: Container(height: 38, alignment: Alignment.center, child: Text('Sign Up', style: TextStyle(color: !isLogin ? AuthColors.cyan : AuthColors.muted.withValues(alpha: 0.4), fontWeight: FontWeight.bold, fontSize: 13))))),
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
          Text(text, style: GoogleFonts.dmSans(color: AuthColors.text.withValues(alpha: 0.75), fontWeight: FontWeight.w600, fontSize: 13)),
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
              const Expanded(child: _InputField(hint: 'First name', icon: Icons.person_outline)),
              const SizedBox(width: 8),
              const Expanded(child: _InputField(hint: 'Last name', icon: Icons.person_outline)),
            ],
          ),
          const SizedBox(height: 10),
        ],
        const _InputField(hint: 'Email address', icon: Icons.mail_outline),
        const SizedBox(height: 10),
        const _InputField(hint: 'Password', icon: Icons.lock_outline, isPassword: true),
        if (!isLogin) ...[
          const SizedBox(height: 10),
          const _InputField(hint: 'Confirm password', icon: Icons.lock_outline, isPassword: true),
        ],
        if (isLogin) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () {}, child: Text('Forgot password?', style: TextStyle(color: AuthColors.cyan.withValues(alpha: 0.45), fontSize: 11))),
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
          prefixIcon: Icon(icon, color: AuthColors.muted.withValues(alpha: 0.3), size: 18),
          hintStyle: TextStyle(color: AuthColors.muted.withValues(alpha: 0.4), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _BigButton({required this.text, required this.onPressed, required this.isPrimary});

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
        boxShadow: isPrimary
            ? [BoxShadow(color: AuthColors.cyan.withValues(alpha: 0.28), blurRadius: 32, offset: const Offset(0, 8))]
            : null,
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
            const Icon(Icons.person_outline, color: AuthColors.dead, size: 14),
            const SizedBox(width: 8),
            Text('Continue without account', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AuthColors.dead.withValues(alpha: 0.5))),
            const Spacer(),
            const Icon(Icons.arrow_forward, color: AuthColors.dead, size: 12),
          ],
        ),
      ),
    );
  }
}
