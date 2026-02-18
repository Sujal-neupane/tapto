import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme notifier that manages ThemeMode with persistence
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    SharedPreferences.getInstance().then((prefs) {
      final isDarkMode = prefs.getBool('isDarkMode') ?? false;
      state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggle() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    final isDarkMode = newMode == ThemeMode.dark;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkMode', isDarkMode);
    });
  }

  void setLight() {
    state = ThemeMode.light;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkMode', false);
    });
  }

  void setDark() {
    state = ThemeMode.dark;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkMode', true);
    });
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (_) => ThemeNotifier(),
);
