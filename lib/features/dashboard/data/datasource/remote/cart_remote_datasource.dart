import 'package:dio/dio.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/api/api_endpoint.dart';
import 'package:tapto/core/error/exceptions.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  /// Fetch the user's server-side cart.
  Future<List<CartItemModel>> getCart();

  /// Add a single item to the server cart.
  Future<List<CartItemModel>> addItem({
    required String productId,
    required int quantity,
    String? size,
    String? color,
  });

  /// Update quantity of an item in the server cart.
  Future<List<CartItemModel>> updateItemQuantity({
    required String productId,
    required int quantity,
    String? size,
    String? color,
  });

  /// Remove a specific item from the server cart.
  Future<List<CartItemModel>> removeItem({
    required String productId,
    String? size,
    String? color,
  });

  /// Clear all items from the server cart.
  Future<void> clearCart();

  /// Push the full local cart to the server (full replacement sync).
  Future<List<CartItemModel>> syncCart(List<CartItemModel> items);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient apiClient;

  CartRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CartItemModel>> getCart() async {
    try {
      final response = await apiClient.get(ApiEndpoints.cart);
      final data = response.data;
      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to fetch cart',
          statusCode: response.statusCode,
        );
      }
      final items = data['data']['items'] as List<dynamic>? ?? [];
      return items
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<CartItemModel>> addItem({
    required String productId,
    required int quantity,
    String? size,
    String? color,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.cart,
        data: {
          'productId': productId,
          'quantity': quantity,
          if (size != null) 'size': size,
          if (color != null) 'color': color,
        },
      );
      final data = response.data;
      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to add item to cart',
          statusCode: response.statusCode,
        );
      }
      final items = data['data']['items'] as List<dynamic>? ?? [];
      return items
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<CartItemModel>> updateItemQuantity({
    required String productId,
    required int quantity,
    String? size,
    String? color,
  }) async {
    try {
      final response = await apiClient.patch(
        ApiEndpoints.cart,
        data: {
          'productId': productId,
          'quantity': quantity,
          if (size != null) 'size': size,
          if (color != null) 'color': color,
        },
      );
      final data = response.data;
      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to update cart',
          statusCode: response.statusCode,
        );
      }
      final items = data['data']['items'] as List<dynamic>? ?? [];
      return items
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<CartItemModel>> removeItem({
    required String productId,
    String? size,
    String? color,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (size != null) queryParams['size'] = size;
      if (color != null) queryParams['color'] = color;

      final response = await apiClient.delete(
        '${ApiEndpoints.cart}/$productId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;
      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to remove item from cart',
          statusCode: response.statusCode,
        );
      }
      final items = data['data']['items'] as List<dynamic>? ?? [];
      return items
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      final response = await apiClient.delete(ApiEndpoints.cart);
      final data = response.data;
      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to clear cart',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<CartItemModel>> syncCart(List<CartItemModel> items) async {
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.cart}/sync',
        data: {
          'items': items
              .map((item) => {
                    'productId': item.productId,
                    'quantity': item.quantity,
                    if (item.size != null && item.size!.isNotEmpty)
                      'size': item.size,
                    if (item.color != null && item.color!.isNotEmpty)
                      'color': item.color,
                  })
              .toList(),
        },
      );
      final data = response.data;
      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to sync cart',
          statusCode: response.statusCode,
        );
      }
      final serverItems = data['data']['items'] as List<dynamic>? ?? [];
      return serverItems
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
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
}
