import 'package:flutter_riverpod/legacy.dart';
import 'package:tapto/features/orders/domain/usecases/cancel_order.dart';
import 'package:tapto/features/orders/domain/usecases/create_order.dart';
import 'package:tapto/features/orders/domain/usecases/get_my_orders.dart';
import 'package:tapto/features/orders/domain/usecases/get_order_by_id.dart';
import 'package:tapto/features/orders/domain/usecases/track_order.dart';
import 'package:tapto/features/orders/presentation/state/order_state.dart';

class OrderViewModel extends StateNotifier<OrderState> {
  final GetMyOrders getMyOrders;
  final GetOrderById getOrderById;
  final TrackOrder trackOrder;
  final CreateOrder createOrder;
  final CancelOrder cancelOrder;

  OrderViewModel({
    required this.getMyOrders,
    required this.getOrderById,
    required this.trackOrder,
    required this.createOrder,
    required this.cancelOrder,
  }) : super(OrderState.initial());

  Future<void> fetchMyOrders() async {
    state = state.copyWith(status: OrderStateStatus.loading);

    final result = await getMyOrders(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        status: OrderStateStatus.error,
        error: failure.message,
      ),
      (orders) => state = state.copyWith(
        status: OrderStateStatus.success,
        orders: orders,
      ),
    );
  }

  Future<void> fetchOrderById(String orderId) async {
    state = state.copyWith(status: OrderStateStatus.loading);

    final result = await getOrderById(orderId);

    result.fold(
      (failure) => state = state.copyWith(
        status: OrderStateStatus.error,
        error: failure.message,
      ),
      (order) => state = state.copyWith(
        status: OrderStateStatus.success,
        selectedOrder: order,
      ),
    );
  }

  Future<void> trackOrderById(String orderId) async {
    state = state.copyWith(status: OrderStateStatus.loading);

    final result = await trackOrder(orderId);

    result.fold(
      (failure) => state = state.copyWith(
        status: OrderStateStatus.error,
        error: failure.message,
      ),
      (tracking) => state = state.copyWith(
        status: OrderStateStatus.success,
        liveTracking: tracking,
      ),
    );
  }

  Future<void> placeOrder(CreateOrderParams params) async {
    state = state.copyWith(status: OrderStateStatus.loading);

    final result = await createOrder(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: OrderStateStatus.error,
        error: failure.message,
      ),
      (order) => state = state.copyWith(
        status: OrderStateStatus.success,
        selectedOrder: order,
      ),
    );
  }

  Future<void> cancelOrderById(String orderId, String reason) async {
    state = state.copyWith(status: OrderStateStatus.loading);

    final result = await cancelOrder(CancelOrderParams(
      orderId: orderId,
      reason: reason,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        status: OrderStateStatus.error,
        error: failure.message,
      ),
      (_) {
        fetchMyOrders();
      },
    );
  }
}
