import 'package:flutter/material.dart';

/// Color palette matching the product store design mockup.
class AppColors {
  AppColors._();

  /// Primary accent — warm coral/orange.
  static const Color primary = Color(0xFFEF6C4A);

  /// Dark card background — almost black (fallback).
  static const Color darkCard = Color(0xFF2D2D2D);

  /// Dark card gradient — light gray to light red.
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8E8E8), // Light gray
      Color(0xFFFFD6D6), // Light red (soft pink-red)
    ],
  );

  /// Page background — soft white (fallback for non-gradient).
  static const Color background = Color(0xFFF5F5F5);

  /// Background gradient — cream yellow to soft pink.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF9E6), // Cream yellow
      Color(0xFFFFE4EC), // Soft pink
    ],
  );

  /// Pure white for card surfaces.
  static const Color surface = Color(0xFFFFFFFF);

  /// Primary text — dark.
  static const Color textPrimary = Color(0xFF1D1D1D);

  /// Secondary text — grey.
  static const Color textSecondary = Color(0xFF9E9E9E);

  /// Star rating color.
  static const Color starYellow = Color(0xFFFFB800);

  /// Add button background.
  static const Color addButton = Color(0xFF2D2D2D);
}

/// Dark mode color palette — dark gray with light purple accent.
class DarkColors {
  DarkColors._();

  /// Dark mode card background.
  static const Color darkCard = Color(0xFF2A2A3D);

  /// Dark card gradient — dark gray to dark purple.
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D2D3F), // Dark gray-purple
      Color(0xFF3D2D4A), // Subtle dark purple
    ],
  );

  /// Dark mode page background.
  static const Color background = Color(0xFF1A1A2E);

  /// Dark mode background gradient — dark gray-purple.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A2E), // Deep dark blue-gray
      Color(0xFF16132B), // Dark purple-black
    ],
  );

  /// Dark mode card surface — dark gray-purple.
  static const Color surface = Color(0xFF252540);

  /// Dark mode primary text — light.
  static const Color textPrimary = Color(0xFFEEEEEE);

  /// Dark mode secondary text — muted.
  static const Color textSecondary = Color(0xFF888899);

  /// Dark mode add button — light on dark.
  static const Color addButton = Color(0xFFEEEEEE);
}
