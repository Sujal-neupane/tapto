import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/core/services/storage/storage_provider.dart';
import 'package:tapto/core/services/storage/user_session_service.dart';
import 'package:tapto/features/dashboard/data/datasource/remote/cart_remote_datasource.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';

// --- Providers ---

final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  return CartRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

class CartState {
  final List<CartItemModel> items;
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
    List<CartItemModel>? items,
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
  static const String _cartKey = 'shopping_cart';

  @override
  CartState build() {
    return CartState();
  }

  // --- Helpers ---

  bool get _isLoggedIn {
    try {
      return ref.read(tokenStorageServiceProvider).hasToken();
    } catch (_) {
      return false;
    }
  }

  Future<bool> get _isOnline async {
    try {
      return await ref.read(networkInfoProvider).isConnected;
    } catch (_) {
      return false;
    }
  }

  CartRemoteDataSource get _remote =>
      ref.read(cartRemoteDataSourceProvider);

  // --- Load Cart ---

  /// Loads the cart. Prefers server data when online + logged in,
  /// falls back to local SharedPreferences cache.
  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Always load local first for instant UI
      await _loadLocalCart();

      // Then try to fetch from server and merge
      if (_isLoggedIn && await _isOnline) {
        try {
          final serverItems = await _remote.getCart();
          if (serverItems.isNotEmpty) {
            // Server has data — use it as the source of truth
            state = state.copyWith(items: serverItems);
            await _saveLocalCart();
          } else if (state.items.isNotEmpty) {
            // Server is empty but we have local items — push to server
            await _syncToServer();
          }
        } catch (e) {
          // Server fetch failed — local cart is already loaded, just continue
          print('Cart sync fetch failed, using local: $e');
        }
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load cart');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadLocalCart() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      final List<dynamic> decoded = json.decode(cartJson);
      final items =
          decoded.map((item) => CartItemModel.fromJson(item)).toList();
      state = state.copyWith(items: items);
    }
  }

  Future<void> _saveLocalCart() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final cartModels = state.items.map((item) => item.toJson()).toList();
      await prefs.setString(_cartKey, json.encode(cartModels));
    } catch (e) {
      state = state.copyWith(error: 'Failed to save cart locally');
    }
  }

  /// Push the full local cart to the server via PUT /sync.
  Future<void> _syncToServer() async {
    if (!_isLoggedIn || !await _isOnline) return;
    state = state.copyWith(isSyncing: true);
    try {
      final serverItems = await _remote.syncCart(state.items);
      state = state.copyWith(items: serverItems, isSyncing: false);
      await _saveLocalCart();
    } catch (e) {
      // Sync failed silently — local state is still good
      state = state.copyWith(isSyncing: false);
      print('Cart sync to server failed: $e');
    }
  }

  // --- Mutators ---

  void addItem(CartItemModel item) {
    final existingIndex = state.items.indexWhere(
      (i) =>
          i.productId == item.productId &&
          i.size == item.size &&
          i.color == item.color,
    );

    List<CartItemModel> updatedItems;

    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      updatedItems = List.from(state.items);
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    } else {
      updatedItems = [...state.items, item];
    }

    state = state.copyWith(items: updatedItems);
    _saveLocalCart();
    _syncToServer();
  }

  void removeItem(String productId, {String? size, String? color}) {
    final updatedItems = state.items.where((item) {
      if (size != null && color != null) {
        return !(item.productId == productId &&
            item.size == size &&
            item.color == color);
      }
      return item.productId != productId;
    }).toList().cast<CartItemModel>();

    state = state.copyWith(items: updatedItems);
    _saveLocalCart();
    _syncToServer();
  }

  void updateQuantity(String productId, int quantity,
      {String? size, String? color}) {
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
    _saveLocalCart();
    _syncToServer();
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
    _saveLocalCart();
    _clearOnServer();
  }

  Future<void> _clearOnServer() async {
    if (!_isLoggedIn || !await _isOnline) return;
    try {
      await _remote.clearCart();
    } catch (e) {
      print('Cart clear on server failed: $e');
    }
  }

  /// Force a full sync from local → server. Can be called manually
  /// (e.g. after login, or after regaining connectivity).
  Future<void> forceSyncToServer() async {
    await _syncToServer();
  }
}

final cartViewModelProvider =
    NotifierProvider<CartViewModel, CartState>(CartViewModel.new);