import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/api/api_endpoint.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/dashboard/presentation/provider/wishlist_provider.dart';
import 'package:tapto/features/dashboard/presentation/viewmodel/cart_viewmodel.dart';
import 'package:tapto/core/utils/currency_formatter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  String _getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiEndpoints.baseUrl}/$path';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final screenSize = MediaQuery.of(context).size;
    final textScaler = MediaQuery.of(context).textScaler;
    final isTablet = screenSize.width > 600;
    final iconSize = min(50.0, screenSize.width * 0.1); // Max 50, or 10% of width
    final containerSize = min(100.0, screenSize.width * 0.2); // Max 100, or 20% of width
    final titleFontSize = min(20.0, 18 * textScaler.scale(1.0) * (isTablet ? 1.1 : 1.0));

    if (wishlist.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: iconSize,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'yourWishlistIsEmpty',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ).tr(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'doubleTapProductsToAdd',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: min(16.0, 14 * textScaler.scale(1.0)),
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ).tr(),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'startExploring',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ).tr(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Wishlist (${wishlist.length})'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (wishlist.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showClearDialog(context, ref);
              },
            ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: wishlist.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = wishlist[index];
          return _WishlistItemCard(
            product: product,
            imageUrl: product.images.isNotEmpty 
                ? _getImageUrl(product.images.first) 
                : '',
            onAddToCart: () {
              HapticFeedback.mediumImpact();
              _addToCart(context, ref, product);
            },
            onRemove: () {
              HapticFeedback.lightImpact();
              ref.read(wishlistProvider.notifier).removeFromWishlist(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} removed from wishlist'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, product) {
    if (product.colors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('productHasNoColors').tr(),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cartItem = CartItemModel(
      productId: product.id,
      productName: product.name,
      productImage: product.images.isNotEmpty 
          ? _getImageUrl(product.images.first) 
          : '',
      price: product.price,
      quantity: 1,
      color: product.colors.first,
      size: product.sizes.isNotEmpty ? product.sizes.first : 'M',
    );

    ref.read(cartViewModelProvider.notifier).addItem(cartItem);
    
    // Optionally remove from wishlist after adding to cart
    ref.read(wishlistProvider.notifier).removeFromWishlist(product.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart ✓'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            const Text('clearWishlist').tr(),
          ],
        ),
        content: const Text('confirmClearWishlist').tr(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('cancel').tr(),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(wishlistProvider.notifier).clearWishlist();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('wishlistCleared').tr(),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('clearAll').tr(),
          ),
        ],
      ),
    );
  }
}

class _WishlistItemCard extends ConsumerWidget {
  final dynamic product;
  final String imageUrl;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;

  const _WishlistItemCard({
    required this.product,
    required this.imageUrl,
    required this.onAddToCart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          )
                        : Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${ref.watch(currencyFormatterProvider)(product.price)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (product.discount != null && product.discount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${product.discount.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Remove Button
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.grey[400],
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Add to Cart Button
          InkWell(
            onTap: onAddToCart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'addToCart',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ).tr(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
