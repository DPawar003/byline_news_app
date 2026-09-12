import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  static const Color lightPaper = Color(0xFFF7F6F3);
  static const Color lightInk = Color(0xFF16171A);
  static const Color lightInkSoft = Color(0xFF6B6D74);
  static const Color lightSignal = Color(0xFFB08D3F); // Brass accent
  static const Color lightHairline = Color(0xFFE4E2DC);

  static const Color darkBackground = Color(0xFF121214);
  static const Color darkInk = Color(0xFFECEBE7);
  static const Color darkInkSoft = Color(0xFF9B9A97);
  static const Color darkSignal = Color(0xFFD9A03D);
  static const Color darkHairline = Color(0xFF2A2A2D);

  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightPaper,
      colorScheme: const ColorScheme.light(
        surface: lightPaper,
        onSurface: lightInk,
        primary: lightInk,
        onPrimary: lightPaper,
        secondary: lightSignal,
        outline: lightHairline,
      ),
      dividerColor: lightHairline,
      dividerTheme: const DividerThemeData(
        color: lightHairline,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightPaper,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: lightInk),
        titleTextStyle: GoogleFonts.newsreader(
          color: lightInk,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.newsreader(
          color: lightInk,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.15,
        ),
        titleLarge: GoogleFonts.newsreader(
          color: lightInk,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 1.25,
        ),
        titleMedium: GoogleFonts.newsreader(
          color: lightInk,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        bodyLarge: GoogleFonts.inter(
          color: lightInk,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: lightInkSoft,
          fontSize: 14,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.newsreader(
          color: lightInkSoft,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightPaper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: lightHairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: lightHairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: lightInk, width: 1.5),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: lightInk,
        unselectedLabelColor: lightInkSoft,
        indicatorColor: lightSignal,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: darkBackground,
        onSurface: darkInk,
        primary: darkInk,
        onPrimary: darkBackground,
        secondary: darkSignal,
        outline: darkHairline,
      ),
      dividerColor: darkHairline,
      dividerTheme: const DividerThemeData(
        color: darkHairline,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: darkInk),
        titleTextStyle: GoogleFonts.newsreader(
          color: darkInk,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.newsreader(
          color: darkInk,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.15,
        ),
        titleLarge: GoogleFonts.newsreader(
          color: darkInk,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 1.25,
        ),
        titleMedium: GoogleFonts.newsreader(
          color: darkInk,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        bodyLarge: GoogleFonts.inter(
          color: darkInk,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: darkInkSoft,
          fontSize: 14,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.newsreader(
          color: darkInkSoft,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: darkHairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: darkHairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: darkInk, width: 1.5),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: darkInk,
        unselectedLabelColor: darkInkSoft,
        indicatorColor: darkSignal,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
    );
  }
}
