// ══════════════════════════════════════════════════════════════
// SYNAP — Premium Screen
// Student:      ₹29/2mo  | ₹79/7mo  | ₹549/yr
// Professional: ₹149/4mo | ₹749/yr
// Features: AI rain bg, SLAM animations, tier toggle,
//           real billing, restore, error handling
// ══════════════════════════════════════════════════════════════

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/premium/premium_bloc.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {

  // ── Controllers ──────────────────────────────────────────
  late AnimationController _rainCtrl;
  late AnimationController _entranceCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _tabCtrl;

  // ── Entrance animations ──────────────────────────────────
  late Animation<double>  _heroFade;
  late Animation<Offset>  _heroSlide;
  late Animation<double>  _tabFade;
  late Animation<double>  _cardsFade;
  late Animation<Offset>  _cardsSlide;
  late Animation<double>  _ctaScale;

  // ── State ────────────────────────────────────────────────
  PlanTier _selectedTier = PlanTier.student;
  String _selectedPlanId = SynapPlans.student7Month; // default: popular

  @override
  void initState() {
    super.initState();

    _rainCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 80),
    )..repeat();

    _shimmerCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000),
    )..repeat();

    _tabCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300),
    );

    _entranceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100),
    );

    // Staggered SLAM-style entrance
    _heroFade  = _interval(0.0, 0.4);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, -0.25), end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    _tabFade   = _interval(0.25, 0.55);
    _cardsFade = _interval(0.4, 0.75);
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.15), end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    ));
    _ctaScale  = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutBack),
    ));

    _entranceCtrl.forward();
  }

  Animation<double> _interval(double begin, double end) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _rainCtrl.dispose();
    _entranceCtrl.dispose();
    _shimmerCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  void _switchTier(PlanTier tier) {
    if (_selectedTier == tier) return;
    setState(() {
      _selectedTier = tier;
      _selectedPlanId = tier == PlanTier.student
          ? SynapPlans.student7Month
          : SynapPlans.proYearly;
    });
    _tabCtrl.forward(from: 0);
  }

  List<PlanDefinition> get _currentPlans => _selectedTier == PlanTier.student
      ? SynapPlans.studentPlans
      : SynapPlans.proPlans;

  void _showSnack(String msg, {bool isError = true, bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Text(isSuccess ? '🎉 ' : isError ? '⚠️ ' : 'ℹ️ '),
        const SizedBox(width: 6),
        Expanded(child: Text(msg,
          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13))),
      ]),
      backgroundColor: isSuccess
          ? const Color(0xFF0D2E1A)
          : isError
              ? const Color(0xFF3D0011)
              : const Color(0xFF0D1A2E),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: Duration(seconds: isSuccess ? 4 : 3),
    ));
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PremiumBloc, PremiumState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (ctx, state) {
        if (state.isSuccess) {
          final tier = state.isStudent ? 'Student' : 'Professional';
          _showSnack('Welcome to Synap $tier Pro! 🎉',
              isError: false, isSuccess: true);
          final navigator = Navigator.of(context);
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) navigator.pop();
          });
        }
        if (state.hasError && state.errorMessage != null) {
          _showSnack(state.errorMessage!);
        }
        if (state.status == PremiumStatus.restoring) {
          _showSnack('Checking your purchases...', isError: false);
        }
      },
      builder: (ctx, state) => Scaffold(
        backgroundColor: const Color(0xFF040608),
        body: Stack(children: [

          // ── Rain BG ───────────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rainCtrl,
              builder: (_, __) => CustomPaint(
                painter: _RainPainter(_rainCtrl.value),
              ),
            ),
          ),

          // ── Gradient overlay ──────────────────────────────
          Positioned.fill(child: IgnorePointer(child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x22040608), Color(0x44040608),
                  Color(0xCC040608), Color(0xFF040608),
                ],
                stops: [0, 0.3, 0.55, 0.75],
              ),
            ),
          ))),

          // ── Content ───────────────────────────────────────
          SafeArea(
            child: Column(children: [
              _buildAppBar(ctx, state),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(children: [
                    _buildHero(),
                    const SizedBox(height: 28),
                    _buildTierToggle(),
                    const SizedBox(height: 20),
                    _buildPlanCards(state),
                    const SizedBox(height: 20),
                    _buildFeatures(),
                    const SizedBox(height: 28),
                    _buildCTAButton(ctx, state),
                    const SizedBox(height: 14),
                    _buildRestoreButton(ctx, state),
                    const SizedBox(height: 12),
                    _buildLegal(),
                  ]),
                ),
              ),
            ]),
          ),

          // ── Full-screen loading overlay ───────────────────
          if (state.isPurchasing || state.isRestoring)
            _buildLoadingOverlay(state),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext ctx, PremiumState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 12, 0),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF4A5568)),
          onPressed: () => Navigator.pop(ctx),
        ),
        const Spacer(),
        if (state.isPremium)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(colors: [
                Color(0xFF0D2E1A), Color(0xFF0D1A2E),
              ]),
              border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
            ),
            child: const Text('✓ Active', style: TextStyle(
              fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w600,
              color: Color(0xFF22C55E),
            )),
          ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HERO HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildHero() {
    return SlideTransition(
      position: _heroSlide,
      child: FadeTransition(
        opacity: _heroFade,
        child: Column(children: [
          const SizedBox(height: 12),

          // Animated glow icon
          AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, __) => Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: const Color(0xFF6EE7F7).withValues(alpha:
                    0.12 + 0.18 * sin(_shimmerCtrl.value * 2 * pi),
                  ),
                  blurRadius: 35, spreadRadius: 6,
                )],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFF6EE7F7).withValues(alpha: 0.12),
                    const Color(0xFF040608),
                  ]),
                  border: Border.all(
                    color: const Color(0xFF6EE7F7).withValues(alpha: 0.2),
                  ),
                ),
                child: const Center(
                  child: Text('⚡', style: TextStyle(fontSize: 36)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Text('Synap Pro', style: TextStyle(
            fontFamily: 'Syne', fontSize: 34, fontWeight: FontWeight.w800,
            color: Colors.white, letterSpacing: -1,
          )),
          const SizedBox(height: 8),
          Text(
            'Unlock every AI tool. Zero ads.\nCancel anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans', fontSize: 14,
              color: Colors.white.withValues(alpha: 0.4), height: 1.6,
            ),
          ),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TIER TOGGLE (Student / Professional)
  // ─────────────────────────────────────────────────────────
  Widget _buildTierToggle() {
    return FadeTransition(
      opacity: _tabFade,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0A0E14),
          border: Border.all(color: const Color(0xFF1E2530)),
        ),
        child: Row(children: [
          _TierTab(
            label: '🎓 Student',
            sublabel: 'From ₹29',
            isActive: _selectedTier == PlanTier.student,
            activeColor: const Color(0xFF6EE7F7),
            onTap: () => _switchTier(PlanTier.student),
          ),
          _TierTab(
            label: '💼 Professional',
            sublabel: 'From ₹149',
            isActive: _selectedTier == PlanTier.professional,
            activeColor: const Color(0xFFA78BFA),
            onTap: () => _switchTier(PlanTier.professional),
          ),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // PLAN CARDS
  // ─────────────────────────────────────────────────────────
  Widget _buildPlanCards(PremiumState state) {
    return SlideTransition(
      position: _cardsSlide,
      child: FadeTransition(
        opacity: _cardsFade,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim, child: child,
          ),
          child: Column(
            key: ValueKey(_selectedTier),
            children: _currentPlans.map((plan) {
              final isSelected = _selectedPlanId == plan.id;
              // Get live price from Play Store or use static fallback
              final displayPrice = state.livePrice(plan.id, plan.price);
              final accentColor = _selectedTier == PlanTier.student
                  ? const Color(0xFF6EE7F7)
                  : const Color(0xFFA78BFA);

              return _PlanCard(
                plan: plan,
                displayPrice: displayPrice,
                isSelected: isSelected,
                accentColor: accentColor,
                onTap: () => setState(() => _selectedPlanId = plan.id),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // FEATURES
  // ─────────────────────────────────────────────────────────
  Widget _buildFeatures() {
    final studentFeatures = [
      ('⚡', 'Access 500+ AI tools'),
      ('🚫', 'Ad-free experience'),
      ('🔖', 'Save unlimited favorites'),
      ('🔍', 'Advanced search & filters'),
    ];
    final proFeatures = [
      ('⚡', 'Everything in Student'),
      ('🎯', 'Personalized AI recommendations'),
      ('🆕', 'Early access to new tools'),
      ('📊', 'Tool comparison & analytics'),
      ('⭐', 'Priority support'),
    ];

    final features = _selectedTier == PlanTier.student
        ? studentFeatures
        : proFeatures;

    final accentColor = _selectedTier == PlanTier.student
        ? const Color(0xFF6EE7F7)
        : const Color(0xFFA78BFA);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_selectedTier),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF0A0E14),
          border: Border.all(color: const Color(0xFF1E2530)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedTier == PlanTier.student
                  ? '🎓 Student Plan includes'
                  : '💼 Professional Plan includes',
              style: const TextStyle(
                fontFamily: 'Syne', fontSize: 14, fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Text(f.$1, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 12),
                Expanded(child: Text(f.$2, style: const TextStyle(
                  fontFamily: 'DM Sans', fontSize: 13,
                  color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500,
                ))),
                Icon(Icons.check_circle_rounded, color: accentColor, size: 16),
              ]),
            )),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CTA BUTTON
  // ─────────────────────────────────────────────────────────
  Widget _buildCTAButton(BuildContext ctx, PremiumState state) {
    final accentColor = _selectedTier == PlanTier.student
        ? const Color(0xFF6EE7F7)
        : const Color(0xFFA78BFA);

    final plan = _currentPlans.firstWhere(
      (p) => p.id == _selectedPlanId,
      orElse: () => _currentPlans.first,
    );
    final displayPrice = state.livePrice(_selectedPlanId, plan.price);

    return ScaleTransition(
      scale: _ctaScale,
      child: GestureDetector(
        onTap: (state.isPurchasing || state.isLoading || !state.billingAvailable)
            ? null
            : () => ctx.read<PremiumBloc>().add(
                PremiumPurchaseStarted(_selectedPlanId)),
        child: AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) {
            final glowOpacity = 0.2 + 0.15 * sin(_shimmerCtrl.value * 2 * pi);
            return Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: accentColor,
                boxShadow: [BoxShadow(
                  color: accentColor.withValues(alpha: glowOpacity),
                  blurRadius: 25, offset: const Offset(0, 8),
                )],
              ),
              child: Center(child: state.isPurchasing
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF040608),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.isPremium ? 'Already Active ✓' : 'Get Started — $displayPrice',
                          style: const TextStyle(
                            fontFamily: 'Syne', fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF040608),
                          ),
                        ),
                        Text(
                          'for ${plan.period}',
                          style: TextStyle(
                            fontFamily: 'DM Sans', fontSize: 11,
                            color: const Color(0xFF040608).withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // RESTORE BUTTON
  // ─────────────────────────────────────────────────────────
  Widget _buildRestoreButton(BuildContext ctx, PremiumState state) {
    return TextButton(
      onPressed: state.isRestoring
          ? null
          : () => ctx.read<PremiumBloc>().add(PremiumPurchaseRestored()),
      child: Text(
        state.isRestoring ? 'Restoring...' : 'Restore Purchase',
        style: const TextStyle(
          fontFamily: 'DM Sans', fontSize: 13,
          color: Color(0xFF4A5568), fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLegal() {
    return Text(
      'Subscriptions auto-renew. Cancel anytime via Google Play.\n'
      'By continuing you agree to our Terms & Privacy Policy.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'DM Sans', fontSize: 10,
        color: Colors.white.withValues(alpha: 0.2), height: 1.5,
      ),
    );
  }

  Widget _buildLoadingOverlay(PremiumState state) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF6EE7F7), strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            state.isRestoring ? 'Restoring purchase...' : 'Processing payment...',
            style: const TextStyle(
              fontFamily: 'DM Sans', fontSize: 14, color: Colors.white70,
            ),
          ),
        ],
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TIER TAB WIDGET
// ══════════════════════════════════════════════════════════════
class _TierTab extends StatelessWidget {
  final String label, sublabel;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _TierTab({
    required this.label, required this.sublabel,
    required this.isActive, required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          border: isActive
              ? Border.all(color: activeColor.withValues(alpha: 0.4))
              : Border.all(color: Colors.transparent),
        ),
        child: Column(children: [
          Text(label, style: TextStyle(
            fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700,
            color: isActive ? activeColor : const Color(0xFF4A5568),
          )),
          const SizedBox(height: 2),
          Text(sublabel, style: TextStyle(
            fontFamily: 'DM Sans', fontSize: 11,
            color: isActive
                ? activeColor.withValues(alpha: 0.7)
                : const Color(0xFF2D3748),
          )),
        ]),
      ),
    ));
  }
}

// ══════════════════════════════════════════════════════════════
// PLAN CARD WIDGET
// ══════════════════════════════════════════════════════════════
class _PlanCard extends StatefulWidget {
  final PlanDefinition plan;
  final String displayPrice;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan, required this.displayPrice,
    required this.isSelected, required this.accentColor,
    required this.onTap,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: widget.isSelected
              ? widget.accentColor.withValues(alpha: 0.07)
              : const Color(0xFF0A0E14),
          border: Border.all(
            color: widget.isSelected
                ? widget.accentColor
                : const Color(0xFF1E2530),
            width: widget.isSelected ? 1.5 : 1,
          ),
          boxShadow: widget.isSelected ? [BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.1), blurRadius: 20,
          )] : null,
        ),
        child: Row(children: [
          // Radio dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isSelected
                    ? widget.accentColor
                    : const Color(0xFF2D3748),
                width: widget.isSelected ? 5.5 : 2,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Plan label + per-month
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(widget.plan.label, style: TextStyle(
                  fontFamily: 'Syne', fontSize: 15, fontWeight: FontWeight.w700,
                  color: widget.isSelected
                      ? Colors.white
                      : const Color(0xFF64748B),
                )),
                if (widget.plan.highlight != null) ...[
                  const SizedBox(width: 8),
                  _Badge(
                    text: widget.plan.highlight!,
                    color: widget.plan.highlight == 'POPULAR'
                        ? const Color(0xFF6EE7F7)
                        : const Color(0xFF22C55E),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(widget.plan.perMonth, style: const TextStyle(
                fontFamily: 'DM Sans', fontSize: 11,
                color: Color(0xFF4A5568),
              )),
            ],
          )),

          // Price + period
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(widget.displayPrice, style: TextStyle(
              fontFamily: 'Syne', fontSize: 18, fontWeight: FontWeight.w800,
              color: widget.isSelected ? Colors.white : const Color(0xFF4A5568),
            )),
            Text('/ ${widget.plan.period}', style: const TextStyle(
              fontFamily: 'DM Sans', fontSize: 10,
              color: Color(0xFF2D3748),
            )),
          ]),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(text, style: TextStyle(
        fontFamily: 'DM Sans', fontSize: 9,
        fontWeight: FontWeight.w700, letterSpacing: 0.5, color: color,
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AI RAIN PAINTER (subtle, behind content)
// ══════════════════════════════════════════════════════════════
class _RainPainter extends CustomPainter {
  final double progress;
  _RainPainter(this.progress);

  static List<_Col>? _cols;

  static void _init(Size size) {
    if (_cols != null) return;
    final rng = Random(7);
    final n = (size.width / 14).floor();
    _cols = List.generate(n, (i) => _Col(
      x: i * 14.0,
      y: rng.nextDouble() * size.height,
      speed: 1.5 + rng.nextDouble() * 3,
      alpha: 0.06 + rng.nextDouble() * 0.12,
      color: rng.nextDouble() < 0.6
          ? const Color(0xFF00D2F0)
          : const Color(0xFFA78BFA),
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    _init(size);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF040608),
    );

    const chars = 'ABCDEFabcdef0123456789!@#\$%^';
    final rng = Random(42);
    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (final col in _cols!) {
      final y = (col.y + progress * col.speed * size.height * 2) % size.height;
      final ch = chars[rng.nextInt(chars.length)];
      tp.text = TextSpan(
        text: ch,
        style: TextStyle(
          fontSize: 13, color: col.color.withValues(alpha: col.alpha),
          fontFamily: 'monospace',
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(col.x, y));
    }
  }

  @override
  bool shouldRepaint(_RainPainter old) => old.progress != progress;
}

class _Col {
  final double x, speed, alpha;
  double y;
  final Color color;
  _Col({required this.x, required this.y, required this.speed,
        required this.alpha, required this.color});
}
