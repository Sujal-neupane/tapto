
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';
import 'package:tapto/features/orders/domain/enitites/tracking_entity.dart';

enum OrderStateStatus { initial, loading, success, error }

class OrderState {
  final OrderStateStatus status;
  final List<OrderEntity> orders;
  final OrderEntity? selectedOrder;
  final LiveTrackingEntity? liveTracking;
  final String? error;

  OrderState({
    required this.status,
    this.orders = const [],
    this.selectedOrder,
    this.liveTracking,
    this.error,
  });

  factory OrderState.initial() {
    return OrderState(status: OrderStateStatus.initial);
  }

  OrderState copyWith({
    OrderStateStatus? status,
    List<OrderEntity>? orders,
    OrderEntity? selectedOrder,
    LiveTrackingEntity? liveTracking,
    String? error,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      liveTracking: liveTracking ?? this.liveTracking,
      error: error,
    );
  }
}
