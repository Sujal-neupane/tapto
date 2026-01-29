import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/orders/domain/enitites/tracking_entity.dart';
import 'package:tapto/features/orders/domain/repository/order_repository.dart';

class TrackOrder implements UseCase<LiveTrackingEntity, String> {
  final OrderRepository repository;

  TrackOrder(this.repository);

  @override
  Future<Either<Failure, LiveTrackingEntity>> call(String orderId) {
    return repository.trackOrder(orderId);
  }
}