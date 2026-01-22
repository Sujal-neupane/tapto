// lib/features/orders/domain/usecases/get_my_orders.dart
import 'package:dartz/dartz.dart';
import 'package:tapto/features/dashboard/domain/repository/order_repository.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';

class GetMyOrders {
  final OrderRepository repository;

  GetMyOrders(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) {
    return repository.getMyOrders();
  }
}

class NoParams {}