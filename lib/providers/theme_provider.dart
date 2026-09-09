import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  // TikVply opens in the branded light theme unless the user explicitly chooses another mode.
  AppThemeMode _mode = AppThemeMode.light;

  AppThemeMode get mode => _mode;
  bool get isDarkMode => _mode == AppThemeMode.dark;
  ThemeMode get themeMode {
    switch (_mode) {
      case AppThemeMode.light: return ThemeMode.light;
      case AppThemeMode.dark: return ThemeMode.dark;
      case AppThemeMode.system: return ThemeMode.system;
    }
  }

  ThemeProvider() { _loadTheme(); }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    // Missing preference = branded light theme.
    _mode = value == null
        ? AppThemeMode.light
        : AppThemeMode.values.firstWhere((item) => item.name == value, orElse: () => AppThemeMode.light);
    notifyListeners();
  }

  Future<void> setMode(AppThemeMode value) async {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value.name);
  }

  Future<void> toggleTheme() async => setMode(_mode == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark);
  Future<void> setDarkMode(bool value) async => setMode(value ? AppThemeMode.dark : AppThemeMode.light);
}
