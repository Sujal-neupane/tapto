import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/features/auth/data/models/user_model.dart';
import 'package:tapto/features/auth/domain/entities/user.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // Box names
  static const String _userBoxName = 'users';
  static const String _ordersBoxName = 'orders';
  static const String _orderCacheBoxName = 'order_cache';
  static const String _addressesBoxName = 'addresses';
  static const String _addressCacheBoxName = 'address_cache';
  static const String _cartBoxName = 'cart';
  static const String _generalBoxName = 'general';
  static const String _productsBoxName = 'products';
  static const String _productCacheBoxName = 'product_cache';

  // Boxes
  Box<UserModel>? _userBox;
  Box? _ordersBox;
  Box? _orderCacheBox;
  Box? _addressesBox;
  Box? _addressCacheBox;
  Box? _cartBox;
  Box? _generalBox;
  Box? _productsBox;
  Box? _productCacheBox;

  bool _isInitialized = false;

  /// Initialize Hive and register adapters
  // In HiveService
  Future<void> init({bool useFlutter = true, String? testPath}) async {
    if (_isInitialized) return;

    if (useFlutter) {
      await Hive.initFlutter();
    } else if (testPath != null) {
      Hive.init(testPath);
    }

    // Register UserModel adapter (generated from user_model.g.dart)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Open boxes
    _userBox = await Hive.openBox<UserModel>(_userBoxName);
    _ordersBox = await Hive.openBox(_ordersBoxName);
    _orderCacheBox = await Hive.openBox(_orderCacheBoxName);
    _addressesBox = await Hive.openBox(_addressesBoxName);
    _addressCacheBox = await Hive.openBox(_addressCacheBoxName);
    _cartBox = await Hive.openBox(_cartBoxName);
    _generalBox = await Hive.openBox(_generalBoxName);
    _productsBox = await Hive.openBox(_productsBoxName);
    _productCacheBox = await Hive.openBox(_productCacheBoxName);

    _isInitialized = true;
  }

  /// Ensure initialization before operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// Save a new user
  Future<void> saveUser(UserModel user) async {
    await _ensureInitialized();
    await _userBox!.put(user.id, user);
  }

  /// Save user from entity (Clean Architecture compliant)
  Future<void> saveUserFromEntity(User user, String password) async {
    await _ensureInitialized();
    final userModel = UserModel.fromEntity(user, password);
    await _userBox!.put(user.id, userModel);
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
  Future<void> saveTracking(
    String orderId,
    Map<String, dynamic> tracking,
  ) async {
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
  // PRODUCT METHODS
  // ========================================

  /// Save products list with a cache key (e.g. 'user_products', 'admin_products')
  Future<void> saveProducts(
    String cacheKey,
    List<Map<String, dynamic>> products,
  ) async {
    await _ensureInitialized();
    try {
      await _productsBox!.put(cacheKey, products);
      await _productCacheBox!.put(
        '${cacheKey}_last_sync',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Failed to cache products: $e');
    }
  }

  /// Deep cast helper for Hive maps
  Map<String, dynamic> _deepCastMap(dynamic item) {
    if (item is Map<String, dynamic>) return item;
    if (item is Map) {
      return item.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _deepCastMap(value));
        } else if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((e) => e is Map ? _deepCastMap(e) : e).toList(),
          );
        }
        return MapEntry(key.toString(), value);
      });
    }
    return {};
  }

  /// Get cached products by cache key
  List<Map<String, dynamic>>? getProducts(String cacheKey) {
    try {
      if (_productsBox == null) return null;

      final products = _productsBox!.get(cacheKey);
      if (products == null) return null;

      return List<Map<String, dynamic>>.from(
        (products as List).map((e) => _deepCastMap(e)),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if product cache is valid
  bool isProductCacheValid(String cacheKey, {int maxAgeInMinutes = 30}) {
    try {
      if (_productCacheBox == null) return false;

      final lastSync = _productCacheBox!.get('${cacheKey}_last_sync');
      if (lastSync == null) return false;

      final lastSyncTime = DateTime.parse(lastSync);
      final difference = DateTime.now().difference(lastSyncTime);

      return difference.inMinutes < maxAgeInMinutes;
    } catch (e) {
      return false;
    }
  }

  /// Clear all product cache
  Future<void> clearProducts() async {
    await _ensureInitialized();
    try {
      await _productsBox!.clear();
      await _productCacheBox!.clear();
    } catch (e) {
      throw Exception('Failed to clear product cache: $e');
    }
  }

  // ========================================
  // ADDRESS METHODS
  // ========================================

  /// Save multiple addresses
  Future<void> saveAddresses(List<Map<String, dynamic>> addresses) async {
    await _ensureInitialized();
    try {
      await _addressesBox!.put('my_addresses', addresses);
      await _addressCacheBox!.put('last_sync', DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to cache addresses: $e');
    }
  }

  /// Get all cached addresses
  List<Map<String, dynamic>>? getAddresses() {
    try {
      if (_addressesBox == null) return null;

      final addresses = _addressesBox!.get('my_addresses');
      if (addresses == null) return null;

      return List<Map<String, dynamic>>.from(addresses);
    } catch (e) {
      throw Exception('Failed to get cached addresses: $e');
    }
  }

  /// Save single address by ID
  Future<void> saveAddress(String addressId, Map<String, dynamic> address) async {
    await _ensureInitialized();
    try {
      await _addressesBox!.put('address_$addressId', address);
    } catch (e) {
      throw Exception('Failed to cache address: $e');
    }
  }

  /// Get single address by ID
  Map<String, dynamic>? getAddress(String addressId) {
    try {
      if (_addressesBox == null) return null;

      final address = _addressesBox!.get('address_$addressId');
      return address != null ? Map<String, dynamic>.from(address) : null;
    } catch (e) {
      throw Exception('Failed to get cached address: $e');
    }
  }

  /// Clear all addresses
  Future<void> clearAddresses() async {
    await _ensureInitialized();
    try {
      await _addressesBox!.clear();
      await _addressCacheBox!.clear();
    } catch (e) {
      throw Exception('Failed to clear address cache: $e');
    }
  }

  /// Check if address cache is valid
  bool isAddressCacheValid({int maxAgeInMinutes = 30}) {
    try {
      if (_addressCacheBox == null) return false;

      final lastSync = _addressCacheBox!.get('last_sync');
      if (lastSync == null) return false;

      final lastSyncTime = DateTime.parse(lastSync);
      final difference = DateTime.now().difference(lastSyncTime);

      return difference.inMinutes < maxAgeInMinutes;
    } catch (e) {
      return false;
    }
  }

  // ========================================
  // CART METHODS
  // ========================================

  /// Save cart items
  Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    await _ensureInitialized();
    try {
      await _cartBox!.put('cart_items', items);
      await _cartBox!.put('last_updated', DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to cache cart items: $e');
    }
  }

  /// Get cached cart items
  List<Map<String, dynamic>>? getCartItems() {
    try {
      if (_cartBox == null) return null;

      final items = _cartBox!.get('cart_items');
      if (items == null) return null;

      return List<Map<String, dynamic>>.from(items);
    } catch (e) {
      throw Exception('Failed to get cached cart items: $e');
    }
  }

  /// Clear cart cache
  Future<void> clearCart() async {
    await _ensureInitialized();
    try {
      await _cartBox!.clear();
    } catch (e) {
      throw Exception('Failed to clear cart cache: $e');
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
    await _addressesBox?.close();
    await _addressCacheBox?.close();
    await _cartBox?.close();
    await _productsBox?.close();
    await _productCacheBox?.close();
    await _generalBox?.close();
  }

  /// Clear all data (for testing/logout)
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _userBox?.clear();
    await _ordersBox?.clear();
    await _orderCacheBox?.clear();
    await _addressesBox?.clear();
    await _addressCacheBox?.clear();
    await _cartBox?.clear();
    await _productsBox?.clear();
    await _productCacheBox?.clear();
    await _generalBox?.clear();
  }
}

/// Provider for HiveService
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
