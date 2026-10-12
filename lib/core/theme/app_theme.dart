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
    final fontName = GoogleFonts.comfortaa().fontFamily;
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
    );
  }
}

