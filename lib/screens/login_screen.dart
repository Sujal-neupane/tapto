import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_input_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool showPassword = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
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

              const Text('Welcome Back', style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Sign in to continue',
                style: AppTextStyles.subHeading,
              ),

              const SizedBox(height: AppSpacing.lg),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: email,
                      decoration: AppInputTheme.input(
                        'Enter your email',
                        Icons.email,
                      ),
                      validator: (v) =>
                          v != null && v.contains('@') ? null : 'Invalid email',
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
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => showPassword = !showPassword),
                        ),
                      ),
                      validator: (v) => v != null && v.length >= 6
                          ? null
                          : 'Min 6 characters',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text(
                          'Sign In',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
