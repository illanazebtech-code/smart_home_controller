import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceAlt = Color(0xFF1A2235);
  static const Color card = Color(0xFF162032);
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentDim = Color(0xFF00A882);
  static const Color accentGlow = Color(0x3300D4AA);
  static const Color warning = Color(0xFFFFB347);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color textPrimary = Color(0xFFEDF2FF);
  static const Color textSecondary = Color(0xFF8B9EC7);
  static const Color textMuted = Color(0xFF4A5568);
  static const Color border = Color(0xFF1E2D45);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentDim,
        surface: surface,
        error: danger,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      useMaterial3: true,
      dividerTheme: const DividerThemeData(color: border),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
    );
  }
}
