import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', 'English'),
  spanish('es', 'Spanish'),
  french('fr', 'French'),
  german('de', 'German'),
  nepali('ne', 'Nepali');

  const AppLanguage(this.code, this.displayName);
  final String code;
  final String displayName;
}

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english) {
    _loadLanguage();
  }

  void _loadLanguage() {
    SharedPreferences.getInstance().then((prefs) {
      final languageCode = prefs.getString('languageCode') ?? 'en';
      final language = AppLanguage.values.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => AppLanguage.english,
      );
      state = language;
    });
  }

  void setLanguage(AppLanguage language) {
    state = language;
    print('Language Changed: ${language.displayName}');
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('languageCode', language.code);
      print(' Language Saved: ${language.code}');
    });
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (_) => LanguageNotifier(),
);
