
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/cart_item_model.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addToCart(CartItemModel item) {
    // Check if item already exists, if so, increase quantity
    final index = state.indexWhere((e) => e.productId == item.productId);
    if (index != -1) {
      final CartItemModel updated = state[index].copyWith(
        quantity: state[index].quantity + item.quantity,
      );
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) updated else state[i]
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});