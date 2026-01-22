// lib/features/orders/domain/repositories/order_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getMyOrders();
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<OrderItemEntity> items,
    required String addressId,
    required String paymentMethodId,
  });
  Future<Either<Failure, List<TrackingEntity>>> trackOrder(String orderId);
  Future<Either<Failure, bool>> cancelOrder(String orderId);
}