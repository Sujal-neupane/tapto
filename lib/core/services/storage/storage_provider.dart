import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'token_storage_service.dart';
import 'user_session_service.dart';

final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TokenStorageService(prefs);
});