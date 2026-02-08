import 'package:flutter/material.dart';

/// Global app state provider for theme mode and locale.
class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  /// Current theme mode (light or dark).
  ThemeMode get themeMode => _themeMode;

  /// Current locale.
  Locale get locale => _locale;

  /// Whether dark mode is active.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggle between light and dark theme.
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Set app locale by language code.
  void setLocale(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
