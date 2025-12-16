import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

class HomeSwipeScreen extends StatelessWidget {
  const HomeSwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {}, // filter later
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: List.generate(
            3,
            (index) => Draggable(
              childWhenDragging: const SizedBox.shrink(),
              feedback: _ProductCard(index: index),
              child: _ProductCard(index: index),
              onDragEnd: (details) {
                // swipe right = like
                // swipe left = skip
                // swipe up = details of the product
                // double tap = add to wishlist
              },
            ),
          ).reversed.toList(),
        ),
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
      margin: const EdgeInsets.all(AppSpacing.md),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
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
                  Text('Product ${index + 1}', style: AppTextStyles.body),
                  const SizedBox(height: 4),
                  Text('\$99.00', style: AppTextStyles.subHeading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
