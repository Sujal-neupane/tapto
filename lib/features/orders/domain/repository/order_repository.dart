
import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';
import 'package:tapto/features/orders/domain/enitites/tracking_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getMyOrders();
  
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<OrderItemEntity> items,
    required String addressId,
    required String paymentMethodId,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> paymentMethod,
  });
  
  Future<Either<Failure, LiveTrackingEntity>> trackOrder(String orderId);
  
  Future<Either<Failure, bool>> cancelOrder(String orderId, String reason);
}