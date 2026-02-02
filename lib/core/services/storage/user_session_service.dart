import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/auth/data/models/user_model.dart';
import '../../../features/auth/domain/entities/user.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService();
});

/// Service for managing user session and authentication state
class UserSessionService {
  static const String _usersBoxName = 'users';
  static const String _sessionBoxName = 'session';
  static const String _currentUserKey = 'current_user_id';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static bool _hiveInitialized = false;

  Box<UserModel>? _usersBox;
  Box? _sessionBox;
  bool _isInitialized = false;

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!_hiveInitialized) {
      await Hive.initFlutter();
      _hiveInitialized = true;
    }

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    _usersBox ??= await Hive.openBox<UserModel>(_usersBoxName);
    _sessionBox ??= await Hive.openBox(_sessionBoxName);
    _isInitialized = true;
  }

  /// Ensure the Hive boxes are ready before any operation
  Future<void> _ensureInitialized() async {
    if (_usersBox == null || _sessionBox == null || !_isInitialized) {
      await initialize();
    }
  }

  /// Register a new user
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
    String? preference,
  }) async {
    await _ensureInitialized();

    // Check if email already exists
    final emailExists = _usersBox!.values.any(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );

    if (emailExists) throw Exception('Email already registered');

    // Create new user
    final userModel = UserModel.register(
      name: name,
      email: email,
      password: password,
      preference: preference,
    );

    // Save to Hive
    await _usersBox!.put(userModel.id, userModel);

    // Set as current user
    await _sessionBox!.put(_currentUserKey, userModel.id);

    return userModel.toEntity();
  }

  /// Login user with email and password
  Future<User> loginUser({
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();

    // Find user by email
    UserModel? userModel;

    try {
      userModel = _usersBox!.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      throw Exception('User not found');
    }

    // Verify password
    if (!userModel.verifyPassword(password)) {
      throw Exception('Invalid password');
    }

    // Set as current user
    await _sessionBox!.put(_currentUserKey, userModel.id);

    return userModel.toEntity();
  }

  /// Get current logged in user
  Future<User?> getCurrentUser() async {
    await _ensureInitialized();

    String? userId = _sessionBox!.get(_currentUserKey) as String?;

    // If no userId in session, try to get from SharedPreferences
    if (userId == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('user_id');
        // If found, save to session for next time
        if (userId != null) {
          await _sessionBox!.put(_currentUserKey, userId);
        }
      } catch (_) {}
    }

    if (userId == null) {
      return null;
    }

    final userModel = _usersBox!.get(userId);
    return userModel?.toEntity();
  }
  
  /// Save user session (called after successful login/register)
  Future<void> saveUserSession({
    required String userId,
    required String token,
  }) async {
    await _ensureInitialized();
    await _sessionBox!.put(_currentUserKey, userId);
    
    // Also save to SharedPreferences for persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('auth_token', token);
  }

  /// Check if user is logged in - checks both session and token storage
  Future<bool> isLoggedIn() async {
    await _ensureInitialized();

    // First check if we have a user ID in session
    final userId = _sessionBox!.get(_currentUserKey);
    if (userId != null) return true;
    
    // Also check SharedPreferences for token (in case of app restart)
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        return true;
      }
    } catch (_) {}
    
    return false;
  }

  /// Logout current user
  Future<void> logout() async {
    await _ensureInitialized();
    await _sessionBox!.delete(_currentUserKey);
  }

  /// Update user profile
  Future<User> updateUser({
    required String userId,
    String? name,
    String? preference,
  }) async {
    await _ensureInitialized();

    final userModel = _usersBox!.get(userId);

    if (userModel == null) {
      throw Exception('User not found');
    }

    final updatedModel = userModel.copyWith(name: name, preference: preference);

    await _usersBox!.put(userId, updatedModel);
    return updatedModel.toEntity();
  }

  /// Delete user account
  Future<void> deleteUser(String userId) async {
    await _ensureInitialized();

    await _usersBox!.delete(userId);

    // If this was the current user, logout
    final currentUserId = _sessionBox!.get(_currentUserKey);
    if (currentUserId == userId) {
      await logout();
    }
  }

  /// Get all registered users (for debugging)
  List<User> getAllUsers() {
    return _usersBox!.values.map((model) => model.toEntity()).toList();
  }

  /// Clear all data (for testing/debugging)
  Future<void> clearAllData() async {
    await _usersBox!.clear();
    await _sessionBox!.clear();
  }

  /// Mark onboarding as complete for current user
  Future<void> markOnboardingComplete() async {
    await _ensureInitialized();
    final userId = _sessionBox!.get(_currentUserKey);
    if (userId != null) {
      await _sessionBox!.put('${_onboardingCompleteKey}_$userId', true);
    }
  }

  /// Check if onboarding is complete for current user
  Future<bool> isOnboardingComplete() async {
    await _ensureInitialized();
    final userId = _sessionBox!.get(_currentUserKey);
    if (userId == null) return false;
    return _sessionBox!.get(
          '${_onboardingCompleteKey}_$userId',
          defaultValue: false,
        )
        as bool;
  }

  /// Close all boxes
  Future<void> dispose() async {
    await _usersBox?.close();
    await _sessionBox?.close();
  }
}
