import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../products/data/models/product_model.dart';

class WishlistNotifier extends StateNotifier<List<ProductModel>> {
  WishlistNotifier() : super([]);

  void addToWishlist(ProductModel product) {
    // Check if product already exists in wishlist
    final exists = state.any((p) => p.id == product.id);
    if (!exists) {
      state = [...state, product];
    }
  }

  void removeFromWishlist(String productId) {
    state = state.where((product) => product.id != productId).toList();
  }

  void toggleWishlist(ProductModel product) {
    final exists = state.any((p) => p.id == product.id);
    if (exists) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }

  bool isInWishlist(String productId) {
    return state.any((product) => product.id == productId);
  }

  void clearWishlist() {
    state = [];
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<ProductModel>>((ref) {
  return WishlistNotifier();
});

// Helper provider to check if a specific product is in wishlist
final isInWishlistProvider = Provider.family<bool, String>((ref, productId) {
  final wishlist = ref.watch(wishlistProvider);
  return wishlist.any((product) => product.id == productId);
});

// Provider for wishlist count
final wishlistCountProvider = Provider<int>((ref) {
  return ref.watch(wishlistProvider).length;
});
