import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_input_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();

  void _sendOtp() {
    if (email.text.contains('@')) {
      Navigator.pushNamed(context, '/otp', arguments: email.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.lg),

            Icon(Icons.lock_reset, size: 80, color: AppColors.primary),

            const SizedBox(height: AppSpacing.md),

            const Text('Forgot Password', style: AppTextStyles.heading),

            const SizedBox(height: AppSpacing.xs),

            const Text(
              'Enter your email to receive OTP',
              style: AppTextStyles.subHeading,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.lg),

            TextField(
              controller: email,
              decoration: AppInputTheme.input('Email address', Icons.email),
            ),

            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _sendOtp();
                },
                //
                child: const Text('Send OTP', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
