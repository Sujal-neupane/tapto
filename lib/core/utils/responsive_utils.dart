import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class ResponsiveUtils {
  /// Breakpoint for tablet screens
  static const double tabletBreakpoint = 600.0;

  /// Breakpoint for desktop screens
  static const double desktopBreakpoint = 1200.0;

  /// Check if the screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  /// Check if the screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// Check if the screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    }
    return const EdgeInsets.all(16.0);
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isDesktop(context)) {
      return 400.0;
    } else if (isTablet(context)) {
      return screenWidth * 0.7;
    }
    return screenWidth * 0.85;
  }

  /// Get responsive card height
  static double getCardHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (isDesktop(context)) {
      return 500.0;
    } else if (isTablet(context)) {
      return screenHeight * 0.5;
    }
    return screenHeight * 0.6;
  }

  /// Get grid cross axis count based on screen size
  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 2;
    }
    return 1;
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isTablet(context) || isDesktop(context)) {
      return baseSize * 1.1;
    }
    return baseSize;
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    if (isTablet(context)) {
      return baseSize * 1.2;
    } else if (isDesktop(context)) {
      return baseSize * 1.4;
    }
    return baseSize;
  }

  /// Get max content width for centering on large screens
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200.0;
    } else if (isTablet(context)) {
      return 800.0;
    }
    return double.infinity;
  }
}
