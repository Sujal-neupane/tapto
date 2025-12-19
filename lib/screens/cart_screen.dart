import 'package:flutter/material.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
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
                  return ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: Text('Product ${index + 1}'),
                    subtitle: const Text('\$99.00'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {},
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
