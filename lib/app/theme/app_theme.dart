import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.surface,
    primaryColor: AppColors.primary,
    canvasColor: AppColors.background,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(backgroundColor: AppColors.primary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppDarkColors.darkSurface,
    primaryColor: AppDarkColors.darkPrimary,
    canvasColor: AppDarkColors.darkBackground,
    colorScheme: ColorScheme.dark(
      primary: AppDarkColors.darkPrimary,
      secondary: AppDarkColors.darkPrimary,
      surface: AppDarkColors.darkSurface,
      error: AppDarkColors.darkError,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppDarkColors.darkTextPrimary,
      onError: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppDarkColors.darkPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDarkColors.darkPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkColors.darkPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
