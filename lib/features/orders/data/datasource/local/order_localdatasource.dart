import 'package:tapto/core/error/exceptions.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:tapto/features/orders/data/models/order_model.dart';
import 'package:tapto/features/orders/data/models/tracking_model.dart';

abstract class OrderLocalDataSource {
  Future<List<OrderModel>> getCachedOrders();
  Future<void> cacheOrders(List<OrderModel> orders);
  Future<OrderModel?> getCachedOrder(String orderId);
  Future<void> cacheOrder(OrderModel order);
  Future<LiveTrackingModel?> getCachedTracking(String orderId);
  Future<void> cacheTracking(String orderId, LiveTrackingModel tracking);
  Future<void> clearCache();
  bool isCacheValid();
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  final HiveService hiveService;

  OrderLocalDataSourceImpl({required this.hiveService});

  @override
  Future<List<OrderModel>> getCachedOrders() async {
    try {
      final cachedData = hiveService.getOrders();

      if (cachedData == null || cachedData.isEmpty) {
        throw CacheException(message: 'No cached orders found');
      }

      return cachedData
          .map((json) => OrderModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to get cached orders: $e');
    }
  }

  @override
  Future<void> cacheOrders(List<OrderModel> orders) async {
    try {
      final jsonList = orders.map((order) => order.toJson()).toList();
      await hiveService.saveOrders(jsonList);
    } catch (e) {
      throw CacheException(message: 'Failed to cache orders: $e');
    }
  }

  @override
  Future<OrderModel?> getCachedOrder(String orderId) async {
    try {
      final cachedData = hiveService.getOrder(orderId);
      if (cachedData == null) return null;
      return OrderModel.fromJson(Map<String, dynamic>.from(cachedData));
    } catch (e) {
      throw CacheException(message: 'Failed to get cached order: $e');
    }
  }

  @override
  Future<void> cacheOrder(OrderModel order) async {
    try {
      await hiveService.saveOrder(order.id, order.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to cache order: $e');
    }
  }

  @override
  Future<LiveTrackingModel?> getCachedTracking(String orderId) async {
    try {
      final cachedData = hiveService.getTracking(orderId);
      if (cachedData == null) return null;
      return LiveTrackingModel.fromJson(Map<String, dynamic>.from(cachedData));
    } catch (e) {
      throw CacheException(message: 'Failed to get cached tracking: $e');
    }
  }

  @override
  Future<void> cacheTracking(String orderId, LiveTrackingModel tracking) async {
    try {
      await hiveService.saveTracking(orderId, tracking.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to cache tracking: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await hiveService.clearOrders();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  bool isCacheValid() {
    return hiveService.isOrderCacheValid(maxAgeInMinutes: 30);
  }
}
