import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';

/// Reusable widget for a single onboarding page
/// This follows the DRY principle - we create one widget and reuse it
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingModel page;
  final VoidCallback? onIconTap; // For demonstration purposes

  const OnboardingPageWidget({super.key, required this.page, this.onIconTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with background
          GestureDetector(
            onTap: onIconTap,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: page.backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(page.icon, size: 56, color: page.iconColor),
            ),
          ),

          const SizedBox(height: 48),

          // Title text
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description text
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
