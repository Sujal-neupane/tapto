import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/features/dashboard/domain/entities/cart_item.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCart();
  Future<Either<Failure, List<CartItem>>> addItem(CartItem item);
  Future<Either<Failure, List<CartItem>>> updateItemQuantity(String productId, int quantity, {String? size, String? color});
  Future<Either<Failure, List<CartItem>>> removeItem(String productId, {String? size, String? color});
  Future<Either<Failure, void>> clearCart();
  Future<Either<Failure, List<CartItem>>> syncCart(List<CartItem> items);
}