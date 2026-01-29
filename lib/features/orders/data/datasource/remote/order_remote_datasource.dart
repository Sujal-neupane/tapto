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

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      // ✅ FIXED: Changed from /orders/user to /orders/my-orders
      final response = await apiClient.get(ApiEndpoints.userOrders);

      final data = response.data;
      List<dynamic> ordersJson;

      if (data is Map) {
        if (data['success'] == false) {
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch orders',
            statusCode: response.statusCode,
            data: data,
          );
        }
        ordersJson = data['data'] ?? [];
      } else if (data is List) {
        ordersJson = data;
      } else {
        throw ServerException(message: 'Unexpected response format');
      }

      return ordersJson
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return e.response?.data['message'] ?? 'Server error';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'An error occurred';
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
