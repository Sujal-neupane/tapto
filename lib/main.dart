import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tapto/app/app.dart';
import 'package:tapto/core/services/storage/storage_provider.dart';
import 'package:tapto/core/services/storage/token_storage_service.dart';
import 'package:tapto/core/services/storage/user_session_service.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize UserSessionService
  final userSessionService = UserSessionService();
  await userSessionService.initialize();

  final sharedPreferences = await SharedPreferences.getInstance();
  final tokenStorageService = TokenStorageService(sharedPreferences);
  
  // Get saved language preference
  final savedLanguageCode = sharedPreferences.getString('languageCode') ?? 'en';
  final savedLocale = Locale(savedLanguageCode);
  
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es'), Locale('fr'), Locale('de'), Locale('ne')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: savedLocale,
      child: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences ),
          tokenStorageServiceProvider.overrideWithValue(tokenStorageService),
        ],
        child: const MyApp(),
      ),
    ),
  );
}