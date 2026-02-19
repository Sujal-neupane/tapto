import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/dashboard/data/repositories/cart_repository_impl.dart';
import 'package:tapto/features/dashboard/domain/entities/cart_item.dart';
import 'package:tapto/features/dashboard/domain/repositories/cart_repository.dart';

final getCartUsecaseProvider = Provider<GetCartUsecase>((ref) {
  return GetCartUsecase(ref.watch(cartRepositoryProvider));
});

final addToCartUsecaseProvider = Provider<AddToCartUsecase>((ref) {
  return AddToCartUsecase(ref.watch(cartRepositoryProvider));
});

final updateCartItemQuantityUsecaseProvider = Provider<UpdateCartItemQuantityUsecase>((ref) {
  return UpdateCartItemQuantityUsecase(ref.watch(cartRepositoryProvider));
});

final removeFromCartUsecaseProvider = Provider<RemoveFromCartUsecase>((ref) {
  return RemoveFromCartUsecase(ref.watch(cartRepositoryProvider));
});

final clearCartUsecaseProvider = Provider<ClearCartUsecase>((ref) {
  return ClearCartUsecase(ref.watch(cartRepositoryProvider));
});

final syncCartUsecaseProvider = Provider<SyncCartUsecase>((ref) {
  return SyncCartUsecase(ref.watch(cartRepositoryProvider));
});

class GetCartUsecase implements UsecaseWithoutParms<List<CartItem>> {
  final CartRepository repository;

  GetCartUsecase(this.repository);

  @override
  Future<Either<Failure, List<CartItem>>> call() {
    return repository.getCart();
  }
}

class AddToCartUsecase implements UsecaseWithParms<List<CartItem>, AddToCartParams> {
  final CartRepository repository;

  AddToCartUsecase(this.repository);

  @override
  Future<Either<Failure, List<CartItem>>> call(AddToCartParams params) {
    final cartItem = CartItem(
      productId: params.productId,
      productName: params.productName,
      productImage: params.productImage,
      price: params.price,
      quantity: params.quantity,
      size: params.size,
      color: params.color,
    );
    return repository.addItem(cartItem);
  }
}

class UpdateCartItemQuantityUsecase implements UsecaseWithParms<List<CartItem>, UpdateCartItemParams> {
  final CartRepository repository;

  UpdateCartItemQuantityUsecase(this.repository);

  @override
  Future<Either<Failure, List<CartItem>>> call(UpdateCartItemParams params) {
    return repository.updateItemQuantity(
      params.productId,
      params.quantity,
      size: params.size,
      color: params.color,
    );
  }
}

class RemoveFromCartUsecase implements UsecaseWithParms<List<CartItem>, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCartUsecase(this.repository);

  @override
  Future<Either<Failure, List<CartItem>>> call(RemoveFromCartParams params) {
    return repository.removeItem(
      params.productId,
      size: params.size,
      color: params.color,
    );
  }
}

class ClearCartUsecase implements UsecaseWithoutParms<void> {
  final CartRepository repository;

  ClearCartUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call() {
    return repository.clearCart();
  }
}

class SyncCartUsecase implements UsecaseWithParms<List<CartItem>, SyncCartParams> {
  final CartRepository repository;

  SyncCartUsecase(this.repository);

  @override
  Future<Either<Failure, List<CartItem>>> call(SyncCartParams params) {
    return repository.syncCart(params.items);
  }
}

// Parameters
class AddToCartParams {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? size;
  final String? color;

  AddToCartParams({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.size,
    this.color,
  });
}

class UpdateCartItemParams {
  final String productId;
  final int quantity;
  final String? size;
  final String? color;

  UpdateCartItemParams({
    required this.productId,
    required this.quantity,
    this.size,
    this.color,
  });
}

class RemoveFromCartParams {
  final String productId;
  final String? size;
  final String? color;

  RemoveFromCartParams({
    required this.productId,
    this.size,
    this.color,
  });
}

class SyncCartParams {
  final List<CartItem> items;

  SyncCartParams({required this.items});
}