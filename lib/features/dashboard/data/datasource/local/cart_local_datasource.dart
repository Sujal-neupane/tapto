import 'package:tapto/core/error/exceptions.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCachedCartItems();
  Future<void> cacheCartItems(List<CartItemModel> items);
  Future<void> clearCache();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final HiveService hiveService;

  CartLocalDataSourceImpl({required this.hiveService});

  /// Helper to deeply cast Map<dynamic, dynamic> to Map<String, dynamic>
  Map<String, dynamic> _deepCastMap(dynamic item) {
    if (item == null) return {};
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

  @override
  Future<List<CartItemModel>> getCachedCartItems() async {
    try {
      final cachedData = hiveService.getCartItems();
      if (cachedData == null || cachedData.isEmpty) {
        return [];
      }
      return cachedData
          .map((json) => CartItemModel.fromJson(_deepCastMap(json)))
          .toList();
    } catch (e) {
      // Return empty list instead of throwing
      return [];
    }
  }

  @override
  Future<void> cacheCartItems(List<CartItemModel> items) async {
    try {
      final jsonList = items.map((item) => item.toJson()).toList();
      await hiveService.saveCartItems(jsonList);
    } catch (e) {
      throw CacheException(message: 'Failed to cache cart items: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await hiveService.clearCart();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }
}
