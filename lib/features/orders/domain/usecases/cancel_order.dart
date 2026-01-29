import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/orders/domain/repository/order_repository.dart';

class CancelOrderParams {
  final String orderId;
  final String reason;

  CancelOrderParams({
    required this.orderId,
    required this.reason,
  });
}

class CancelOrder implements UseCase<bool, CancelOrderParams> {
  final OrderRepository repository;

  CancelOrder(this.repository);

  @override
  Future<Either<Failure, bool>> call(CancelOrderParams params) {
    return repository.cancelOrder(params.orderId, params.reason);
  }
}