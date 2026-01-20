import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
  final TextStyle headingLarge;
  final TextStyle headingMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;

  AppThemeExtension({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.headingLarge,
    required this.headingMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
  });

  @override
  AppThemeExtension copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    TextStyle? headingLarge,
    TextStyle? headingMedium,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
  }) {
    return AppThemeExtension(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      headingLarge: headingLarge ?? this.headingLarge,
      headingMedium: headingMedium ?? this.headingMedium,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      primaryColor:
          Color.lerp(primaryColor, other.primaryColor, t) ?? primaryColor,
      secondaryColor:
          Color.lerp(secondaryColor, other.secondaryColor, t) ?? secondaryColor,
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      surfaceColor:
          Color.lerp(surfaceColor, other.surfaceColor, t) ?? surfaceColor,
      errorColor: Color.lerp(errorColor, other.errorColor, t) ?? errorColor,
      successColor:
          Color.lerp(successColor, other.successColor, t) ?? successColor,
      warningColor:
          Color.lerp(warningColor, other.warningColor, t) ?? warningColor,
      headingLarge:
          TextStyle.lerp(headingLarge, other.headingLarge, t) ?? headingLarge,
      headingMedium:
          TextStyle.lerp(headingMedium, other.headingMedium, t) ??
          headingMedium,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t) ?? bodyLarge,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t) ?? bodyMedium,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t) ?? bodySmall,
    );
  }
}

extension AppThemeExtensionContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
