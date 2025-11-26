import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _scale = 0.3; // Initial scale for animation

  @override
  void initState() {
    super.initState();

    // Animate logo after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _scale = 1.8; // Target scale for pop effect
      });
    });

    // Navigate to Login screen after 2 seconds
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack, // Smooth pop animation
          child: Image.asset(
            'assets/images/logo1.png',
            width: 120,
            height: 120,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
