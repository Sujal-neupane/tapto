import 'package:flutter/material.dart';
import '../colors.dart';
import '../typography.dart';

class AppAppBarTheme {
  static AppBarTheme light = AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    titleTextStyle: AppTypography.h3,
  );
}
