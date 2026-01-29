import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:tapto/core/services/storage/user_session_service.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;
  final bool isLoading;
  final String? error;

  CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity);

  double get shippingFee => items.isEmpty ? 0 : 10.0;

  double get tax => subtotal * 0.13;

  double get total => subtotal + shippingFee + tax;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CartViewModel extends Notifier<CartState> {
  static const String _cartKey = 'shopping_cart';

  @override
  CartState build() {
    // Don't read your own provider here!
    return CartState();
  }

  Future<void> loadCart() async {
    try {    
      final prefs = ref.read(sharedPreferencesProvider);
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final List<dynamic> decoded = json.decode(cartJson);
        final items = decoded
            .map((item) => CartItemModel.fromJson(item))
            .toList();

        state = state.copyWith(items: items);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load cart');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final cartModels = state.items
          .map((item) => item.toJson())
          .toList();

      await prefs.setString(_cartKey, json.encode(cartModels));
    } catch (e) {
      state = state.copyWith(error: 'Failed to save cart');
    }
  }

  void addItem(CartItemModel item) {
  // Match by productId, size, and color for unique customization
  final existingIndex = state.items.indexWhere(
    (i) =>
        i.productId == item.productId &&
        i.size == item.size &&
        i.color == item.color,
  );

  List<CartItemModel> updatedItems;

  if (existingIndex >= 0) {
    // Item with same customization exists, increase quantity
    final existing = state.items[existingIndex];
    updatedItems = List.from(state.items);
    updatedItems[existingIndex] = existing.copyWith(
      quantity: existing.quantity + item.quantity,
    );
  } else {
    // New customization
    updatedItems = [...state.items, item];
  }

  state = state.copyWith(items: updatedItems);
  _saveCart();
}

  void removeItem(String productId, {String? size, String? color}) {
    final updatedItems = state.items.where((item) {
      if (size != null && color != null) {
        return !(item.productId == productId && item.size == size && item.color == color);
      }
      return item.productId != productId;
    }).toList().cast<CartItemModel>();

    state = state.copyWith(items: updatedItems);
    _saveCart();
  }

  void updateQuantity(String productId, int quantity, {String? size, String? color}) {
    if (quantity <= 0) {
      removeItem(productId, size: size, color: color);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.productId == productId &&
          (size == null || item.size == size) &&
          (color == null || item.color == color)) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    _saveCart();
  }

  void incrementQuantity(String productId, {String? size, String? color}) {
    final item = state.items.firstWhere((i) =>
        i.productId == productId &&
        (size == null || i.size == size) &&
        (color == null || i.color == color));
    updateQuantity(productId, item.quantity + 1, size: size, color: color);
  }

  void decrementQuantity(String productId, {String? size, String? color}) {
    final item = state.items.firstWhere((i) =>
        i.productId == productId &&
        (size == null || i.size == size) &&
        (color == null || i.color == color));
    updateQuantity(productId, item.quantity - 1, size: size, color: color);
  }

  void clearCart() {
    state = state.copyWith(items: []);
    _saveCart();
  }
}

final cartViewModelProvider =
    NotifierProvider<CartViewModel, CartState>(CartViewModel.new);