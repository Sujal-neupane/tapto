// // lib/screens/auth/otp_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import '../../theme/app_theme.dart';

// class OtpScreen extends StatefulWidget {
//   final String email;

//   const OtpScreen({super.key, required this.email});

//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   final List<TextEditingController> _controllers = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

//   int _remainingSeconds = 60;
//   Timer? _timer;
//   bool _canResend = false;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     _timer?.cancel();
//     super.dispose();
//   }

//   void _startTimer() {
//     _remainingSeconds = 60;
//     _canResend = false;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingSeconds > 0) {
//         setState(() {
//           _remainingSeconds--;
//         });
//       } else {
//         setState(() {
//           _canResend = true;
//         });
//         timer.cancel();
//       }
//     });
//   }

//   void _handleResendOtp() {
//     if (_canResend) {
//       // Resend OTP logic
//       print('Resending OTP to ${widget.email}');
//       _startTimer();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('OTP sent successfully'),
//           backgroundColor: AppColors.success,
//         ),
//       );
//     }
//   }

//   void _handleVerifyOtp() {
//     String otp = _controllers.map((c) => c.text).join();
//     if (otp.length == 6) {
//       // Verify OTP logic
//       print('Verifying OTP: $otp');
//       Navigator.pushReplacementNamed(context, '/dashboard');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter complete OTP'),
//           backgroundColor: AppColors.error,
//         ),
//       );
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
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: AppSpacing.xl),

//               // Icon
//               Icon(Icons.message_outlined, size: 80, color: AppColors.primary),

//               const SizedBox(height: AppSpacing.lg),

//               // Title
//               Text(
//                 'Verify OTP',
//                 style: AppTypography.h2,
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: AppSpacing.sm),

//               // Description
//               Text(
//                 'We have sent a verification code to\n${widget.email}',
//                 style: AppTypography.bodyMedium.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: AppSpacing.xl),

//               // OTP Input Fields
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(6, (index) {
//                   return SizedBox(
//                     width: 50,
//                     child: TextFormField(
//                       controller: _controllers[index],
//                       focusNode: _focusNodes[index],
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.center,
//                       maxLength: 1,
//                       style: AppTypography.h3,
//                       decoration: InputDecoration(
//                         counterText: '',
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: AppSpacing.md,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             AppBorderRadius.md,
//                           ),
//                         ),
//                       ),
//                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                       onChanged: (value) {
//                         if (value.length == 1 && index < 5) {
//                           _focusNodes[index + 1].requestFocus();
//                         } else if (value.isEmpty && index > 0) {
//                           _focusNodes[index - 1].requestFocus();
//                         }

//                         // Auto-verify when all fields are filled
//                         if (index == 5 && value.isNotEmpty) {
//                           String otp = _controllers.map((c) => c.text).join();
//                           if (otp.length == 6) {
//                             _handleVerifyOtp();
//                           }
//                         }
//                       },
//                     ),
//                   );
//                 }),
//               ),

//               const SizedBox(height: AppSpacing.xl),

//               // Timer and Resend
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     _canResend
//                         ? "Didn't receive the code? "
//                         : 'Resend code in ',
//                     style: AppTypography.bodyMedium.copyWith(
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   if (!_canResend)
//                     Text(
//                       '00:${_remainingSeconds.toString().padLeft(2, '0')}',
//                       style: AppTypography.bodyMedium.copyWith(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   if (_canResend)
//                     TextButton(
//                       onPressed: _handleResendOtp,
//                       child: Text(
//                         'Resend',
//                         style: AppTypography.bodyMedium.copyWith(
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(height: AppSpacing.xl),

//               // Verify Button
//               ElevatedButton(
//                 onPressed: _handleVerifyOtp,
//                 child: const Padding(
//                   padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
//                   child: Text('Verify OTP'),
//                 ),
//               ),

//               const SizedBox(height: AppSpacing.md),

//               // Change Email
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'Change Email Address',
//                   style: AppTypography.bodyMedium.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
