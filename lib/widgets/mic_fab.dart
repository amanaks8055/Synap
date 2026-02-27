import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MicFAB extends StatefulWidget {
  final VoidCallback onTap;
  const MicFAB({super.key, required this.onTap});
  @override
  State<MicFAB> createState() => _MicFABState();
}

class _MicFABState extends State<MicFAB> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => AnimatedScale(
          scale: _pressed ? 0.91 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: SizedBox(
            width: 72, height: 72,
            child: Stack(alignment: Alignment.center, children: [
              // Outer pulse ring
              Transform.scale(
                scale: 1.0 + 0.16 * _ctrl.value,
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00C8E8)
                        .withValues(alpha: 0.07 + 0.06 * _ctrl.value),
                  ),
                ),
              ),
              // Inner border ring
              Container(
                width: 62, height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00C8E8)
                        .withValues(alpha: 0.18 + 0.14 * _ctrl.value),
                    width: 1.5,
                  ),
                ),
              ),
              // Main cyan button
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00C8E8),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF00C8E8)
                        .withValues(alpha: 0.22 + 0.14 * _ctrl.value),
                    blurRadius: 20, spreadRadius: 2,
                  )],
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: Color(0xFF05080F), size: 24,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
