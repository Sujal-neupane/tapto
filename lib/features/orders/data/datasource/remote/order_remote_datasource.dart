import 'package:dio/dio.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/api/api_endpoint.dart';
import 'package:tapto/core/error/exceptions.dart';
import 'package:tapto/features/orders/data/models/order_model.dart';
import 'package:tapto/features/orders/data/models/tracking_model.dart';

/// ===== ABSTRACT REMOTE DATASOURCE =====
abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getMyOrders();
  Future<OrderModel> getOrderById(String orderId);
  Future<OrderModel> createOrder({
    required List<OrderItemModel> items,
    required String addressId,
    required String paymentMethodId,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> paymentMethod,
  });
  Future<LiveTrackingModel> trackOrder(String orderId);
  Future<bool> cancelOrder(String orderId, String reason);
}

/// ===== IMPLEMENTATION =====
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await apiClient.get(ApiEndpoints.userOrders);
      final data = response.data;

      final List list =
          data is Map<String, dynamic> ? (data['data'] ?? []) : data;

      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response =
          await apiClient.get(ApiEndpoints.orderById(orderId));
      return OrderModel.fromJson(_extractData(response));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OrderModel> createOrder({
    required List<OrderItemModel> items,
    required String addressId,
    required String paymentMethodId,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> paymentMethod,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.orders,
        data: {
          'items': items.map((e) => e.toJson()).toList(),
          'addressId': addressId,
          'paymentMethodId': paymentMethodId,
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
        },
      );

      return OrderModel.fromJson(_extractData(response));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LiveTrackingModel> trackOrder(String orderId) async {
    try {
      final response = await apiClient.get(
        '${ApiEndpoints.orders}/$orderId/track',
      );
      return LiveTrackingModel.fromJson(_extractData(response));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await apiClient.post(
        '${ApiEndpoints.orders}/$orderId/cancel',
        data: {'reason': reason},
      );
      return true;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Map<String, dynamic> _extractData(Response response) {
    final data = response.data;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException(
        message: data['message'] ?? 'Request failed',
        statusCode: response.statusCode,
        data: data,
      );
    }

    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }

    throw ServerException(message: 'Invalid response format');
  }
}
