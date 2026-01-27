class DashboardStats {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double todayRevenue;
  final int totalUsers;
  final int totalProducts;

  DashboardStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.totalUsers,
    required this.totalProducts,
  });
}