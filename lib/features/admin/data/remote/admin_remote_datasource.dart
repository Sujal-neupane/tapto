import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:tapto/features/orders/data/models/order_model.dart';

abstract class AdminRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<List<OrderModel>> getAllOrders();
  Future<OrderModel> updateOrderStatus(String orderId, String status);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await apiClient.get('/admin/dashboard/stats');
      
      if (response.data['success'] == true) {
        return DashboardStatsModel.fromJson(response.data['data']);
      }
      
      throw Exception('Failed to fetch dashboard stats');
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await apiClient.get('/admin/orders');
      
      if (response.data['success'] == true) {
        final List<dynamic> ordersJson = response.data['data'];
        return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch orders');
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await apiClient.patch(
        '/admin/orders/$orderId/status',
        data: {'status': status},
      );
      
      if (response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      }
      
      throw Exception('Failed to update order status');
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}