
import 'package:dio/dio.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/features/dashboard/data/repository/order_model.dart';


abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getMyOrders();
  Future<OrderModel> getOrderById(String orderId);
  Future<OrderModel> createOrder({
    required List<OrderItemModel> items,
    required String addressId,
    required String paymentMethodId,
  });
  Future<List<TrackingModel>> trackOrder(String orderId);
  Future<bool> cancelOrder(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await apiClient.request(
        method: 'GET',
        endpoint: '/orders/my-orders',
      );

      return (response.data['data'] as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await apiClient.request(
        method: 'GET',
        endpoint: '/orders/$orderId',
      );

      return OrderModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  @override
  Future<OrderModel> createOrder({
    required List<OrderItemModel> items,
    required String addressId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await apiClient.request(
        method: 'POST',
        endpoint: '/orders',
        // body: {
        //   'items': items.map((item) => item.toJson()).toList(),
        //   'addressId': addressId,
        //   'paymentMethodId': paymentMethodId,
        // },
      );

      return OrderModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<List<TrackingModel>> trackOrder(String orderId) async {
    try {
      final response = await apiClient.request(
        method: 'GET',
        endpoint: '/orders/$orderId/tracking',
      );

      return (response.data['data'] as List)
          .map((tracking) => TrackingModel.fromJson(tracking))
          .toList();
    } catch (e) {
      throw Exception('Failed to track order: $e');
    }
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    try {
      await apiClient.request(
        method: 'POST',
        endpoint: '/orders/$orderId/cancel',
      );
      return true;
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
}