import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/auth/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String _userBoxName = 'users';
  Box<UserModel>? _userBox;

  /// Initialize Hive and register adapters
  Future<void> init() async {
    await Hive.initFlutter();

    // Register UserModel adapter (generated from user_model.g.dart)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    _userBox = await Hive.openBox<UserModel>(_userBoxName);
  }

  /// Save a new user
  Future<void> saveUser(UserModel user) async {
    if (_userBox == null) throw Exception('Hive not initialized');
    await _userBox!.put(user.id, user);
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String id) async {
    if (_userBox == null) throw Exception('Hive not initialized');
    return _userBox!.get(id);
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    if (_userBox == null) throw Exception('Hive not initialized');

    final users = _userBox!.values.where((user) => user.email == email);
    return users.isEmpty ? null : users.first;
  }

  /// Update existing user
  Future<bool> updateUser(UserModel user) async {
    if (_userBox == null) throw Exception('Hive not initialized');

    try {
      await _userBox!.put(user.id, user);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete user by ID
  Future<void> deleteUser(String id) async {
    if (_userBox == null) throw Exception('Hive not initialized');
    await _userBox!.delete(id);
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    if (_userBox == null) throw Exception('Hive not initialized');
    return _userBox!.values.toList();
  }

  /// Check if user exists by email
  Future<bool> userExists(String email) async {
    if (_userBox == null) throw Exception('Hive not initialized');
    return _userBox!.values.any((user) => user.email == email);
  }

  /// Clear all users (for testing purposes)
  Future<void> clearAllUsers() async {
    if (_userBox == null) throw Exception('Hive not initialized');
    await _userBox!.clear();
  }

  /// Close the box
  Future<void> close() async {
    await _userBox?.close();
  }

  /// Generic methods for other data types
  late Box _generalBox;

  Future<void> openBox(String boxName) async {
    _generalBox = await Hive.openBox(boxName);
  }

  Future<void> put<T>(String key, T value) async {
    await _generalBox.put(key, value);
  }

  T? get<T>(String key, {T? defaultValue}) {
    return _generalBox.get(key, defaultValue: defaultValue);
  }

  Future<void> delete(String key) async {
    await _generalBox.delete(key);
  }

  Future<void> clear() async {
    await _generalBox.clear();
  }

  bool containsKey(String key) {
    return _generalBox.containsKey(key);
  }
}

/// Provider for HiveService
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
