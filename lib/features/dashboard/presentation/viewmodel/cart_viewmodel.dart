import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/features/dashboard/domain/entities/cart_item.dart';
import 'package:tapto/features/dashboard/domain/usecases/cart_usecases.dart';

// --- Providers ---

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final bool isSyncing;
  final String? error;

  CartState({
    this.items = const [],
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity);

  double get shippingFee => items.isEmpty ? 0 : 10.0;

  double get tax => 0.0; // Will be calculated in viewmodel

  double get total => subtotal + shippingFee + tax;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    bool? isSyncing,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      // Defensive: old state objects from hot-reload may have null isSyncing
      isSyncing: isSyncing ?? ((this.isSyncing as bool?) ?? false),
      error: error,
    );
  }
}

class CartViewModel extends Notifier<CartState> {

  late final GetCartUsecase _getCartUsecase;
  late final AddToCartUsecase _addToCartUsecase;
  late final UpdateCartItemQuantityUsecase _updateCartItemQuantityUsecase;
  late final RemoveFromCartUsecase _removeFromCartUsecase;
  late final ClearCartUsecase _clearCartUsecase;
  late final SyncCartUsecase _syncCartUsecase;

  @override
  CartState build() {
    _getCartUsecase = ref.watch(getCartUsecaseProvider);
    _addToCartUsecase = ref.watch(addToCartUsecaseProvider);
    _updateCartItemQuantityUsecase = ref.watch(updateCartItemQuantityUsecaseProvider);
    _removeFromCartUsecase = ref.watch(removeFromCartUsecaseProvider);
    _clearCartUsecase = ref.watch(clearCartUsecaseProvider);
    _syncCartUsecase = ref.watch(syncCartUsecaseProvider);
    return CartState();
  }

  // --- Load Cart ---

  /// Loads the cart. Prefers server data when online + logged in,
  /// falls back to local SharedPreferences cache.
  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _getCartUsecase();
      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (items) {
          state = state.copyWith(items: items);
        },
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to load cart');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // --- Mutators ---

  void addItem(CartItem item) {
    state = state.copyWith(isLoading: true, error: null);
    _addToCartUsecase(AddToCartParams(
      productId: item.productId,
      productName: item.productName,
      productImage: item.productImage,
      price: item.price,
      quantity: item.quantity,
      size: item.size,
      color: item.color,
    )).then((result) {
      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message, isLoading: false);
        },
        (updatedItems) {
          state = state.copyWith(items: updatedItems, isLoading: false);
        },
      );
    });
  }

  void removeItem(String productId, {String? size, String? color}) {
    state = state.copyWith(isLoading: true, error: null);
    _removeFromCartUsecase(RemoveFromCartParams(
      productId: productId,
      size: size,
      color: color,
    )).then((result) {
      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message, isLoading: false);
        },
        (updatedItems) {
          state = state.copyWith(items: updatedItems, isLoading: false);
        },
      );
    });
  }

  void updateQuantity(String productId, int quantity,
      {String? size, String? color}) {
    if (quantity <= 0) {
      removeItem(productId, size: size, color: color);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    _updateCartItemQuantityUsecase(UpdateCartItemParams(
      productId: productId,
      quantity: quantity,
      size: size,
      color: color,
    )).then((result) {
      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message, isLoading: false);
        },
        (updatedItems) {
          state = state.copyWith(items: updatedItems, isLoading: false);
        },
      );
    });
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
    state = state.copyWith(isLoading: true, error: null);
    _clearCartUsecase().then((result) {
      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message, isLoading: false);
        },
        (_) {
          state = state.copyWith(items: [], isLoading: false);
        },
      );
    });
  }

  /// Force a full sync from local → server. Can be called manually
  /// (e.g. after login, or after regaining connectivity).
  Future<void> forceSyncToServer() async {
    state = state.copyWith(isSyncing: true, error: null);
    final result = await _syncCartUsecase(SyncCartParams(items: state.items));
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message, isSyncing: false);
      },
      (syncedItems) {
        state = state.copyWith(items: syncedItems, isSyncing: false);
      },
    );
  }
}

final cartViewModelProvider =
    NotifierProvider<CartViewModel, CartState>(CartViewModel.new);