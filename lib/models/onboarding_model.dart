import 'package:flutter/material.dart';

class OnboardingModel {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

/// Static data class containing all onboarding pages
/// This makes it easy to modify content without touching the UI logic
class OnboardingData {
  static const List<OnboardingModel> pages = [
    OnboardingModel(
      title: 'Swipe Right to Buy',
      description:
          'Found something you love? Swipe right to add it to your cart and it\'s yours!',
      icon: Icons.shopping_cart_outlined,
      backgroundColor: Color(0xFFE3F2FD), // Light blue
      iconColor: Color(0xFF2196F3), // Blue
    ),
    OnboardingModel(
      title: 'Swipe Left to Skip',
      description: 'Not interested? Swipe left to see the next amazing product',
      icon: Icons.close,
      backgroundColor: Color(0xFFF5F5F5), // Light grey
      iconColor: Color(0xFF757575), // Grey
    ),
    OnboardingModel(
      title: 'Swipe up for Details',
      description:
          'Want to know more? Swipe up to view full product details, reviews, and sizes',
      icon: Icons.arrow_upward,
      backgroundColor: Color(0xFFE0F7FA), // Light cyan
      iconColor: Color(0xFF00BCD4), // Cyan
    ),
    OnboardingModel(
      title: 'Double-Tap to Save',
      description:
          'Love it but not ready to buy? Double-tap to add items to your wishlist',
      icon: Icons.favorite_outline,
      backgroundColor: Color(0xFFFCE4EC), // Light pink
      iconColor: Color(0xFFE91E63), // Pink
    ),
  ];
}
