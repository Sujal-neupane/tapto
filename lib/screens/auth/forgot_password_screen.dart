// // lib/screens/auth/forgot_password_screen.dart
// import 'package:flutter/material.dart';
// import '../../theme/app_theme.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   bool _isSubmitted = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   void _handleResetPassword() {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isSubmitted = true;
//       });
//       // Handle password reset logic
//       print('Reset password for: ${_emailController.text}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(AppSpacing.lg),
//           child: _isSubmitted ? _buildSuccessView() : _buildFormView(),
//         ),
//       ),
//     );
//   }

//   Widget _buildFormView() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const SizedBox(height: AppSpacing.xl),

//           // Icon
//           Icon(Icons.lock_reset, size: 80, color: AppColors.primary),

//           const SizedBox(height: AppSpacing.lg),

//           // Title
//           Text(
//             'Forgot Password?',
//             style: AppTypography.h2,
//             textAlign: TextAlign.center,
//           ),

//           const SizedBox(height: AppSpacing.sm),

//           // Description
//           Text(
//             'No worries! Enter your email and we will send you a reset link',
//             style: AppTypography.bodyMedium.copyWith(
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),

//           const SizedBox(height: AppSpacing.xl),

//           // Email Field
//           TextFormField(
//             controller: _emailController,
//             keyboardType: TextInputType.emailAddress,
//             decoration: const InputDecoration(
//               labelText: 'Email',
//               hintText: 'Enter your email',
//               prefixIcon: Icon(Icons.email_outlined),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your email';
//               }
//               if (!value.contains('@')) {
//                 return 'Please enter a valid email';
//               }
//               return null;
//             },
//           ),

//           const SizedBox(height: AppSpacing.xl),

//           // Submit Button
//           ElevatedButton(
//             onPressed: _handleResetPassword,
//             child: const Padding(
//               padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
//               child: Text('Send Reset Link'),
//             ),
//           ),

//           const SizedBox(height: AppSpacing.md),

//           // Back to Login
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.arrow_back,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'Back to Login',
//                   style: AppTypography.bodyMedium.copyWith(
//                     color: AppColors.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSuccessView() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const SizedBox(height: AppSpacing.xxxxl),

//         // Success Icon
//         Container(
//           padding: const EdgeInsets.all(AppSpacing.lg),
//           decoration: BoxDecoration(
//             color: AppColors.successBg,
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(
//             Icons.check_circle_outline,
//             size: 80,
//             color: AppColors.success,
//           ),
//         ),

//         const SizedBox(height: AppSpacing.lg),

//         // Title
//         Text(
//           'Check Your Email',
//           style: AppTypography.h2,
//           textAlign: TextAlign.center,
//         ),

//         const SizedBox(height: AppSpacing.sm),

//         // Description
//         Text(
//           'We have sent a password reset link to\n${_emailController.text}',
//           style: AppTypography.bodyMedium.copyWith(
//             color: AppColors.textSecondary,
//           ),
//           textAlign: TextAlign.center,
//         ),

//         const SizedBox(height: AppSpacing.xl),

//         // Open Email Button
//         ElevatedButton.icon(
//           onPressed: () {
//             // Open email app
//           },
//           icon: const Icon(Icons.email_outlined),
//           label: const Text('Open Email App'),
//         ),

//         const SizedBox(height: AppSpacing.md),

//         // Resend Link
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Didn't receive the email? ", style: AppTypography.bodyMedium),
//             TextButton(
//               onPressed: () {
//                 // Resend email
//               },
//               child: Text(
//                 'Resend',
//                 style: AppTypography.bodyMedium.copyWith(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: AppSpacing.xl),

//         // Back to Login
//         TextButton.icon(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back, size: 20),
//           label: const Text('Back to Login'),
//         ),
//       ],
//     );
//   }
// }
