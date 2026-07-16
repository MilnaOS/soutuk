import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant, tailored dark mode color system
  static const Color background = Color(0xFF0A0C16);
  static const Color surface = Color(0xFF13172E);
  static const Color surfaceGlass = Color(0x7F181C3F);
  static const Color borderGlass = Color(0x3F00F2FE);

  static const Color primary = Color(0xFF00F2FE); // Neon Teal
  static const Color secondary = Color(0xFF9D4EDD); // Vibrant Magenta-Violet
  static const Color accent = Color(0xFF4EA8DE); // Electric Blue
  
  static const Color success = Color(0xFF06D6A0); // Glowing Mint
  static const Color warning = Color(0xFFFFB703); // Amber Hazard
  static const Color error = Color(0xFFEF476F); // Crimson Alert

  static const Color textPrimary = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFFADB5BD);

  // Gradient definitions for premium look
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient glassGradient = LinearGradient(
    colors: [Color(0x1F1A1F3E), Color(0x0A0F1123)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: primary,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Shadow details for premium card overlays
  static List<BoxShadow> get neonGlow {
    return [
      BoxShadow(
        color: primary.withOpacity(0.15),
        blurRadius: 16,
        spreadRadius: -2,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static Decoration get glassCardDecoration {
    return BoxDecoration(
      color: surfaceGlass,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: borderGlass.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
