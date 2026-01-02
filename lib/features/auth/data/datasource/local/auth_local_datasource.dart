import 'package:tapto/core/services/hive/hive_services.dart';

import '../../models/user_model.dart';
import 'package:tapto/core/services/storage/user_session_service.dart';

/// Local datasource for authentication
abstract class AuthLocalDataSource {
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? preference,
  });
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> logout();
  Future<UserModel?> getUserById(String id);
  Future<UserModel?> getUserByEmail(String email);
  Future<bool> updateUser(UserModel user);
  Future<bool> deleteUser(String id);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final UserSessionService _sessionService;
  final HiveService _hiveService;

  AuthLocalDataSourceImpl({
    required UserSessionService sessionService,
    required HiveService hiveService,
  }) : _sessionService = sessionService,
       _hiveService = hiveService;

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? preference,
  }) async {
    try {
      final userModel = UserModel.register(
        name: name,
        email: email,
        password: password,
        preference: preference,
      );

      // Save to Hive
      await _hiveService.saveUser(userModel);

      // Save session
      await _sessionService.saveUserSession(
        userId: userModel.id,
        email: userModel.email,
        name: userModel.name,
        preference: userModel.preference,
      );

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      // Get user from Hive
      final user = await _hiveService.getUserByEmail(email);

      if (user == null) {
        throw Exception('User not found');
      }

      // Verify password
      if (!user.verifyPassword(password)) {
        throw Exception('Invalid password');
      }

      // Save session to SharedPreferences
      await _sessionService.saveUserSession(
        userId: user.id,
        email: user.email,
        name: user.name,
        preference: user.preference,
      );

      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // Check if user is logged in
      if (!await _sessionService.isLoggedIn()) {
        return null;
      }

      // Get user ID from session
      final user = await _sessionService.getCurrentUser();
      if (user == null) {
        return null;
      }

      // Fetch user from Hive
      return await _hiveService.getUserById(user.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _sessionService.isLoggedIn();
  }

  @override
  Future<void> logout() async {
    try {
      await _sessionService.logout();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      return await _hiveService.getUserById(id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      return await _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(UserModel user) async {
    try {
      return await _hiveService.updateUser(user);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String id) async {
    try {
      await _hiveService.deleteUser(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
