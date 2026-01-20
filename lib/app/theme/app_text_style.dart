import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const subHeading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(fontSize: 14, color: AppColors.textPrimary);

  static const hint = TextStyle(fontSize: 14, color: AppColors.textSecondary);

  static const link = TextStyle(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
  );

  static const appBar = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
}
