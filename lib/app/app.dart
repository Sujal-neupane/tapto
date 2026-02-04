import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tapto/app/routes/app_routes.dart';
import 'package:tapto/app/theme/app_theme.dart';
import 'package:tapto/core/providers/theme_provider.dart';
import 'package:tapto/core/providers/language_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final themeMode = ref.watch(themeProvider);
      final language = ref.watch(languageProvider);

     

      return MaterialApp(
        title: 'Tapto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        locale: context.locale, // Use EasyLocalization's current locale
        supportedLocales: context.supportedLocales,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ...context.localizationDelegates,
        ],
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
