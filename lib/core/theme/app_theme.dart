import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryAmber = Color(0xFFF59E0B);
  static const Color primaryDarkAmber = Color(0xFFD97706);
  static const Color skyTurquoise = Color(0xFF0EA5E9);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color coralRed = Color(0xFFF43F5E);
  static const Color sunnyYellow = Color(0xFFFBBF24);
  static const Color violetPurple = Color(0xFF8B5CF6);
  static const Color softBackground = Color(0xFFF8FAFC);
  static const Color surfaceCard = Colors.white;

  static ThemeData get lightTheme {
    final fontName = GoogleFonts.nunito().fontFamily;
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontName,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAmber,
        primary: primaryAmber,
        secondary: skyTurquoise,
        tertiary: emeraldGreen,
        surface: surfaceCard,
      ),
      scaffoldBackgroundColor: softBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: const Color(0xFF475569),
          height: 1.45,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFEA580C),
          textStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

