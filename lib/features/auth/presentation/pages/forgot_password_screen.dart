import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tapto/app/routes/app_routes.dart';
import 'package:tapto/app/theme/app_colors.dart';
import 'package:tapto/app/theme/app_text_styles.dart';
import 'package:tapto/features/auth/presentation/state/auth_state.dart';
import 'package:tapto/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:tapto/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:tapto/features/auth/presentation/pages/reset_password_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (!mounted) return;
      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'errorOccurred'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next.status == AuthStatus.initial && previous?.status == AuthStatus.loading) {
        // Request successful, navigate to reset password screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: _emailController.text.trim()),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('resetCodeSent'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _controller,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/logo1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'forgotPassword'.tr(),
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'enterEmailToReset'.tr(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'resetCodeWillBeSent'.tr(),
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    height: 58,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.85),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: authState.status == AuthStatus.loading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() == true) {
                                ref
                                    .read(authViewModelProvider.notifier)
                                    .requestPasswordReset(_emailController.text.trim());
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: authState.status == AuthStatus.loading
                          ? const SizedBox(
                              height: 26,
                              width: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'sendResetCode'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'rememberPassword'.tr(),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'login',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ).tr(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
