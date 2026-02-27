import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/tracker/tracker_bloc.dart';
import '../../blocs/tracker/tracker_event.dart';
import '../../blocs/tracker/tracker_state.dart';
import '../../models/tracker_tool.dart';

class TrackerHomeWidget extends StatefulWidget {
  const TrackerHomeWidget({super.key});
  @override State<TrackerHomeWidget> createState() => _State();
}

class _State extends State<TrackerHomeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackerBloc, TrackerState>(
      builder: (ctx, state) {
        if (state.activeTools.isEmpty) return _empty(ctx);
        return _card(ctx, state);
      },
    );
  }

  Widget _card(BuildContext ctx, TrackerState state) {
    final tools     = state.activeTools.take(3).toList();
    final hasAlert  = state.lowTools.isNotEmpty ||
                      state.exhaustedTools.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(ctx, '/tracker'),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF090D16),
            border: Border.all(
              color: hasAlert
                  ? const Color(0xFFF5A623).withValues(alpha:
                      0.22 + 0.12 * _pulse.value)
                  : const Color(0xFF131B27),
              width: hasAlert ? 1.5 : 1,
            ),
          ),
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF00C8E8).withValues(alpha: 0.08),
                  ),
                  child: const Text('⚡ Free Tier Tracker',
                    style: TextStyle(fontFamily: 'Syne',
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: Color(0xFF00C8E8))),
                ),
                const Spacer(),
                if (hasAlert)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: const Color(0xFFF5A623).withValues(alpha: 0.1),
                      border: Border.all(
                        color: const Color(0xFFF5A623).withValues(alpha: 0.25)),
                    ),
                    child: const Text('⚠️ Alert',
                      style: TextStyle(fontFamily: 'DM Sans',
                        fontSize: 10, color: Color(0xFFF5A623),
                        fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios,
                  color: Color(0xFF2E3E54), size: 11),
              ]),
            ),

            // Tool rows
            ...tools.map((t) => _MiniRow(
              tool: t,
              onTap: () {
                HapticFeedback.lightImpact();
                ctx.read<TrackerBloc>()
                    .add(TrackerUsageLogged(t.id));
              },
            )),

            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }

  Widget _empty(BuildContext ctx) => GestureDetector(
    onTap: () => Navigator.pushNamed(ctx, '/tracker'),
    child: Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF090D16),
        border: Border.all(color: const Color(0xFF131B27)),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: const Color(0xFF00C8E8).withValues(alpha: 0.07),
            border: Border.all(
              color: const Color(0xFF00C8E8).withValues(alpha: 0.18)),
          ),
          child: const Center(
            child: Text('📊', style: TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Track Free Tiers',
              style: TextStyle(fontFamily: 'Syne',
                fontSize: 13, fontWeight: FontWeight.w700,
                color: Colors.white)),
            const SizedBox(height: 2),
            Text('Know how much ChatGPT, Claude & more you have left',
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 11,
                color: Colors.white.withValues(alpha: 0.3), height: 1.4)),
          ],
        )),
        const Icon(Icons.arrow_forward_ios,
          color: Color(0xFF2E3E54), size: 13),
      ]),
    ),
  );
}

class _MiniRow extends StatelessWidget {
  final TrackerTool tool;
  final VoidCallback onTap;
  const _MiniRow({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(tool.colorHex);
    final statusColor = tool.isExhausted
        ? const Color(0xFFFF4F6A)
        : tool.isLow
            ? const Color(0xFFF5A623)
            : color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Row(children: [
        Text(tool.emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 9),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(tool.name,
                style: const TextStyle(fontFamily: 'DM Sans',
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: Colors.white)),
              const Spacer(),
              Text(
                tool.isExhausted
                    ? tool.countdownLabel
                    : '${tool.remaining}/${tool.freeLimit}',
                style: TextStyle(fontFamily: 'DM Sans',
                  fontSize: 11, color: statusColor,
                  fontWeight: FontWeight.w600),
              ),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: tool.usagePct,
                minHeight: 3,
                backgroundColor: const Color(0xFF131B27),
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
          ],
        )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: color.withValues(alpha: 0.08),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Icon(Icons.add, color: color, size: 15),
          ),
        ),
      ]),
    );
  }
}
