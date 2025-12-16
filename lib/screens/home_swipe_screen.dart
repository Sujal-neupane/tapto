import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class HomeSwipeScreen extends StatelessWidget {
  const HomeSwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(
          5,
          (index) => Draggable(
            childWhenDragging: const SizedBox.shrink(),
            feedback: _ProductCard(index: index),
            child: _ProductCard(index: index),
            onDragEnd: (details) {
              // left = skip
              // right = wishlist
              //up = product detail
              // double tap for wishlist
            },
          ),
        ).reversed.toList(),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final int index;
  const _ProductCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  size: 120,
                  color: AppColors.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product ${index + 1}', style: AppTextStyles.subHeading),
                  const SizedBox(height: AppSpacing.xs),
                  Text('\$99.00', style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
