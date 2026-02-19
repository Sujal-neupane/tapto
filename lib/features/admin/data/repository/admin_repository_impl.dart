import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/features/admin/data/remote/admin_remote_datasource.dart';
import 'package:tapto/features/admin/domain/repository/admin_repository.dart';
import 'package:tapto/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(
    remoteDataSource: ref.watch(adminRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final dashboardStatsModel = await remoteDataSource.getDashboardStats();
      final dashboardStats = dashboardStatsModel.toEntity();
      return Right(dashboardStats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders() async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final orderModels = await remoteDataSource.getAllOrders();
      final orders = orderModels.map((model) => model.toEntity()).toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(String orderId, String status) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final orderModel = await remoteDataSource.updateOrderStatus(orderId, status);
      final order = orderModel.toEntity();
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}