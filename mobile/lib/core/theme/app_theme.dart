import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application theme with light and dark variants.
class AppTheme {
  AppTheme._();

  /// Light theme configuration.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorSchemeSeed: AppColors.primary,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  /// Dark theme configuration.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: DarkColors.background,
      colorSchemeSeed: AppColors.primary,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
