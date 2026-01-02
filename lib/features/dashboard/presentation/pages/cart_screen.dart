import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/custom_app_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Shopping Cart',
        subtitle: '3 items',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: 3,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '\$${(99.99 + (index * 10)).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(
                                              Icons.remove,
                                              size: 14,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: AppColors.border,
                                              ),
                                              right: BorderSide(
                                                color: AppColors.border,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            '1',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(
                                              Icons.add,
                                              size: 14,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(),
            const SizedBox(height: AppSpacing.sm),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.subHeading),
                Text('\$297.00', style: AppTextStyles.subHeading),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
