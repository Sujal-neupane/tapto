import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../app/theme/app_spacing.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String?;
    final screenSize = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;
    final isTablet = screenSize.width > 600;
    final padding = (screenSize.width * 0.05).toDouble(); // 5% of width
    final iconSize = min(80.0, screenSize.width * 0.15); // Max 80, or 15% of width
    final titleFontSize = min(24.0, 20 * textScaler.scale(1.0) * (isTablet ? 1.1 : 1.0));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            Icon(Icons.message_outlined, size: iconSize, color: AppColors.primary),

            const SizedBox(height: AppSpacing.md),

            Text('Verify OTP', style: AppTextStyles.heading.copyWith(fontSize: titleFontSize)),

            const SizedBox(height: AppSpacing.xs),

            Text('Code sent to $email', style: AppTextStyles.subHeading),

            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (_) => SizedBox(
                  width: 45,
                  child: TextField(
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(counterText: ''),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/dashboard'),
                child: const Text('Verify', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
