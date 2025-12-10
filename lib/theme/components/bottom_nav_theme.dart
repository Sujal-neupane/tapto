import 'package:flutter/material.dart';
import '../colors.dart';

class AppBottomNavTheme {
  static const BottomNavigationBarThemeData light =
      BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      );
}
