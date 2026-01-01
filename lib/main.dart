import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/storage/user_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  final userSessionService = UserSessionService();
  await userSessionService.initialize();

  runApp(ProviderScope(child: const MyApp()));
}
