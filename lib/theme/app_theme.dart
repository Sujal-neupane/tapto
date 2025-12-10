import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'components/appbar_theme.dart';
import 'components/bottom_nav_theme.dart';
import 'components/button_theme.dart';
import 'components/input_theme.dart';
import 'components/card_theme.dart';
import 'components/icon_theme.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.background,

    fontFamily: "YourFontName", // <-- Set your custom font here

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),

    textTheme: const TextTheme(
      headlineLarge: AppTypography.h1,
      headlineMedium: AppTypography.h2,
      headlineSmall: AppTypography.h3,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.bodyLight,
      labelSmall: AppTypography.caption,
    ),

    appBarTheme: AppAppBarTheme.light,
    bottomNavigationBarTheme: AppBottomNavTheme.light,
    inputDecorationTheme: AppInputTheme.light,
    cardTheme: AppCardTheme.light,
    iconTheme: AppIconTheme.light,

    elevatedButtonTheme: ElevatedButtonThemeData(style: AppButtonTheme.primary),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppButtonTheme.secondary,
    ),
  );
}
