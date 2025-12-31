import 'package:flutter/material.dart';
import 'package:tapto/core/theme/app_theme.dart';
import 'core/navigation/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapto',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
    );
  }
}
