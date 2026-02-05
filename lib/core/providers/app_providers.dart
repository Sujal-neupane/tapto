import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Services
import '../services/hive/hive_services.dart';
import '../services/storage/user_session_service.dart';
import '../services/sensor_service.dart';

// Auth Feature

/// Central file for all app-level providers
/// This helps in dependency injection and makes testing easier

// ==================== Core Providers ====================

/// SharedPreferences provider - must be overridden in main.dart
final sharedPreferencesInstanceProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// API Client is already provided in api_client.dart
// Network Info is already provided in network_info.dart
// Hive Service is already provided in hive_services.dart
// User Session Service is already provided in user_session_service.dart

/// Sensor service provider for shake gesture detection
final sensorServiceProvider = Provider<SensorService>((ref) {
  return SensorService();
});

// ==================== Data Source Providers ====================

// Auth Local DataSource is already provided in auth_local_datasource.dart
// Auth Remote DataSource is already provided in auth_remote_datasource.dart

// ==================== Repository Providers ====================

// Auth Repository is already provided in auth_repository.dart

// ==================== Use Case Providers ====================

// Use cases will be added here as we create them

// ==================== Presentation Providers ====================

// Presentation layer providers (BLoC, ChangeNotifier) will be added here

/// Helper function to initialize all async providers
Future<void> initializeProviders(ProviderContainer container) async {
  // Initialize Hive
  await container.read(hiveServiceProvider).init();

  // Initialize User Session Service
  await container.read(userSessionServiceProvider).initialize();

  // Additional initialization can be added here
}
