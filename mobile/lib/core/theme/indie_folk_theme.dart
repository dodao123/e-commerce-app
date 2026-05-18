import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IndieFolkTheme {
  // Colors
  static Color primary(bool isDark) => isDark ? const Color(0xFFF7EDD6) : const Color(0xFF1E1A13);
  static Color secondary(bool isDark) => isDark ? const Color(0xFFA9A090) : const Color(0xFF877C68);
  static Color tertiary(bool isDark) => isDark ? const Color(0xFFD6975A) : const Color(0xFFC27C38);
  static Color neutral(bool isDark) => isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEFE6D0);
  static Color surface(bool isDark) => isDark ? const Color(0xFF252540) : const Color(0xFFF7EDD6);
  static Color onPrimary(bool isDark) => isDark ? const Color(0xFF1E1A13) : const Color(0xFFF7EDD6);

  // Typography
  static TextStyle display(bool isDark) {
    return GoogleFonts.fraunces(
      fontSize: 76.0,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.02 * 76.0,
      color: primary(isDark),
    );
  }

  static TextStyle h1(bool isDark) {
    return GoogleFonts.fraunces(
      fontSize: 38.4,
      fontWeight: FontWeight.w400,
      color: primary(isDark),
    );
  }

  static TextStyle body(bool isDark) {
    return GoogleFonts.lora(
      fontSize: 16.32,
      height: 1.75,
      color: primary(isDark),
    );
  }

  static TextStyle label(bool isDark) {
    return GoogleFonts.lora(
      fontSize: 12.16,
      letterSpacing: 0.18 * 12.16,
      color: primary(isDark),
    );
  }
}
