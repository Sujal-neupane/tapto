
import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';
import 'package:tapto/features/orders/domain/repository/order_repository.dart';

class CreateOrderParams {
  final List<OrderItemEntity> items;
  final String addressId;
  final String paymentMethodId;
  final Map<String, dynamic> shippingAddress;
  final Map<String, dynamic> paymentMethod;

  CreateOrderParams({
    required this.items,
    required this.addressId,
    required this.paymentMethodId,
    required this.shippingAddress,
    required this.paymentMethod,
  });
}

class CreateOrder implements UseCase<OrderEntity, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrder(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) {
    return repository.createOrder(
      items: params.items,
      addressId: params.addressId,
      paymentMethodId: params.paymentMethodId,
      shippingAddress: params.shippingAddress,
      paymentMethod: params.paymentMethod,
    );
  }
}