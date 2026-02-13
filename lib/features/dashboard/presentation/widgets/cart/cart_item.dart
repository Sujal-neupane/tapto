import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/cached_image.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../presentation/viewmodel/cart_viewmodel.dart';
import 'cart_chip.dart';
import 'cart_image_placeholder.dart';
import 'quantity_button.dart';

class CartItemWidget extends ConsumerWidget {
  final CartItem item;
  final VoidCallback? onTap;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surface,
                ),
                child: item.productImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppCachedImage(
                          imageUrl: item.productImage,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const CartImagePlaceholder(),
              ),
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Variants
                    if ((item.size != null && item.size!.isNotEmpty) ||
                        (item.color != null && item.color!.isNotEmpty))
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (item.size != null && item.size!.isNotEmpty)
                            CartChip(text: 'Size: ${item.size!.toUpperCase()}'),
                          if (item.color != null && item.color!.isNotEmpty)
                            CartChip(text: item.color!),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // Price and Quantity
                    Row(
                      children: [
                        Text(
                          'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        // Quantity controls
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              QuantityButton(
                                icon: Icons.remove_rounded,
                                onTap: () {
                                  if (item.quantity > 1) {
                                    ref.read(cartViewModelProvider.notifier)
                                        .updateQuantity(item.productId, item.quantity - 1);
                                  }
                                },
                              ),
                              Container(
                                width: 36,
                                alignment: Alignment.center,
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              QuantityButton(
                                icon: Icons.add_rounded,
                                onTap: () {
                                  ref.read(cartViewModelProvider.notifier)
                                      .updateQuantity(item.productId, item.quantity + 1);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Remove Button
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                ref.read(cartViewModelProvider.notifier)
                    .removeItem(item.productId);
              },
              icon: Icon(
                Icons.delete_outline,
                size: 16,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
              label: Text(
                'Remove',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.error.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}