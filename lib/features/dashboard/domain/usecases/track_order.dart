// lib/features/orders/domain/usecases/track_order.dart
import 'package:dartz/dartz.dart';
import 'package:tapto/features/dashboard/domain/repository/order_repository.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';


class TrackOrder {
  final OrderRepository repository;

  TrackOrder(this.repository);

  @override
  Future<Either<Failure, List<TrackingEntity>>> call(String orderId) {
    return repository.trackOrder(orderId);
  }
}