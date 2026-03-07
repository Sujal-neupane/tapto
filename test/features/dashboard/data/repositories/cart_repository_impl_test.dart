import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/features/dashboard/data/datasource/local/cart_local_datasource.dart';
import 'package:tapto/features/dashboard/data/datasource/remote/cart_remote_datasource.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/dashboard/data/repositories/cart_repository_impl.dart';
import 'package:tapto/features/dashboard/domain/entities/cart_item.dart';

class FakeNetworkInfo implements INetworkInfo {
  FakeNetworkInfo({required this.connected});

  bool connected;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged async* {
    yield connected;
  }
}

class FakeCartLocalDataSource implements CartLocalDataSource {
  List<CartItemModel> cachedItems;
  int cacheCalls = 0;
  int clearCalls = 0;

  FakeCartLocalDataSource({this.cachedItems = const []});

  @override
  Future<void> cacheCartItems(List<CartItemModel> items) async {
    cacheCalls++;
    cachedItems = List<CartItemModel>.from(items);
  }

  @override
  Future<void> clearCache() async {
    clearCalls++;
    cachedItems = [];
  }

  @override
  Future<List<CartItemModel>> getCachedCartItems() async {
    return List<CartItemModel>.from(cachedItems);
  }
}

class FakeCartRemoteDataSource implements CartRemoteDataSource {
  List<CartItemModel> remoteItems;
  int getCartCalls = 0;
  int addItemCalls = 0;
  int syncCalls = 0;
  int clearCalls = 0;
  bool throwOnGet = false;

  FakeCartRemoteDataSource({this.remoteItems = const []});

  @override
  Future<List<CartItemModel>> addItem({
    required String productId,
    required int quantity,
    String? size,
    String? color,
  }) async {
    addItemCalls++;
    return List<CartItemModel>.from(remoteItems);
  }

  @override
  Future<void> clearCart() async {
    clearCalls++;
  }

  @override
  Future<List<CartItemModel>> getCart() async {
    getCartCalls++;
    if (throwOnGet) {
      throw Exception('remote unavailable');
    }
    return List<CartItemModel>.from(remoteItems);
  }

  @override
  Future<List<CartItemModel>> removeItem({
    required String productId,
    String? size,
    String? color,
  }) async {
    return List<CartItemModel>.from(remoteItems);
  }

  @override
  Future<List<CartItemModel>> syncCart(List<CartItemModel> items) async {
    syncCalls++;
    return List<CartItemModel>.from(remoteItems);
  }

  @override
  Future<List<CartItemModel>> updateItemQuantity({
    required String productId,
    required int quantity,
    String? size,
    String? color,
  }) async {
    return List<CartItemModel>.from(remoteItems);
  }
}

void main() {
  CartItemModel makeModel({
    String id = 'p1',
    int quantity = 1,
    double price = 100,
  }) {
    return CartItemModel(
      productId: id,
      productName: 'Product $id',
      productImage: '/$id.jpg',
      price: price,
      quantity: quantity,
      size: 'M',
      color: 'Black',
    );
  }

  CartItem makeEntity({
    String id = 'p1',
    int quantity = 1,
    double price = 100,
  }) {
    return CartItem(
      productId: id,
      productName: 'Product $id',
      productImage: '/$id.jpg',
      price: price,
      quantity: quantity,
      size: 'M',
      color: 'Black',
    );
  }

  group('CartRepositoryImpl dashboard flows', () {
    test('getCart online returns remote data and caches it', () async {
      final remote = FakeCartRemoteDataSource(remoteItems: [makeModel()]);
      final local = FakeCartLocalDataSource();
      final network = FakeNetworkInfo(connected: true);

      final repository = CartRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: network,
      );

      final result = await repository.getCart();

      expect(result.isRight(), true);
      result.fold((_) => fail('Expected Right result'), (items) {
        expect(items.length, 1);
        expect(items.first.productId, 'p1');
      });
      expect(remote.getCartCalls, 1);
      expect(local.cacheCalls, 1);
    });

    test('getCart offline returns cached items', () async {
      final remote = FakeCartRemoteDataSource(remoteItems: [makeModel(id: 'x')]);
      final local = FakeCartLocalDataSource(cachedItems: [makeModel(id: 'cached')]);
      final network = FakeNetworkInfo(connected: false);

      final repository = CartRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: network,
      );

      final result = await repository.getCart();

      expect(result.isRight(), true);
      result.fold((_) => fail('Expected Right result'), (items) {
        expect(items.length, 1);
        expect(items.first.productId, 'cached');
      });
      expect(remote.getCartCalls, 0);
      expect(local.cacheCalls, 0);
    });

    test('addItem offline returns NetworkFailure', () async {
      final remote = FakeCartRemoteDataSource(remoteItems: [makeModel()]);
      final local = FakeCartLocalDataSource();
      final network = FakeNetworkInfo(connected: false);

      final repository = CartRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: network,
      );

      final result = await repository.addItem(makeEntity());

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left result'),
      );
      expect(remote.addItemCalls, 0);
    });

    test('syncCart online pushes local items and caches response', () async {
      final remote = FakeCartRemoteDataSource(
        remoteItems: [makeModel(id: 'synced', quantity: 2)],
      );
      final local = FakeCartLocalDataSource();
      final network = FakeNetworkInfo(connected: true);

      final repository = CartRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: network,
      );

      final result = await repository.syncCart([
        makeEntity(id: 'local', quantity: 3),
      ]);

      expect(result.isRight(), true);
      result.fold((_) => fail('Expected Right result'), (items) {
        expect(items.length, 1);
        expect(items.first.productId, 'synced');
      });
      expect(remote.syncCalls, 1);
      expect(local.cacheCalls, 1);
    });

    test('clearCart online clears remote and local cache', () async {
      final remote = FakeCartRemoteDataSource(remoteItems: [makeModel()]);
      final local = FakeCartLocalDataSource(cachedItems: [makeModel()]);
      final network = FakeNetworkInfo(connected: true);

      final repository = CartRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: network,
      );

      final result = await repository.clearCart();

      expect(result.isRight(), true);
      expect(remote.clearCalls, 1);
      expect(local.clearCalls, 1);
      expect(local.cachedItems, isEmpty);
    });

    test('getCart returns ServerFailure when remote throws online', () async {
      final remote = FakeCartRemoteDataSource(remoteItems: [makeModel()])
        ..throwOnGet = true;
      final local = FakeCartLocalDataSource();
      final network = FakeNetworkInfo(connected: true);

      final repository = CartRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: network,
      );

      final result = await repository.getCart();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left result'),
      );
    });
  });
}
