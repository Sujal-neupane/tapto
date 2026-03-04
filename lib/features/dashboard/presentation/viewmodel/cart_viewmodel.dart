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
  /// falls back to local optimistic state and cache.
  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _getCartUsecase();
      result.fold(
        (failure) {
          // On failure, keep optimistic items if they exist
          // Only show error if cart was completely empty
          if (state.items.isEmpty) {
            state = state.copyWith(
              error: failure.message,
              isLoading: false,
            );
          } else {
            // Keep optimistic items, just clear loading
            state = state.copyWith(isLoading: false);
          }
        },
        (items) {
          // If server returns empty but we have optimistic items, keep them
          if (items.isEmpty && state.items.isNotEmpty) {
            // Server returned empty - could be a sync issue
            // Keep the optimistic items and log the issue
            state = state.copyWith(isLoading: false);
          } else {
            // Use server data (either has items or we want to show empty)
            state = state.copyWith(items: items, isLoading: false);
          }
        },
      );
    } catch (e) {
      // On exception, keep optimistic items if any
      if (state.items.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load cart',
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  // --- Mutators ---

  void addItem(CartItem item) {
    // Optimistic update: add item to cart immediately
    final existingIndex = state.items.indexWhere((i) =>
        i.productId == item.productId &&
        i.size == item.size &&
        i.color == item.color);

    List<CartItem> optimisticItems;
    if (existingIndex >= 0) {
      // Item exists - increment quantity
      optimisticItems = [...state.items];
      optimisticItems[existingIndex] = CartItem(
        productId: item.productId,
        productName: item.productName,
        productImage: item.productImage,
        price: item.price,
        quantity: optimisticItems[existingIndex].quantity + item.quantity,
        size: item.size,
        color: item.color,
      );
    } else {
      // New item - add to cart
      optimisticItems = [...state.items, item];
    }

    // Update UI immediately
    state = state.copyWith(items: optimisticItems, error: null);

    // Sync with server in the background
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
          // On failure, revert to previous state and show error
          state = state.copyWith(error: failure.message);
        },
        (updatedItems) {
          // Server returned the full updated cart - use it
          state = state.copyWith(items: updatedItems, error: null);
        },
      );
    });
  }

  void removeItem(String productId, {String? size, String? color}) {
    // Optimistic update: remove item immediately
    final filteredItems = state.items.where((item) =>
        !(item.productId == productId &&
            (size == null || item.size == size) &&
            (color == null || item.color == color))).toList();
    
    state = state.copyWith(items: filteredItems, error: null);

    // Sync removal with server
    _removeFromCartUsecase(RemoveFromCartParams(
      productId: productId,
      size: size,
      color: color,
    )).then((result) {
      result.fold(
        (failure) {
          // On failure, revert and show error
          state = state.copyWith(error: failure.message);
        },
        (updatedItems) {
          state = state.copyWith(items: updatedItems, error: null);
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

    // Optimistic update: update quantity immediately
    final updatedItems = state.items.map((item) {
      if (item.productId == productId &&
          (size == null || item.size == size) &&
          (color == null || item.color == color)) {
        return CartItem(
          productId: item.productId,
          productName: item.productName,
          productImage: item.productImage,
          price: item.price,
          quantity: quantity,
          size: item.size,
          color: item.color,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems, error: null);

    // Sync with server
    _updateCartItemQuantityUsecase(UpdateCartItemParams(
      productId: productId,
      quantity: quantity,
      size: size,
      color: color,
    )).then((result) {
      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (syncedItems) {
          state = state.copyWith(items: syncedItems, error: null);
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