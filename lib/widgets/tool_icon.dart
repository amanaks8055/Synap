import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Play Store safe tool icon — uses first letter with category color.
/// No copyrighted logos.
class ToolIcon extends StatelessWidget {
  final String name;
  final String categoryId;
  final double size;
  final double fontSize;
  final double radius;

  const ToolIcon({
    super.key,
    required this.name,
    required this.categoryId,
    this.size = 48,
    this.fontSize = 20,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  LinearGradient get _gradient {
    switch (categoryId) {
      case 'chat':
        return const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)]);
      case 'writing':
        return const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]);
      case 'image':
        return const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)]);
      case 'code':
        return const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0D9488)]);
      case 'video':
        return const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
      case 'audio':
        return const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]);
      case 'research':
        return const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
      default:
        return LinearGradient(colors: [SynapColors.accent, SynapColors.accent]);
    }
  }
}
