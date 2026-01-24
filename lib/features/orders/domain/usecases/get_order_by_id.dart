import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';
import 'package:tapto/features/orders/domain/repository/order_repository.dart';

class GetOrderById implements UseCase<OrderEntity, String> {
  final OrderRepository repository;

  GetOrderById(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return repository.getOrderById(orderId);
  }
}