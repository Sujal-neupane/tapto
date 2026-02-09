import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/utils/image_utils.dart';
import 'package:tapto/core/widgets/cached_image.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/dashboard/presentation/provider/wishlist_provider.dart';
import 'package:tapto/features/dashboard/presentation/viewmodel/cart_viewmodel.dart';
import 'package:tapto/core/utils/currency_formatter.dart';
import '../../../../app/theme/app_colors.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, ref, wishlist.length),
            Expanded(
              child: wishlist.isEmpty
                  ? _buildEmptyState(context)
                  : _buildWishlistBody(context, ref, wishlist),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App bar ───
  Widget _buildAppBar(BuildContext context, WidgetRef ref, int count) {
    return const SizedBox.shrink();
  }

  // ─── Empty state ───
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 56,
                color: AppColors.error.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'yourWishlistIsEmpty',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ).tr(),
            const SizedBox(height: 8),
            Text(
              'doubleTapProductsToAdd',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ).tr(),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                icon: const Icon(Icons.storefront_rounded, size: 20),
                label: const Text(
                  'startExploring',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ).tr(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Wishlist body ───
  Widget _buildWishlistBody(
    BuildContext context,
    WidgetRef ref,
    List wishlist,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: wishlist.length,
      itemBuilder: (context, index) {
        final product = wishlist[index];
        final imageUrl = product.images.isNotEmpty
            ? ImageUtils.getImageUrl(product.images.first)
            : '';

        return _WishlistItemCard(
          product: product,
          imageUrl: imageUrl,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(12),
              ),
            );
          },
        );
      },
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, product) {
    if (product.colors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('productHasNoColors').tr(),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
      return;
    }

    final cartItem = CartItemModel(
      productId: product.id,
      productName: product.name,
      productImage: product.images.isNotEmpty
          ? ImageUtils.getImageUrl(product.images.first)
          : '',
      price: product.price,
      quantity: 1,
      color: product.colors.first,
      size: product.sizes.isNotEmpty ? product.sizes.first : 'M',
    );

    ref.read(cartViewModelProvider.notifier).addItem(cartItem);
    ref.read(wishlistProvider.notifier).removeFromWishlist(product.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('${product.name} added to cart')),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }
}

// ─── Wishlist item card ───
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
    final currencyFormatter = ref.watch(currencyFormatterProvider);
    final hasDiscount = product.discount != null && product.discount > 0;

    return Dismissible(
      key: Key(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  // ─ Product image ─
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 110,
                          height: 110,
                          color: const Color(0xFFF0F2F5),
                          child: AppCachedImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: _imagePlaceholder(),
                          ),
                        ),
                      ),
                      if (hasDiscount)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${product.discount.toInt()}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // ─ Product details ─
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + remove
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: onRemove,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Category
                        Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Size / color chips
                        if (product.sizes.isNotEmpty ||
                            product.colors.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (product.sizes.isNotEmpty)
                                  _chip('${product.sizes.length} sizes'),
                                if (product.colors.isNotEmpty)
                                  _chip('${product.colors.length} colors'),
                              ],
                            ),
                          ),
                        // Price
                        Text(
                          currencyFormatter(product.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ─ Add to cart button ─
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAddToCart,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'addToCart',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ).tr(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Icon(Icons.image_outlined, color: Colors.grey[350], size: 32),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
