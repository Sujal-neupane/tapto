import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/features/admin/domain/usecases/admin_usecases.dart';
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
  late final GetDashboardStatsUsecase _getDashboardStatsUsecase;
  late final GetAllOrdersUsecase _getAllOrdersUsecase;
  late final UpdateOrderStatusUsecase _updateOrderStatusUsecase;

  @override
  AdminState build() {
    _getDashboardStatsUsecase = ref.watch(getDashboardStatsUsecaseProvider);
    _getAllOrdersUsecase = ref.watch(getAllOrdersUsecaseProvider);
    _updateOrderStatusUsecase = ref.watch(updateOrderStatusUsecaseProvider);
    return AdminState();
  }

  Future<void> fetchDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statsResult = await _getDashboardStatsUsecase();
      final ordersResult = await _getAllOrdersUsecase();

      statsResult.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: failure.message,
        ),
        (stats) {
          ordersResult.fold(
            (failure) => state = state.copyWith(
              isLoading: false,
              error: failure.message,
            ),
            (orders) => state = state.copyWith(
              stats: stats,
              orders: orders,
              isLoading: false,
            ),
          );
        },
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
      final result = await _updateOrderStatusUsecase(
        UpdateOrderStatusParams(orderId: orderId, status: status),
      );

      result.fold(
        (failure) => state = state.copyWith(error: failure.message),
        (updatedOrder) async {
          // Refresh data
          await fetchDashboardData();
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// Provider
final adminViewModelProvider =
    NotifierProvider<AdminViewModel, AdminState>(AdminViewModel.new); 