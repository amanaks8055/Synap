import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── POE-EXACT COLOR PALETTE ──────────────────────
class SynapColors {
  // Backgrounds (POE exact)
  static const Color bgPrimary = Color(0xFF181818);
  static const Color bgSecondary = Color(0xFF222222);
  static const Color bgTertiary = Color(0xFF2A2A2A);
  static const Color bgCard = Color(0xFF262626);

  // Accent (POE purple)
  static const Color accent = Color(0xFF7B68EE);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentOrange = Color(0xFFF97316);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textMuted = Color(0xFF666666);

  // Border
  static const Color border = Color(0xFF333333);
  static const Color divider = Color(0xFF2A2A2A);
}

// ─── THEME ────────────────────────────────────────
class SynapTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SynapColors.bgPrimary,
      primaryColor: SynapColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: SynapColors.accent,
        secondary: SynapColors.accentGreen,
        surface: SynapColors.bgSecondary,
        error: SynapColors.accentRed,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: SynapColors.textPrimary),
          bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: SynapColors.textPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SynapColors.textPrimary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: SynapColors.textSecondary),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SynapColors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SynapColors.bgCard,
        contentTextStyle: const TextStyle(color: SynapColors.textPrimary, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
