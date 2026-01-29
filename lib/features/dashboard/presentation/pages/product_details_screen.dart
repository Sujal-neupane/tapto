import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/features/dashboard/data/models/cart_item_model.dart';
import 'package:tapto/features/dashboard/presentation/viewmodel/cart_viewmodel.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/custom_app_bar.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final String description;
  final List<String> sizes;
  final List<String> colors;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.description,
    required this.sizes,
    required this.colors,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  String? selectedSize;
  String? selectedColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Scaffold(
          backgroundColor: AppColors.surface,
          appBar: CustomAppBar(
            title: 'Product Details',
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: AppColors.primary),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with rounded corners and shadow
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.productImage.isNotEmpty
                        ? Image.network(
                            widget.productImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 240,
                          )
                        : Container(
                            height: 240,
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 120,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Product Name
                Text(
                  widget.productName,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Price
                Text(
                  '\$${widget.price.toStringAsFixed(2)}',
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Description
                Text(
                  widget.description,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Size selection
                Text('Size', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 12,
                  children: widget.sizes.map((size) {
                    final isSelected = selectedSize == size;
                    return ChoiceChip(
                      label: Text(size,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          )),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      onSelected: (_) => setState(() => selectedSize = size),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Color selection
                Text('Color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 12,
                  children: widget.colors.map((color) {
                    final isSelected = selectedColor == color;
                    return ChoiceChip(
                      label: Text(color,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          )),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      onSelected: (_) => setState(() => selectedColor = color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Add to Cart button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (selectedSize != null && selectedColor != null)
                        ? () {
                            developer.log(
                              'Adding to cart: Size=$selectedSize, Color=$selectedColor',
                              name: 'ProductDetailsScreen',
                            );
                            ref.read(cartViewModelProvider.notifier).addItem(
                              CartItemModel(
                                productId: widget.productId,
                                productName: widget.productName,
                                productImage: widget.productImage,
                                price: widget.price,
                                quantity: 1,
                                size: selectedSize!,
                                color: selectedColor!,
                              ),
                            );
                            Navigator.pop(context); // Close the modal first
                            // Show snackbar after pop to ensure context is valid
                            Future.delayed(const Duration(milliseconds: 300), () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.productName} added to cart ✓'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}