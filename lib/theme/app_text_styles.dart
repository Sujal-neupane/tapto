import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String fontPrimary = 'Geom';
  static const String fontSecondary = 'Inter';

  static const heading = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    fontFamily: fontPrimary,
    color: AppColors.primary,
  );

  static const subHeading = TextStyle(
    fontSize: 14,
    fontFamily: fontSecondary,
    color: AppColors.textSecondary,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontFamily: fontSecondary,
    color: AppColors.textPrimary,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontFamily: fontSecondary,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle? get appBar => null;

  static TextStyle? get link => null;

  static TextStyle? get hint => null;

  static TextStyle? get caption => null;
}
