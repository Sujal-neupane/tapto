import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:tapto/core/services/storage/user_session_service.dart';
import 'package:tapto/features/auth/domain/entities/user.dart';

/// Domain service for user storage operations
/// This ensures presentation layer doesn't directly access data models
abstract class UserStorageService {
  Future<void> saveUser(User user, String password);
  Future<void> saveUserCountry(String country);
  Future<void> setCurrentUser(User user);
  Future<User?> getCurrentUser();
  Future<void> clearUserData();
}

/// Implementation of UserStorageService
class UserStorageServiceImpl implements UserStorageService {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  UserStorageServiceImpl(this._hiveService, this._userSessionService);

  @override
  Future<void> saveUser(User user, String password) async {
    // Convert entity to model for storage (this happens in data layer)
    // We'll need to create a mapper or use the model's fromEntity method
    // But this should be done through a repository, not directly in presentation
    await _hiveService.saveUserFromEntity(user, password);
  }

  @override
  Future<void> saveUserCountry(String country) async {
    await _hiveService.put('user_country', country);
  }

  @override
  Future<void> setCurrentUser(User user) async {
    await _userSessionService.setCurrentUser(user.id);
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _userSessionService.getCurrentUser();
  }

  @override
  Future<void> clearUserData() async {
    await _userSessionService.clearAllData();
    await _hiveService.clearAllUsers();
  }
}

/// Provider for UserStorageService
final userStorageServiceProvider = Provider<UserStorageService>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return UserStorageServiceImpl(hiveService, userSessionService);
});