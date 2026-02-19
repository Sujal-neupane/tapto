import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapto/core/services/storage/user_session_service.dart';

// Theme notifier that manages ThemeMode with persistence
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }
  final SharedPreferences _prefs;

  void _loadTheme() {
    final savedThemeMode = _prefs.getString('themeMode');
    if (savedThemeMode != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
      return;
    }

    // Backward compatibility with older isDarkMode boolean.
    final isDarkMode = _prefs.getBool('isDarkMode');
    if (isDarkMode != null) {
      state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      return;
    }

    state = ThemeMode.system;
  }

  void _persistThemeMode(ThemeMode mode) {
    _prefs.setString('themeMode', mode.name);
    _prefs.setBool('isDarkMode', mode == ThemeMode.dark);
  }

  void toggle() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    _persistThemeMode(newMode);
  }

  void setLight() {
    state = ThemeMode.light;
    _persistThemeMode(ThemeMode.light);
  }

  void setDark() {
    state = ThemeMode.dark;
    _persistThemeMode(ThemeMode.dark);
  }

  void setSystem() {
    state = ThemeMode.system;
    _persistThemeMode(ThemeMode.system);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(ref.watch(sharedPreferencesProvider)),
);
