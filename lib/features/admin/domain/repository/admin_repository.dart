import 'package:tapto/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';

abstract class AdminRepository {
  Future<DashboardStats> getDashboardStats();
  Future<List<OrderEntity>> getAllOrders();
  Future<OrderEntity> updateOrderStatus(String orderId, String status);
}