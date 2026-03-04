import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/orders/data/datasource/remote/order_remote_datasource.dart';
import 'package:tapto/features/orders/data/models/order_model.dart';
import 'package:tapto/features/orders/data/repository/order_repository_impl.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/features/orders/presentation/providers/order_provider.dart';

// Order State
class OrderState {
  final List<OrderEntity> orders;
  final bool isLoading;
  final String? error;
  final OrderEntity? selectedOrder;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedOrder,
  });

  OrderState copyWith({
    List<OrderEntity>? orders,
    bool? isLoading,
    String? error,
    OrderEntity? selectedOrder,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedOrder: selectedOrder ?? this.selectedOrder,
    );
  }
}

// Order ViewModel
class OrderViewModel extends Notifier<OrderState> {
  @override
  OrderState build() {
    return OrderState();
  }

  Future<void> fetchMyOrders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = ref.read(apiClientProvider);
      final dataSource = OrderRemoteDataSourceImpl(apiClient: apiClient);
      final localDataSource = ref.read(orderLocalDataSourceProvider);
      final networkInfo = ref.read(networkInfoProvider);
      final repository = OrderRepositoryImpl(
        remoteDataSource: dataSource,
        localDataSource: localDataSource,
        networkInfo: networkInfo,
      );

      final result = await repository.getMyOrders();

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.toString(),
          );
        },
        (orders) {
          state = state.copyWith(
            orders: orders,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  // ...existing code...

Future<void> createOrderFromCart(
  List<CartItemModel> cartItems, {
  required Map<String, String> address,
  required Map<String, dynamic> payment,
}) async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final networkInfo = ref.read(networkInfoProvider);
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('No internet connection. Please connect to internet to place an order.');
    }

    final apiClient = ref.read(apiClientProvider);
    final dataSource = OrderRemoteDataSourceImpl(apiClient: apiClient);

    // Convert CartItems to OrderItemModels
    final orderItems = cartItems.map((item) {
      return OrderItemModel(
        productId: item.productId,
        productName: item.productName,
        productImage: item.productImage,
        quantity: item.quantity,
        price: item.price,
      );
    }).toList();

    // Use the address provided by the user (from modal)
    final order = await dataSource.createOrder(
      items: orderItems,
      addressId: address['id'] ?? 'default-address',
      paymentMethodId: payment['id'] ?? 'cod',
      shippingAddress: address, // <-- Use the address from the modal
      paymentMethod: payment,
    );

    // Refresh orders list
    await fetchMyOrders();

    state = state.copyWith(
      isLoading: false,
      selectedOrder: order,
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
    rethrow;
  }
}

// ...existing code...

  Future<void> getOrderById(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = ref.read(apiClientProvider);
      final dataSource = OrderRemoteDataSourceImpl(apiClient: apiClient);
      final localDataSource = ref.read(orderLocalDataSourceProvider);
      final networkInfo = ref.read(networkInfoProvider);
      final repository = OrderRepositoryImpl(
        remoteDataSource: dataSource,
        localDataSource: localDataSource,
        networkInfo: networkInfo,
      );

      final result = await repository.getOrderById(orderId);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.toString(),
            selectedOrder: null,
          );
        },
        (order) {
          state = state.copyWith(
            selectedOrder: order,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = ref.read(apiClientProvider);
      final dataSource = OrderRemoteDataSourceImpl(apiClient: apiClient);
      final localDataSource = ref.read(orderLocalDataSourceProvider);
      final networkInfo = ref.read(networkInfoProvider);
      final repository = OrderRepositoryImpl(
        remoteDataSource: dataSource,
        localDataSource: localDataSource,
        networkInfo: networkInfo,
      );

      await repository.cancelOrder(orderId, reason);

      // Refresh orders
      await fetchMyOrders();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final orderViewModelProvider =
    NotifierProvider<OrderViewModel, OrderState>(OrderViewModel.new);