import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer' as developer;
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/dashboard/presentation/viewmodel/cart_viewmodel.dart';
import 'package:tapto/core/utils/currency_formatter.dart';
import '../../../../../app/theme/app_colors.dart';

class BottomCartBar extends ConsumerWidget {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final String? selectedSize;
  final String? selectedColor;
  final VoidCallback onItemAdded;

  const BottomCartBar({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.selectedSize,
    this.selectedColor,
    required this.onItemAdded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = ref.watch(currencyFormatterProvider);
    final canAddToCart = selectedSize != null && selectedColor != null;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
          border: Border(
            top: BorderSide(color: const Color(0xFFE9ECEF), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6C757D),
                    ),
                  ),
                  Text(
                    currencyFormatter(price),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212529),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: canAddToCart
                      ? () {
                          developer.log(
                            'Adding to cart: Size=$selectedSize, Color=$selectedColor',
                            name: 'ProductDetailsScreen',
                          );

                          ref
                              .read(cartViewModelProvider.notifier)
                              .addItem(
                                CartItemModel(
                                  productId: productId,
                                  productName: productName,
                                  productImage: productImage,
                                  price: price,
                                  quantity: 1,
                                  size: selectedSize!,
                                  color: selectedColor!,
                                ),
                              );

                          onItemAdded();

                          Future.delayed(const Duration(milliseconds: 300), () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Success!',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            '$productName ${'addedToCart'.tr()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            );
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAddToCart
                        ? AppColors.primary
                        : const Color(0xFFE9ECEF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: canAddToCart
                            ? Colors.white
                            : const Color(0xFF6C757D),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: canAddToCart
                              ? Colors.white
                              : const Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}