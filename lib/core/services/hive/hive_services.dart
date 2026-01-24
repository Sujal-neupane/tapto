import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/features/auth/data/models/user_model.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // Box names
  static const String _userBoxName = 'users';
  static const String _ordersBoxName = 'orders';
  static const String _orderCacheBoxName = 'order_cache';
  static const String _generalBoxName = 'general';

  // Boxes
  Box<UserModel>? _userBox;
  Box? _ordersBox;
  Box? _orderCacheBox;
  Box? _generalBox;

  bool _isInitialized = false;

  /// Initialize Hive and register adapters
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register UserModel adapter (generated from user_model.g.dart)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Open boxes
    _userBox = await Hive.openBox<UserModel>(_userBoxName);
    _ordersBox = await Hive.openBox(_ordersBoxName);
    _orderCacheBox = await Hive.openBox(_orderCacheBoxName);
    _generalBox = await Hive.openBox(_generalBoxName);

    _isInitialized = true;
  }

  /// Ensure initialization before operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // ========================================
  // USER METHODS
  // ========================================

  /// Save a new user
  Future<void> saveUser(UserModel user) async {
    await _ensureInitialized();
    await _userBox!.put(user.id, user);
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String id) async {
    await _ensureInitialized();
    return _userBox!.get(id);
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    await _ensureInitialized();
    final users = _userBox!.values.where((user) => user.email == email);
    return users.isEmpty ? null : users.first;
  }

  /// Update existing user
  Future<bool> updateUser(UserModel user) async {
    await _ensureInitialized();
    try {
      await _userBox!.put(user.id, user);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete user by ID
  Future<void> deleteUser(String id) async {
    await _ensureInitialized();
    await _userBox!.delete(id);
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    await _ensureInitialized();
    return _userBox!.values.toList();
  }

  /// Check if user exists by email
  Future<bool> userExists(String email) async {
    await _ensureInitialized();
    return _userBox!.values.any((user) => user.email == email);
  }

  /// Clear all users (for testing purposes)
  Future<void> clearAllUsers() async {
    await _ensureInitialized();
    await _userBox!.clear();
  }

  // ========================================
  // ORDER METHODS
  // ========================================

  /// Save multiple orders
  Future<void> saveOrders(List<Map<String, dynamic>> orders) async {
    await _ensureInitialized();
    try {
      await _ordersBox!.put('my_orders', orders);
      await _orderCacheBox!.put('last_sync', DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to cache orders: $e');
    }
  }

  /// Get all cached orders
  List<Map<String, dynamic>>? getOrders() {
    try {
      if (_ordersBox == null) return null;
      
      final orders = _ordersBox!.get('my_orders');
      if (orders == null) return null;
      
      return List<Map<String, dynamic>>.from(orders);
    } catch (e) {
      throw Exception('Failed to get cached orders: $e');
    }
  }

  /// Save single order by ID
  Future<void> saveOrder(String orderId, Map<String, dynamic> order) async {
    await _ensureInitialized();
    try {
      await _ordersBox!.put('order_$orderId', order);
    } catch (e) {
      throw Exception('Failed to cache order: $e');
    }
  }

  /// Get single order by ID
  Map<String, dynamic>? getOrder(String orderId) {
    try {
      if (_ordersBox == null) return null;
      
      final order = _ordersBox!.get('order_$orderId');
      return order != null ? Map<String, dynamic>.from(order) : null;
    } catch (e) {
      throw Exception('Failed to get cached order: $e');
    }
  }

  /// Save tracking data
  Future<void> saveTracking(String orderId, Map<String, dynamic> tracking) async {
    await _ensureInitialized();
    try {
      await _ordersBox!.put('tracking_$orderId', tracking);
    } catch (e) {
      throw Exception('Failed to cache tracking: $e');
    }
  }

  /// Get tracking data
  Map<String, dynamic>? getTracking(String orderId) {
    try {
      if (_ordersBox == null) return null;
      
      final tracking = _ordersBox!.get('tracking_$orderId');
      return tracking != null ? Map<String, dynamic>.from(tracking) : null;
    } catch (e) {
      throw Exception('Failed to get cached tracking: $e');
    }
  }

  /// Clear all orders
  Future<void> clearOrders() async {
    await _ensureInitialized();
    try {
      await _ordersBox!.clear();
      await _orderCacheBox!.clear();
    } catch (e) {
      throw Exception('Failed to clear order cache: $e');
    }
  }

  /// Check if order cache is valid
  bool isOrderCacheValid({int maxAgeInMinutes = 30}) {
    try {
      if (_orderCacheBox == null) return false;
      
      final lastSync = _orderCacheBox!.get('last_sync');
      if (lastSync == null) return false;

      final lastSyncTime = DateTime.parse(lastSync);
      final difference = DateTime.now().difference(lastSyncTime);

      return difference.inMinutes < maxAgeInMinutes;
    } catch (e) {
      return false;
    }
  }

  // ========================================
  // GENERAL METHODS
  // ========================================

  /// Put any value to general box
  Future<void> put<T>(String key, T value) async {
    await _ensureInitialized();
    await _generalBox!.put(key, value);
  }

  /// Get value from general box
  T? get<T>(String key, {T? defaultValue}) {
    if (_generalBox == null) return defaultValue;
    return _generalBox!.get(key, defaultValue: defaultValue);
  }

  /// Delete key from general box
  Future<void> delete(String key) async {
    await _ensureInitialized();
    await _generalBox!.delete(key);
  }

  /// Clear general box
  Future<void> clear() async {
    await _ensureInitialized();
    await _generalBox!.clear();
  }

  /// Check if key exists
  bool containsKey(String key) {
    if (_generalBox == null) return false;
    return _generalBox!.containsKey(key);
  }

  // ========================================
  // CLEANUP METHODS
  // ========================================

  /// Close all boxes
  Future<void> close() async {
    await _userBox?.close();
    await _ordersBox?.close();
    await _orderCacheBox?.close();
    await _generalBox?.close();
  }

  /// Clear all data (for testing/logout)
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _userBox?.clear();
    await _ordersBox?.clear();
    await _orderCacheBox?.clear();
    await _generalBox?.clear();
  }
}

/// Provider for HiveService
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});