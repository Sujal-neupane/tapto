import 'package:flutter/material.dart';
import 'package:tapto/screens/auth/forgot_password_screen.dart';
import 'package:tapto/screens/auth/otp_screen.dart';
import 'package:tapto/screens/cart_screen.dart';
import 'package:tapto/screens/dashboard_screen.dart';
import 'package:tapto/screens/filter_screen.dart';
import 'package:tapto/screens/onboarding_screen.dart';
import 'package:tapto/screens/search_screen.dart';
import 'package:tapto/screens/signp_screen.dart';
import 'package:tapto/screens/splash_screen.dart';
import 'package:tapto/screens/login_screen.dart';
import 'package:tapto/screens/wish_list_screen.dart';
import 'package:tapto/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapto',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/otp': (context) => const OtpScreen(),
        '/filter': (context) => const FilterScreen(),
        '/search': (context) => const SearchScreen(),
        '/cart': (context) => const CartScreen(),
        '/wish-list': (context) => const WishlistScreen(),
      },
    );
  }
}
