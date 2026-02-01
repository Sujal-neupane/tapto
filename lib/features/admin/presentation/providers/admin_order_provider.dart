import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/features/orders/data/models/order_model.dart';

/// Provider for admin orders data source
final adminOrderDataSourceProvider = Provider<AdminOrderDataSource>((ref) {
  return AdminOrderDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

/// Provider to fetch all orders for admin
final adminOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final dataSource = ref.watch(adminOrderDataSourceProvider);
  return dataSource.getAllOrders();
});

/// Provider to fetch orders by status
final adminOrdersByStatusProvider =
    FutureProvider.family<List<OrderModel>, String?>((ref, status) async {
      final dataSource = ref.watch(adminOrderDataSourceProvider);
      final orders = await dataSource.getAllOrders();

      if (status == null || status.toLowerCase() == 'all') {
        return orders;
      }

      return orders
          .where(
            (order) => order.status.name.toLowerCase() == status.toLowerCase(),
          )
          .toList();
    });

/// State for admin order operations
class AdminOrderOperationState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const AdminOrderOperationState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AdminOrderOperationState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return AdminOrderOperationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Notifier for admin order operations
class AdminOrderOperationNotifier extends Notifier<AdminOrderOperationState> {
  @override
  AdminOrderOperationState build() => const AdminOrderOperationState();

  Future<bool> updateOrderStatus(String orderId, String status) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final dataSource = ref.read(adminOrderDataSourceProvider);
      await dataSource.updateOrderStatus(orderId, status);

      // Invalidate the orders list to refresh
      ref.invalidate(adminOrdersProvider);

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId, String reason) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final dataSource = ref.read(adminOrderDataSourceProvider);
      await dataSource.cancelOrder(orderId, reason);

      // Invalidate the orders list to refresh
      ref.invalidate(adminOrdersProvider);

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final adminOrderOperationProvider =
    NotifierProvider<AdminOrderOperationNotifier, AdminOrderOperationState>(() {
      return AdminOrderOperationNotifier();
    });

/// Abstract data source for admin orders
abstract class AdminOrderDataSource {
  Future<List<OrderModel>> getAllOrders();
  Future<OrderModel> updateOrderStatus(String orderId, String status);
  Future<void> cancelOrder(String orderId, String reason);
}

/// Implementation of admin order data source
class AdminOrderDataSourceImpl implements AdminOrderDataSource {
  final ApiClient apiClient;

  AdminOrderDataSourceImpl({required this.apiClient});

  @override
  Future<List<OrderModel>> getAllOrders() async {
    final response = await apiClient.get('/admin/orders');

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return (data['data'] as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    }
    return (data as List).map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    final response = await apiClient.patch(
      '/admin/orders/$orderId/status',
      data: {'status': status},
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return OrderModel.fromJson(data['data']);
    }
    return OrderModel.fromJson(data);
  }

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    await apiClient.patch(
      '/admin/orders/$orderId/status',
      data: {'status': 'cancelled', 'cancellationReason': reason},
    );
  }
}
