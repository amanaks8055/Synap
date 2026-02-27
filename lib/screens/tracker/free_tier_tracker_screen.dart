import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/tracker/tracker_bloc.dart';
import '../../blocs/tracker/tracker_event.dart';
import '../../blocs/tracker/tracker_state.dart';
import '../../models/tracker_tool.dart';

class FreeTierTrackerScreen extends StatefulWidget {
  const FreeTierTrackerScreen({super.key});
  @override State<FreeTierTrackerScreen> createState() => _State();
}

class _State extends State<FreeTierTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _pulseCtrl;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1), (_) { if (mounted) setState(() {}); },
    );
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrackerBloc, TrackerState>(
      listenWhen: (p, c) =>
          c.alertToolId != null && p.alertToolId != c.alertToolId,
      listener: (ctx, state) {
        if (state.alertToolId == null) return;
        final tool = state.tools.firstWhere(
          (t) => t.id == state.alertToolId,
          orElse: () => state.tools.first,
        );
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(
            tool.isExhausted
                ? '🔴 ${tool.name} limit reached! Switch to ${tool.switchTo}'
                : '⚠️ ${tool.name} running low — ${tool.remaining} left',
          ),
          backgroundColor: tool.isExhausted
              ? const Color(0xFF3D0011)
              : const Color(0xFF2D1B00),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ));
      },
      builder: (ctx, state) => Scaffold(
        backgroundColor: const Color(0xFF05080F),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(ctx, state),
            if (state.status == TrackerStatus.loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(
                  color: Color(0xFF00C8E8))),
              )
            else ...[
              if (state.bestToolNow != null)
                _buildSuggestion(state),
              if (state.activeTools.isNotEmpty)
                _buildActiveList(ctx, state),
              if (state.activeTools.isEmpty)
                _buildEmpty(ctx),
              if (state.catalogTools.isNotEmpty)
                _buildCatalog(ctx, state),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 100)),
            ],
          ],
        ),
        floatingActionButton: _buildFAB(ctx),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────
  Widget _buildHeader(BuildContext ctx, TrackerState state) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: const Color(0xFF05080F),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: Color(0xFF3A4A60), size: 18),
        onPressed: () => Navigator.pop(ctx),
      ),
      title: const Text('Free Tier Tracker',
        style: TextStyle(fontFamily: 'Syne', fontSize: 17,
          fontWeight: FontWeight.w800, color: Colors.white)),
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) => _HeaderStats(
            state: state,
            pulseValue: _pulseCtrl.value,
            entranceCtrl: _entranceCtrl,
          ),
        ),
      ),
    );
  }

  // ── SMART SUGGESTION ────────────────────────────────────────
  Widget _buildSuggestion(TrackerState state) {
    final best = state.bestToolNow!;
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) => Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF090D16),
            border: Border.all(
              color: const Color(0xFF00C8E8)
                  .withValues(alpha: 0.18 + 0.12 * _pulseCtrl.value),
            ),
            boxShadow: [BoxShadow(
              color: const Color(0xFF00C8E8)
                  .withValues(alpha: 0.04 + 0.04 * _pulseCtrl.value),
              blurRadius: 20,
            )],
          ),
          child: Row(children: [
            Text(best.emoji,
              style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚡ Best right now',
                  style: TextStyle(fontFamily: 'DM Sans',
                    fontSize: 10, color: Color(0xFF00C8E8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text('${best.name} — ${best.remaining} ${best.unitShort} left',
                  style: const TextStyle(fontFamily: 'Syne',
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: Colors.white)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF00C8E8).withValues(alpha: 0.1),
                border: Border.all(
                  color: const Color(0xFF00C8E8).withValues(alpha: 0.3)),
              ),
              child: const Text('Use it',
                style: TextStyle(fontFamily: 'DM Sans',
                  fontSize: 11, color: Color(0xFF00C8E8),
                  fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
  }

  // ── ACTIVE TOOLS ─────────────────────────────────────────────
  Widget _buildActiveList(BuildContext ctx, TrackerState state) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final tool = state.activeTools[i];
            return TweenAnimationBuilder<double>(
              key: ValueKey(tool.id),
              duration: Duration(milliseconds: 350 + i * 60),
              tween: Tween(begin: 0, end: 1),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) => Transform.translate(
                offset: Offset(0, 20 * (1 - v)),
                child: Opacity(opacity: v.clamp(0, 1), child: child),
              ),
              child: _TrackerCard(
                tool: tool,
                pulseCtrl: _pulseCtrl,
                onLog:    (n) => ctx.read<TrackerBloc>()
                    .add(TrackerUsageLogged(tool.id, count: n)),
                onSet:    (n) => ctx.read<TrackerBloc>()
                    .add(TrackerUsageSet(tool.id, n)),
                onReset:  ()  => ctx.read<TrackerBloc>()
                    .add(TrackerManualReset(tool.id)),
                onPin:    ()  => ctx.read<TrackerBloc>()
                    .add(TrackerToolPinned(tool.id)),
                onRemove: ()  => ctx.read<TrackerBloc>()
                    .add(TrackerToolToggled(tool.id)),
              ),
            );
          },
          childCount: state.activeTools.length,
        ),
      ),
    );
  }

  // ── EMPTY STATE ──────────────────────────────────────────────
  Widget _buildEmpty(BuildContext ctx) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF090D16),
              border: Border.all(color: const Color(0xFF131B27)),
            ),
            child: const Center(
              child: Text('📊', style: TextStyle(fontSize: 34))),
          ),
          const SizedBox(height: 18),
          const Text('Add tools to track',
            style: TextStyle(fontFamily: 'Syne', fontSize: 18,
              fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Tap + below any tool to start tracking',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'DM Sans', fontSize: 13,
              color: Colors.white.withValues(alpha: 0.3))),
        ]),
      ),
    );
  }

  // ── CATALOG ──────────────────────────────────────────────────
  Widget _buildCatalog(BuildContext ctx, TrackerState state) {
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
          child: Text('Add Tools',
            style: TextStyle(fontFamily: 'DM Sans', fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 0.8)),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final tool = state.catalogTools[i];
              return _CatalogCard(
                tool: tool,
                onAdd: () {
                  HapticFeedback.lightImpact();
                  ctx.read<TrackerBloc>()
                      .add(TrackerToolToggled(tool.id));
                },
              );
            },
            childCount: state.catalogTools.length,
          ),
        ),
      ),
    ]);
  }

  // ── FAB ──────────────────────────────────────────────────────
  Widget _buildFAB(BuildContext ctx) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => FloatingActionButton(
        backgroundColor: const Color(0xFF00C8E8),
        onPressed: () => _showAddCustom(ctx),
        child: const Icon(Icons.add,
            color: Color(0xFF05080F), size: 26),
      ),
    );
  }

  void _showAddCustom(BuildContext ctx) {
    final nameCtrl  = TextEditingController();
    final limitCtrl = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF090D16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20, right: 20, top: 20,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xFF1A2336))),
          const SizedBox(height: 20),
          const Text('Add Custom Tool',
            style: TextStyle(fontFamily: 'Syne', fontSize: 17,
              fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 20),
          _inputField(nameCtrl, 'Tool name', Icons.apps),
          const SizedBox(height: 10),
          _inputField(limitCtrl, 'Free limit (e.g. 100)',
            Icons.speed, isNumber: true),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C8E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                ctx.read<TrackerBloc>().add(TrackerCustomToolAdded(
                  name:      nameCtrl.text.trim(),
                  emoji:     '🤖',
                  freeLimit: int.tryParse(limitCtrl.text) ?? 100,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Add Tool',
                style: TextStyle(fontFamily: 'Syne',
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: Color(0xFF05080F))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint,
      IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF0C1019),
        border: Border.all(color: const Color(0xFF131B27)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontFamily: 'DM Sans',
          color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF2E3E54)),
          prefixIcon: Icon(icon,
            color: const Color(0xFF3A4A60), size: 18),
          border: InputBorder.none,
          contentPadding:
            const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ── HEADER STATS ─────────────────────────────────────────────
class _HeaderStats extends StatelessWidget {
  final TrackerState state;
  final double pulseValue;
  final AnimationController entranceCtrl;
  const _HeaderStats({
    required this.state,
    required this.pulseValue,
    required this.entranceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF05080F)),
      child: Stack(children: [
        Positioned(top: -20, right: -20,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF00C8E8)
                    .withValues(alpha: 0.05 + 0.03 * pulseValue),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(bottom: 18, left: 20, right: 20,
          child: AnimatedBuilder(
            animation: entranceCtrl,
            builder: (_, __) {
              final v = Curves.easeOutCubic
                  .transform(entranceCtrl.value.clamp(0.0, 1.0));
              return Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - v)),
                  child: Row(children: [
                    _StatPill(
                      '${state.activeTools.length}',
                      'Tracking',
                      const Color(0xFF00C8E8),
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      '${state.exhaustedTools.length}',
                      'Exhausted',
                      const Color(0xFFFF4F6A),
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      '${state.healthyTools.length}',
                      'Healthy',
                      const Color(0xFF00D68F),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String count, label;
  final Color color;
  const _StatPill(this.count, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: color.withValues(alpha: 0.08),
      border: Border.all(color: color.withValues(alpha: 0.22)),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(count, style: TextStyle(fontFamily: 'Syne',
        fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontFamily: 'DM Sans',
        fontSize: 10, color: Color(0xFF3A4A60),
        fontWeight: FontWeight.w500)),
    ]),
  );
}

// ── TRACKER CARD ─────────────────────────────────────────────
class _TrackerCard extends StatefulWidget {
  final TrackerTool tool;
  final AnimationController pulseCtrl;
  final void Function(int) onLog, onSet;
  final VoidCallback onReset, onPin, onRemove;
  const _TrackerCard({
    required this.tool, required this.pulseCtrl,
    required this.onLog, required this.onSet,
    required this.onReset, required this.onPin,
    required this.onRemove,
  });
  @override State<_TrackerCard> createState() => _TrackerCardState();
}

class _TrackerCardState extends State<_TrackerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _arcCtrl;
  late Animation<double>   _arcAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _arcCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
    _arcAnim = Tween<double>(begin: 0, end: widget.tool.usagePct)
        .animate(CurvedAnimation(
          parent: _arcCtrl, curve: Curves.easeOutCubic));
    _arcCtrl.forward();
  }

  @override
  void didUpdateWidget(_TrackerCard old) {
    super.didUpdateWidget(old);
    if (old.tool.usagePct != widget.tool.usagePct) {
      _arcAnim = Tween<double>(
        begin: _arcAnim.value, end: widget.tool.usagePct,
      ).animate(CurvedAnimation(
        parent: _arcCtrl, curve: Curves.easeOutCubic));
      _arcCtrl.forward(from: 0);
    }
  }

  @override void dispose() { _arcCtrl.dispose(); super.dispose(); }

  Color get _accent => Color(widget.tool.colorHex);

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    final statusColor = tool.isExhausted
        ? const Color(0xFFFF4F6A)
        : tool.isLow
            ? const Color(0xFFF5A623)
            : _accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0B1018),
        border: Border.all(
          color: statusColor.withValues(alpha: 
            tool.isExhausted || tool.isLow ? 0.35 : 0.14),
          width: tool.isExhausted || tool.isLow ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(
          color: statusColor.withValues(alpha: 0.05),
          blurRadius: 16,
        )],
      ),
      child: Column(children: [
        // Main row
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // Arc
            _ArcWidget(
              arcAnim: _arcAnim,
              pulseCtrl: widget.pulseCtrl,
              emoji: tool.emoji,
              color: statusColor,
              isExhausted: tool.isExhausted,
              isLow: tool.isLow,
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(tool.name,
                    style: const TextStyle(fontFamily: 'Syne',
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: Colors.white),
                    overflow: TextOverflow.ellipsis)),
                  if (tool.isPinned)
                    const Icon(Icons.push_pin,
                      color: Color(0xFF00C8E8), size: 13),
                ]),
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: _arcAnim,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: _arcAnim.value,
                      minHeight: 5,
                      backgroundColor: const Color(0xFF131B27),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(children: [
                  Text(
                    tool.isExhausted
                        ? 'Resets in ${tool.countdownLabel}'
                        : '${tool.remaining}/${tool.freeLimit} ${tool.unitShort} left',
                    style: TextStyle(fontFamily: 'DM Sans',
                      fontSize: 11, color: statusColor,
                      fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Text(tool.resetPeriodLabel,
                    style: const TextStyle(fontFamily: 'DM Sans',
                      fontSize: 10, color: Color(0xFF2E3E54))),
                ]),
              ],
            )),
            const SizedBox(width: 10),
            // +1 button
            _TapButton(color: _accent,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onLog(1);
              }),
          ]),
        ),

        // Expand toggle
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(
                color: const Color(0xFF131B27)))),
            child: Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFF2E3E54), size: 18),
          ),
        ),

        // Expanded panel
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: _expanded
              ? _ExpandedPanel(
                  tool: tool, accent: _accent,
                  onLog: widget.onLog, onSet: widget.onSet,
                  onReset: widget.onReset, onPin: widget.onPin,
                  onRemove: widget.onRemove,
                )
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }
}

// ── ARC WIDGET ───────────────────────────────────────────────
class _ArcWidget extends StatelessWidget {
  final Animation<double> arcAnim;
  final AnimationController pulseCtrl;
  final String emoji;
  final Color color;
  final bool isExhausted, isLow;
  const _ArcWidget({
    required this.arcAnim, required this.pulseCtrl,
    required this.emoji, required this.color,
    required this.isExhausted, required this.isLow,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([arcAnim, pulseCtrl]),
      builder: (_, __) => SizedBox(
        width: 54, height: 54,
        child: Stack(alignment: Alignment.center, children: [
          if (isExhausted || isLow)
            Container(
              width: 54 + 6 * pulseCtrl.value,
              height: 54 + 6 * pulseCtrl.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: color.withValues(alpha: 
                    0.12 + 0.08 * pulseCtrl.value),
                  blurRadius: 14,
                )],
              ),
            ),
          CustomPaint(
            size: const Size(54, 54),
            painter: _ArcPainter(
              progress: arcAnim.value, color: color),
          ),
          Text(emoji,
            style: const TextStyle(fontSize: 18)),
        ]),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r  = size.width / 2 - 4;

    canvas.drawCircle(Offset(cx, cy), r,
      Paint()
        ..color = const Color(0xFF131B27)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4);

    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2, 2 * pi * progress, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ── TAP BUTTON ───────────────────────────────────────────────
class _TapButton extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  const _TapButton({required this.color, required this.onTap});
  @override State<_TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<_TapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 100));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp:   (_) { _c.reverse(); widget.onTap(); },
    onTapCancel: () => _c.reverse(),
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Transform.scale(
        scale: 1 - 0.14 * _c.value,
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.color.withValues(alpha: 0.1),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.28)),
          ),
          child: Icon(Icons.add, color: widget.color, size: 19),
        ),
      ),
    ),
  );
}

// ── EXPANDED PANEL ───────────────────────────────────────────
class _ExpandedPanel extends StatefulWidget {
  final TrackerTool tool;
  final Color accent;
  final void Function(int) onLog, onSet;
  final VoidCallback onReset, onPin, onRemove;
  const _ExpandedPanel({
    required this.tool, required this.accent,
    required this.onLog, required this.onSet,
    required this.onReset, required this.onPin,
    required this.onRemove,
  });
  @override State<_ExpandedPanel> createState() => _ExpandedPanelState();
}

class _ExpandedPanelState extends State<_ExpandedPanel> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick +N
          Row(children: [
            Text('Quick:', style: TextStyle(fontFamily: 'DM Sans',
              fontSize: 11, color: Colors.white.withValues(alpha: 0.3))),
            const SizedBox(width: 8),
            for (final n in [2, 5, 10]) ...[
              GestureDetector(
                onTap: () => widget.onLog(n),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: widget.accent.withValues(alpha: 0.08),
                    border: Border.all(
                      color: widget.accent.withValues(alpha: 0.22)),
                  ),
                  child: Text('+$n', style: TextStyle(
                    fontFamily: 'DM Sans', fontSize: 12,
                    color: widget.accent, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ]),
          const SizedBox(height: 10),

          // Set exact
          Row(children: [
            Expanded(child: Container(
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF0C1019),
                border: Border.all(color: const Color(0xFF1A2336)),
              ),
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'DM Sans',
                  color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Set exact usage',
                  hintStyle: TextStyle(
                    color: Color(0xFF2E3E54), fontSize: 12),
                  border: InputBorder.none,
                  contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final v = int.tryParse(_ctrl.text);
                if (v != null) { widget.onSet(v); _ctrl.clear(); }
              },
              child: Container(
                height: 38, width: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: widget.accent.withValues(alpha: 0.1),
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.28)),
                ),
                child: Center(child: Text('Set',
                  style: TextStyle(fontFamily: 'DM Sans',
                    color: widget.accent, fontSize: 13,
                    fontWeight: FontWeight.w600))),
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Actions
          Row(children: [
            _ActionBtn(Icons.refresh, 'Reset',
              const Color(0xFF00D68F), widget.onReset),
            const SizedBox(width: 6),
            _ActionBtn(
              widget.tool.isPinned
                  ? Icons.push_pin
                  : Icons.push_pin_outlined,
              widget.tool.isPinned ? 'Unpin' : 'Pin',
              const Color(0xFF00C8E8), widget.onPin),
            const SizedBox(width: 6),
            _ActionBtn(Icons.remove_circle_outline, 'Remove',
              const Color(0xFFFF4F6A), widget.onRemove),
          ]),

          // Smart tip
          if (widget.tool.isLow || widget.tool.isExhausted) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1A1200),
                border: Border.all(
                  color: const Color(0xFFF5A623).withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                const Text('💡', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.tool.tipWhenLow,
                  style: const TextStyle(fontFamily: 'DM Sans',
                    fontSize: 12, color: Color(0xFFF5A623),
                    height: 1.4))),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label;
  final Color color; final VoidCallback onTap;
  const _ActionBtn(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontFamily: 'DM Sans',
          fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ── CATALOG CARD ─────────────────────────────────────────────
class _CatalogCard extends StatefulWidget {
  final TrackerTool tool;
  final VoidCallback onAdd;
  const _CatalogCard({required this.tool, required this.onAdd});
  @override State<_CatalogCard> createState() => _CatalogCardState();
}

class _CatalogCardState extends State<_CatalogCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final color = Color(widget.tool.colorHex);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) { setState(() => _pressed = false); widget.onAdd(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        transform: Matrix4.identity()
          ..scale(_pressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0B1018),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.tool.emoji,
                  style: const TextStyle(fontSize: 22)),
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.1),
                    border: Border.all(color: color.withValues(alpha: 0.28)),
                  ),
                  child: Icon(Icons.add, color: color, size: 13),
                ),
              ],
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.tool.name,
                  style: const TextStyle(fontFamily: 'Syne',
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: Colors.white),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${widget.tool.freeLimit} ${widget.tool.unitShort} free',
                  style: const TextStyle(fontFamily: 'DM Sans',
                    fontSize: 10, color: Color(0xFF3A4A60))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
