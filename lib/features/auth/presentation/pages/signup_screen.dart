import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_input_theme.dart';
import 'package:tapto/core/widgets/preference_chip.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool showPassword = false;
  String category = '';

  @override
  Widget build(BuildContext context) {
    String preference = '';
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            children: [
              Image.asset('assets/images/logo1.png', height: 100),
              const SizedBox(height: AppSpacing.sm),

              const Text('Create Account', style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Sign up to start shopping',
                style: AppTextStyles.subHeading,
              ),

              const SizedBox(height: AppSpacing.lg),

              TextFormField(
                controller: name,
                decoration: AppInputTheme.input(
                  'Enter your name',
                  Icons.person,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: email,
                decoration: AppInputTheme.input(
                  'Enter your email',
                  Icons.email,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: password,
                obscureText: !showPassword,
                decoration: AppInputTheme.input(
                  'Enter your password',
                  Icons.lock,
                  suffix: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => showPassword = !showPassword),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              const Text(
                'Shopping Preference',
                style: AppTextStyles.subHeading,
              ),
              const SizedBox(height: AppSpacing.sm),

              Row(
                children: [
                  PreferenceChip(
                    label: "Men's Fashion",
                    selected: preference == 'Men',
                    onTap: () => setState(() => preference = 'Men'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  PreferenceChip(
                    label: "Women's Fashion",
                    selected: preference == 'Women',
                    onTap: () => setState(() => preference = 'Women'),
                  ),
                ],
              ),

              // inside signup form
              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Sign Up', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
