import 'package:flutter/material.dart';
import 'package:tapto/screens/wish_list_screen.dart';
// import 'package:tapto/screens/dashboard_screen.dart';
// import 'package:tapto/screens/onboarding_screen.dart';
// import 'package:tapto/screens/signp_screen.dart';
// import 'package:tapto/screens/splash_screen.dart';
// import 'package:tapto/screens/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapto',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const WishlistScreen(),
      // initialRoute: 'WishListScreen',
      // routes: {
      //   '/': (context) => const SplashScreen(),
      //   '/login': (context) => const LoginScreen(),
      //   '/signup': (context) => const SignupScreen(),
      //   '/dashboard': (context) => const DashboardScreen(),
      //   '/onboarding': (context) => const OnboardingScreen(),
      // },
    );
  }
}
