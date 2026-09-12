import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  /// Custom TextStyle for AppTextField
  static TextStyle get appTextField => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      );

  /// Custom TextStyle for AppButton
  static TextStyle get appButton => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      );

  /// Editorial Display Typography
  static TextStyle get displayLarge => GoogleFonts.newsreader(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        height: 1.15,
      );

  static TextStyle get titleLarge => GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        height: 1.25,
      );

  static TextStyle get titleMedium => GoogleFonts.newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      );

  static TextStyle get labelSmall => GoogleFonts.newsreader(
        fontSize: 13,
        fontStyle: FontStyle.italic,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );
}
