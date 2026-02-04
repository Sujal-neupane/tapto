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
      print('🌙 Dark Mode Loaded: ${state == ThemeMode.dark}');
    });
  }

  void toggle() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    final isDarkMode = newMode == ThemeMode.dark;
    print('🌙 Dark Mode Toggled: $isDarkMode');
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkMode', isDarkMode);
      print('✅ Dark Mode Saved: $isDarkMode');
    });
  }

  void setLight() {
    state = ThemeMode.light;
    print('🌙 Dark Mode Set to Light');
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkMode', false);
      print('✅ Dark Mode Saved: false');
    });
  }

  void setDark() {
    state = ThemeMode.dark;
    print('🌙 Dark Mode Set to Dark');
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkMode', true);
      print('✅ Dark Mode Saved: true');
    });
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (_) => ThemeNotifier(),
);
