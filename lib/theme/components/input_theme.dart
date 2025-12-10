import 'package:flutter/material.dart';
import '../colors.dart';
import '../sizes.dart';
import '../typography.dart';

class AppInputTheme {
  static InputDecorationTheme light = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,

    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

    hintStyle: AppTypography.bodyLight,

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      borderSide: const BorderSide(color: AppColors.border),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      borderSide: const BorderSide(color: AppColors.border),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      borderSide: const BorderSide(color: AppColors.error),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),

    errorStyle: const TextStyle(
      color: AppColors.error,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );
}
