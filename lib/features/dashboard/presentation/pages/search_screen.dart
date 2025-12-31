import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search products, brands...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Expanded(
              child: ListView.separated(
                itemCount: 8,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_bag),
                    ),
                    title: Text(
                      'Product ${index + 1}',
                      style: AppTextStyles.body,
                    ),
                    subtitle: const Text('\$99.00'),
                    onTap: () =>
                        Navigator.pushNamed(context, '/product-details'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
