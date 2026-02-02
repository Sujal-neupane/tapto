import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/api/api_endpoint.dart';
import 'package:tapto/features/dashboard/presentation/pages/product_details_screen.dart';
import 'package:tapto/features/dashboard/presentation/provider/wishlist_provider.dart';
import 'package:tapto/features/products/data/models/product_model.dart';
import 'package:tapto/features/products/presentation/providers/product_providers.dart';
import '../../../../app/theme/app_colors.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiEndpoints.baseUrl}/$path';
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final filters = ref.watch(searchFiltersProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Search Products'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (filters.hasFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(searchFiltersProvider.notifier).clearFilters();
              },
              tooltip: 'Clear filters',
            ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterSheet(context),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products, brands...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchFiltersProvider.notifier).setQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _debouncer.run(() {
                  ref.read(searchFiltersProvider.notifier).setQuery(value);
                });
              },
            ),
          ),

          // Active Filters Chips
          if (filters.hasFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (filters.category != null)
                      _FilterChip(
                        label: filters.category!,
                        onRemove: () => ref.read(searchFiltersProvider.notifier).setCategory(null),
                      ),
                    if (filters.minPrice != null || filters.maxPrice != null)
                      _FilterChip(
                        label: '\$${filters.minPrice?.toInt() ?? 0} - \$${filters.maxPrice?.toInt() ?? '∞'}',
                        onRemove: () => ref.read(searchFiltersProvider.notifier).setPriceRange(null, null),
                      ),
                    if (filters.tags != null && filters.tags!.isNotEmpty)
                      ...filters.tags!.map((tag) => _FilterChip(
                            label: tag,
                            onRemove: () {
                              final newTags = List<String>.from(filters.tags!)..remove(tag);
                              ref.read(searchFiltersProvider.notifier).setTags(newTags.isEmpty ? null : newTags);
                            },
                          )),
                  ],
                ),
              ),
            ),

          // Results
          Expanded(
            child: searchResults.when(
              data: (products) {
                if (filters.query.isEmpty && !filters.hasFilters) {
                  return _buildInitialState();
                }
                if (products.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildProductGrid(products);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'Search for products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Type in the search bar to find products',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No products found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Something went wrong'),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(searchResultsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(
          product: product,
          imageUrl: product.images.isNotEmpty ? _getImageUrl(product.images.first) : '',
          onTap: () {
            final allImageUrls = product.images
                .map((img) => _getImageUrl(img))
                .toList();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(
                  productId: product.id,
                  productName: product.name,
                  productImage: product.images.isNotEmpty ? _getImageUrl(product.images.first) : '',
                  productImages: allImageUrls,
                  price: product.price,
                  description: product.description,
                  sizes: product.sizes,
                  colors: product.colors,
                ),
              ),
            );
          },
          onFavorite: () {
            ref.read(wishlistProvider.notifier).toggleWishlist(product);
            final isNowInWishlist = ref.read(wishlistProvider).any((p) => p.id == product.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isNowInWishlist ? 'Added to wishlist' : 'Removed from wishlist'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          isInWishlist: ref.watch(wishlistProvider).any((p) => p.id == product.id),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

// Debouncer helper class
class Debouncer {
  final int milliseconds;
  VoidCallback? _action;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _action = action;
    Future.delayed(Duration(milliseconds: milliseconds), () {
      if (_action == action) {
        action();
      }
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        deleteIconColor: AppColors.primary,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool isInWishlist;

  const _ProductCard({
    required this.product,
    required this.imageUrl,
    required this.onTap,
    required this.onFavorite,
    required this.isInWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.image, color: Colors.grey[400]),
                          )
                        : Icon(Icons.image, color: Colors.grey[400]),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isInWishlist ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (product.discount != null && product.discount! > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${product.discount!.toInt()}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    final filters = ref.read(searchFiltersProvider);
    _selectedCategory = filters.category;
    _priceRange = RangeValues(
      filters.minPrice ?? 0,
      filters.maxPrice ?? 1000,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _priceRange = const RangeValues(0, 1000);
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category Filter
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Men', 'Women'].map((category) {
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategory = selected ? category : null);
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Price Range Filter
          const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '\$${_priceRange.start.toInt()}',
              '\$${_priceRange.end.toInt()}',
            ),
            onChanged: (values) => setState(() => _priceRange = values),
            activeColor: AppColors.primary,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${_priceRange.start.toInt()}'),
              Text('\$${_priceRange.end.toInt()}'),
            ],
          ),
          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final notifier = ref.read(searchFiltersProvider.notifier);
                notifier.setCategory(_selectedCategory);
                if (_priceRange.start > 0 || _priceRange.end < 1000) {
                  notifier.setPriceRange(_priceRange.start, _priceRange.end);
                } else {
                  notifier.setPriceRange(null, null);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
