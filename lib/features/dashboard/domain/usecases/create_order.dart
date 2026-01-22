// lib/features/orders/domain/usecases/create_order.dart
import 'package:dartz/dartz.dart';
import 'package:tapto/features/dashboard/domain/repository/order_repository.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';


class CreateOrderParams {
  final List<OrderItemEntity> items;
  final String addressId;
  final String paymentMethodId;

  CreateOrderParams({
    required this.items,
    required this.addressId,
    required this.paymentMethodId,
  });
}

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) {
    return repository.createOrder(
      items: params.items,
      addressId: params.addressId,
      paymentMethodId: params.paymentMethodId,
    );
  }
}