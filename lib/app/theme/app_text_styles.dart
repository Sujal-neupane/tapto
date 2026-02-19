import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontPrimary = 'Geom';
  static const String fontSecondary = 'Inter';

  static const heading = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    fontFamily: fontPrimary,
  );

  static const subHeading = TextStyle(fontSize: 14, fontFamily: fontSecondary);

  static const body = TextStyle(fontSize: 14, fontFamily: fontSecondary);

  static const button = TextStyle(
    fontSize: 16,
    fontFamily: fontSecondary,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const appBar = TextStyle(
    fontSize: 18,
    fontFamily: fontPrimary,
    fontWeight: FontWeight.w700,
  );

  static const link = TextStyle(
    fontSize: 14,
    fontFamily: fontSecondary,
    fontWeight: FontWeight.w600,
  );

  static const hint = TextStyle(fontSize: 14, fontFamily: fontSecondary);

  static const caption = TextStyle(fontSize: 12, fontFamily: fontSecondary);

  static const h3 = TextStyle(
    fontSize: 20,
    fontFamily: fontPrimary,
    fontWeight: FontWeight.w700,
  );
}
