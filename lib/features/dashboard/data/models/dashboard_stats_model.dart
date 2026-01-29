import 'package:tapto/features/dashboard/domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  DashboardStatsModel({
    required super.totalOrders,
    required super.pendingOrders,
    required super.completedOrders,
    required super.cancelledOrders,
    required super.totalRevenue,
    required super.todayRevenue,
    required super.totalUsers,
    required super.totalProducts,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      cancelledOrders: json['cancelledOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      totalUsers: json['totalUsers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'totalRevenue': totalRevenue,
      'todayRevenue': todayRevenue,
      'totalUsers': totalUsers,
      'totalProducts': totalProducts,
    };
  }
}