import 'package:flutter/material.dart';
import '../sizes.dart';

// Return CardThemeData (for SDKs that expect CardThemeData)
class AppCardTheme {
  static CardThemeData light = CardThemeData(
    color: Colors.white,
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.05),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    ),
  );
}
