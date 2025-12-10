import 'package:flutter/material.dart';
import '../colors.dart';
import '../sizes.dart';
import '../typography.dart';

class AppButtonTheme {
  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, AppSizes.inputHeight),
    textStyle: AppTypography.body.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
    ),
  );

  static final ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
    minimumSize: const Size(double.infinity, AppSizes.inputHeight),
    textStyle: AppTypography.body,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
    ),
  );
}
