import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/app/routes/app_routes.dart';
import 'package:tapto/app/theme/app_theme.dart';
import 'package:tapto/app/theme/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final themeMode = ref.watch(themeProvider);

      return MaterialApp(
        title: 'Tapto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.splash,
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(child: Text('Route not found: ${settings.name}')),
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('MyApp Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Critical Error in MyApp'),
                const SizedBox(height: 16),
                Text(e.toString()),
              ],
            ),
          ),
        ),
      );
    }
  }
}
