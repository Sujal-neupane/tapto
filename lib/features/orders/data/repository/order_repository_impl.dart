import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/exceptions.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/features/orders/data/datasource/local/order_localdatasource.dart';
import 'package:tapto/features/orders/data/datasource/remote/order_remote_datasource.dart';
import 'package:tapto/features/orders/data/models/order_model.dart';
import 'package:tapto/features/orders/domain/enitites/order_entity.dart';
import 'package:tapto/features/orders/domain/enitites/tracking_entity.dart';
import 'package:tapto/features/orders/domain/repository/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final OrderLocalDataSource localDataSource;
  final INetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<OrderEntity>>> getMyOrders() async {
    if (await networkInfo.isConnected) {
      try {
        final orders = await remoteDataSource.getMyOrders();
        // Try to cache but don't fail if caching fails
        try {
          await localDataSource.cacheOrders(orders);
        } catch (_) {
          // Ignore cache errors when we have fresh data
        }
        return Right(orders);
      } on ServerException catch (e) {
        // If server fails, try cache as fallback
        try {
          final cachedOrders = await localDataSource.getCachedOrders();
          return Right(cachedOrders);
        } catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      }
    } else {
      try {
        final cachedOrders = await localDataSource.getCachedOrders();
        return Right(cachedOrders);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        // Clear corrupt cache and return empty list
        try {
          await localDataSource.clearCache();
        } catch (_) {}
        return const Left(CacheFailure(message: 'No cached orders available'));
      }
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        final order = await remoteDataSource.getOrderById(orderId);
        await localDataSource.cacheOrder(order);
        return Right(order);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedOrder = await localDataSource.getCachedOrder(orderId);
        if (cachedOrder != null) {
          return Right(cachedOrder);
        }
        return const Left(CacheFailure(message: 'Order not found in cache'));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<OrderItemEntity> items,
    required String addressId,
    required String paymentMethodId,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> paymentMethod,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final order = await remoteDataSource.createOrder(
        items: items
            .map(
              (e) => OrderItemModel(
                productId: e.productId,
                productName: e.productName,
                productImage: e.productImage,
                quantity: e.quantity,
                price: e.price,
              ),
            )
            .toList(),
        addressId: addressId,
        paymentMethodId: paymentMethodId,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );

      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, LiveTrackingEntity>> trackOrder(String orderId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final tracking = await remoteDataSource.trackOrder(orderId);
      await localDataSource.cacheTracking(orderId, tracking);
      return Right(tracking);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelOrder(
    String orderId,
    String reason,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.cancelOrder(orderId, reason);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
