import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/features/admin/data/remote/admin_remote_datasource.dart';
import 'package:tapto/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';

// Admin State
class AdminState {
  final DashboardStats? stats;
  final List<OrderEntity> orders;
  final bool isLoading;
  final String? error;

  AdminState({
    this.stats,
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    DashboardStats? stats,
    List<OrderEntity>? orders,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Admin ViewModel
class AdminViewModel extends Notifier<AdminState> {
  @override
  AdminState build() {
    return AdminState();
  }

  Future<void> fetchDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = ref.read(apiClientProvider);
      final dataSource = AdminRemoteDataSourceImpl(apiClient: apiClient);

      final stats = await dataSource.getDashboardStats();
      final orders = await dataSource.getAllOrders();

      state = state.copyWith(
        stats: stats,
        orders: orders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final dataSource = AdminRemoteDataSourceImpl(apiClient: apiClient);

      await dataSource.updateOrderStatus(orderId, status);
      
      // Refresh data
      await fetchDashboardData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// Provider
final adminViewModelProvider =
    NotifierProvider<AdminViewModel, AdminState>(AdminViewModel.new); 