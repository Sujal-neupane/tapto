import 'package:dartz/dartz.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';
import 'package:tapto/features/orders/domain/repository/order_repository.dart';
import '../../../../core/error/failures.dart';



class GetMyOrders implements UseCase<List<OrderEntity>, NoParams> {
  final OrderRepository repository;

  GetMyOrders(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) {
    return repository.getMyOrders();
  }
}

class NoParams {}