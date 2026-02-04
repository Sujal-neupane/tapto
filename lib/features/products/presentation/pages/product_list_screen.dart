import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tapto/core/utils/currency_formatter.dart';

import '../../domain/entities/product_entity.dart';

// Minimal ProductViewModel implementation to fix the missing type error
class ProductViewModel extends StateNotifier<AsyncValue<List<ProductEntity>>> {
  ProductViewModel() : super(const AsyncValue.loading());
}


final productViewModelProvider = StateNotifierProvider<ProductViewModel, AsyncValue<List<ProductEntity>>>(
  (ref) => throw UnimplementedError(), // Provide your repository here
);

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productViewModelProvider);
    final currencyFormatter = ref.watch(currencyFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: productState.when(
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text(product.category),
              trailing: Text(currencyFormatter(product.price)),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add product screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}