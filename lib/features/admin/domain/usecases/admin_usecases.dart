import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/admin/data/repository/admin_repository_impl.dart';
import 'package:tapto/features/admin/domain/repository/admin_repository.dart';
import 'package:tapto/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';

final getDashboardStatsUsecaseProvider = Provider<GetDashboardStatsUsecase>((ref) {
  return GetDashboardStatsUsecase(ref.watch(adminRepositoryProvider));
});

final getAllOrdersUsecaseProvider = Provider<GetAllOrdersUsecase>((ref) {
  return GetAllOrdersUsecase(ref.watch(adminRepositoryProvider));
});

final updateOrderStatusUsecaseProvider = Provider<UpdateOrderStatusUsecase>((ref) {
  return UpdateOrderStatusUsecase(ref.watch(adminRepositoryProvider));
});

class GetDashboardStatsUsecase implements UsecaseWithoutParms<DashboardStats> {
  final AdminRepository repository;

  GetDashboardStatsUsecase(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call() async {
    return await repository.getDashboardStats();
  }
}

class GetAllOrdersUsecase implements UsecaseWithoutParms<List<OrderEntity>> {
  final AdminRepository repository;

  GetAllOrdersUsecase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call() async {
    return await repository.getAllOrders();
  }
}

class UpdateOrderStatusUsecase implements UsecaseWithParms<OrderEntity, UpdateOrderStatusParams> {
  final AdminRepository repository;

  UpdateOrderStatusUsecase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(UpdateOrderStatusParams params) async {
    return await repository.updateOrderStatus(params.orderId, params.status);
  }
}

// Parameters
class UpdateOrderStatusParams {
  final String orderId;
  final String status;

  UpdateOrderStatusParams({
    required this.orderId,
    required this.status,
  });
}