import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:tapto/features/dashboard/data/datasource/local/cart_local_datasource.dart';
import 'package:tapto/features/dashboard/data/datasource/remote/cart_remote_datasource.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/dashboard/domain/entities/cart_item.dart';
import 'package:tapto/features/dashboard/domain/repositories/cart_repository.dart';

final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  return CartRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSourceImpl(hiveService: ref.watch(hiveServiceProvider));
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    remoteDataSource: ref.watch(cartRemoteDataSourceProvider),
    localDataSource: ref.watch(cartLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final INetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CartItem>>> getCart() async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (isOnline) {
        final cartItemModels = await remoteDataSource.getCart();
        // Cache the cart items
        try {
          await localDataSource.cacheCartItems(cartItemModels);
        } catch (_) {}
        final cartItems = cartItemModels.map((model) => model.toEntity()).toList();
        return Right(cartItems);
      } else {
        // Offline: try to get from cache
        final cachedItems = await localDataSource.getCachedCartItems();
        final cartItems = cachedItems.map((model) => model.toEntity()).toList();
        return Right(cartItems);
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> addItem(CartItem item) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final cartItemModels = await remoteDataSource.addItem(
        productId: item.productId,
        quantity: item.quantity,
        size: item.size,
        color: item.color,
      );
      // Cache the updated cart
      try {
        await localDataSource.cacheCartItems(cartItemModels);
      } catch (_) {}
      final cartItems = cartItemModels.map((model) => model.toEntity()).toList();
      return Right(cartItems);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> updateItemQuantity(
    String productId,
    int quantity, {
    String? size,
    String? color,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final cartItemModels = await remoteDataSource.updateItemQuantity(
        productId: productId,
        quantity: quantity,
        size: size,
        color: color,
      );
      // Cache the updated cart
      try {
        await localDataSource.cacheCartItems(cartItemModels);
      } catch (_) {}
      final cartItems = cartItemModels.map((model) => model.toEntity()).toList();
      return Right(cartItems);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> removeItem(
    String productId, {
    String? size,
    String? color,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final cartItemModels = await remoteDataSource.removeItem(
        productId: productId,
        size: size,
        color: color,
      );
      // Cache the updated cart
      try {
        await localDataSource.cacheCartItems(cartItemModels);
      } catch (_) {}
      final cartItems = cartItemModels.map((model) => model.toEntity()).toList();
      return Right(cartItems);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      await remoteDataSource.clearCart();
      // Clear local cache
      try {
        await localDataSource.clearCache();
      } catch (_) {}
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> syncCart(List<CartItem> items) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return Left(NetworkFailure(message: 'No internet connection'));
      }

      final cartItemModels = items.map((item) => CartItemModel.fromEntity(item)).toList();
      final syncedCartItemModels = await remoteDataSource.syncCart(cartItemModels);
      // Cache the synced cart
      try {
        await localDataSource.cacheCartItems(syncedCartItemModels);
      } catch (_) {}
      final syncedCartItems = syncedCartItemModels.map((model) => model.toEntity()).toList();
      return Right(syncedCartItems);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}