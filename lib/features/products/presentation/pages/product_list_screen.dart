import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tapto/core/utils/currency_formatter.dart';

import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import 'product_filter_screen.dart';

// Minimal ProductViewModel implementation to fix the missing type error
class ProductViewModel extends StateNotifier<AsyncValue<List<ProductEntity>>> {
  ProductViewModel() : super(const AsyncValue.loading());
}

final productViewModelProvider =
    StateNotifierProvider<ProductViewModel, AsyncValue<List<ProductEntity>>>(
      (ref) => throw UnimplementedError(), // Provide your repository here
    );

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productViewModelProvider);
    final filters = ref.watch(searchFiltersProvider);
    final currencyFormatter = ref.watch(currencyFormatterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('products'.tr()),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filters.hasFilters,
              child: const Icon(Icons.filter_list, color: Colors.black),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductFilterScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: productState.when(
        data: (products) =>
            _buildProductList(products, filters, currencyFormatter),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${'error'.tr()}: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add product screen
        },
        backgroundColor: const Color(0xFF1687FF),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductList(
    List<ProductEntity> products,
    SearchFilters filters,
    String Function(double) currencyFormatter,
  ) {
    // Apply filters
    final filteredProducts = _filterProducts(products, filters);

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'noProductsFound'.tr(),
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'tryAdjustingFilters'.tr(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: product.images.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(product.images.first),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: product.images.isEmpty ? Colors.grey.shade200 : null,
              ),
              child: product.images.isEmpty
                  ? const Icon(Icons.image, color: Colors.grey)
                  : null,
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  currencyFormatter(product.price),
                  style: const TextStyle(
                    color: Color(0xFF1687FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: product.stock > 0
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.stock > 0 ? 'inStock'.tr() : 'outOfStock'.tr(),
                style: TextStyle(
                  color: product.stock > 0
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () {
              // TODO: Navigate to product details
            },
          ),
        );
      },
    );
  }

  List<ProductEntity> _filterProducts(
    List<ProductEntity> products,
    SearchFilters filters,
  ) {
    return products.where((product) {
      // Filter by search query
      if (filters.query.isNotEmpty) {
        final query = filters.query.toLowerCase();
        if (!product.name.toLowerCase().contains(query) &&
            !product.description.toLowerCase().contains(query) &&
            !product.category.toLowerCase().contains(query) &&
            !(product.subcategory?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Filter by category
      if (filters.category != null && product.category != filters.category) {
        return false;
      }

      // Filter by price range
      if (filters.minPrice != null && product.price < filters.minPrice!) {
        return false;
      }
      if (filters.maxPrice != null && product.price > filters.maxPrice!) {
        return false;
      }

      // Filter by tags (sizes, colors, other tags)
      if (filters.tags != null && filters.tags!.isNotEmpty) {
        final productTags = [
          ...product.sizes,
          ...product.colors,
          ...product.tags,
        ];

        // Check if product has any of the selected tags
        final hasMatchingTag = filters.tags!.any(
          (filterTag) => productTags.any(
            (productTag) => productTag.toLowerCase() == filterTag.toLowerCase(),
          ),
        );

        if (!hasMatchingTag) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
