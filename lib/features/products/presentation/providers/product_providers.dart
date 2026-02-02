import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:tapto/features/products/data/datasource/remote/product_remote_datasource.dart';
import 'package:tapto/features/products/data/models/product_model.dart';

/// Provider for ProductRemoteDataSource
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductRemoteDataSourceImpl(dio);
});

/// Provider to fetch all products (for admin)
final adminProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final dataSource = ref.watch(productRemoteDataSourceProvider);
  return dataSource.fetchAdminProducts();
});

/// Helper function to convert user preference to product category
String? _preferenceToCategory(String? preference) {
  if (preference == null) return null;
  // Map "Mens Fashion" -> "Men", "Womens Fashion" -> "Women"
  if (preference.toLowerCase().contains('men')) return 'Men';
  if (preference.toLowerCase().contains('women')) return 'Women';
  return preference;
}

/// Provider to fetch products based on user's fashion preference
final userProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final dataSource = ref.watch(productRemoteDataSourceProvider);
  final authState = ref.watch(authViewModelProvider);
  
  // Get user's preference and convert to category format
  final preference = authState.user?.preference;
  final category = _preferenceToCategory(preference);
  
  // Fetch products filtered by user's preference
  return dataSource.fetchProducts(
    fashionType: category,
    isActive: true,
  );
});

/// Provider to fetch products by specific fashion type
final productsByFashionTypeProvider = FutureProvider.family<List<ProductModel>, String?>((ref, fashionType) async {
  final dataSource = ref.watch(productRemoteDataSourceProvider);
  return dataSource.fetchProducts(
    fashionType: fashionType,
    isActive: true,
  );
});

/// Provider to fetch products by category
final productsByCategoryProvider = FutureProvider.family<List<ProductModel>, String>((ref, category) async {
  final dataSource = ref.watch(productRemoteDataSourceProvider);
  return dataSource.fetchProducts(
    category: category,
    isActive: true,
  );
});

/// State for product operations (add, update, delete)
class ProductOperationState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const ProductOperationState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  ProductOperationState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return ProductOperationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Notifier for product operations
class ProductOperationNotifier extends Notifier<ProductOperationState> {
  @override
  ProductOperationState build() => const ProductOperationState();

  Future<bool> deleteProduct(String productId) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    
    try {
      final dataSource = ref.read(productRemoteDataSourceProvider);
      await dataSource.deleteProduct(productId);
      
      // Invalidate the products list to refresh
      ref.invalidate(adminProductsProvider);
      ref.invalidate(userProductsProvider);
      
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const ProductOperationState();
  }
}

final productOperationProvider = NotifierProvider<ProductOperationNotifier, ProductOperationState>(
  ProductOperationNotifier.new,
);

/// Provider to delete a product by ID (returns a future)
final deleteProductProvider = FutureProvider.family<bool, String>((ref, productId) async {
  final dataSource = ref.read(productRemoteDataSourceProvider);
  await dataSource.deleteProduct(productId);
  ref.invalidate(adminProductsProvider);
  ref.invalidate(userProductsProvider);
  return true;
});

/// Search filter parameters
class SearchFilters {
  final String query;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? tags;

  const SearchFilters({
    this.query = '',
    this.category,
    this.minPrice,
    this.maxPrice,
    this.tags,
  });

  SearchFilters copyWith({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    List<String>? tags,
    bool clearCategory = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearTags = false,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      tags: clearTags ? null : (tags ?? this.tags),
    );
  }

  bool get hasFilters => category != null || minPrice != null || maxPrice != null || (tags != null && tags!.isNotEmpty);
}

/// State notifier for search filters
class SearchFiltersNotifier extends StateNotifier<SearchFilters> {
  SearchFiltersNotifier() : super(const SearchFilters());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(category: category);
    }
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(
      minPrice: min,
      maxPrice: max,
      clearMinPrice: min == null,
      clearMaxPrice: max == null,
    );
  }

  void setTags(List<String>? tags) {
    if (tags == null || tags.isEmpty) {
      state = state.copyWith(clearTags: true);
    } else {
      state = state.copyWith(tags: tags);
    }
  }

  void clearFilters() {
    state = SearchFilters(query: state.query);
  }

  void clearAll() {
    state = const SearchFilters();
  }
}

final searchFiltersProvider = StateNotifierProvider<SearchFiltersNotifier, SearchFilters>(
  (ref) => SearchFiltersNotifier(),
);

/// Provider to fetch search results
final searchResultsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final dataSource = ref.watch(productRemoteDataSourceProvider);
  final filters = ref.watch(searchFiltersProvider);
  
  // Only search if there's a query or filters
  if (filters.query.isEmpty && !filters.hasFilters) {
    return [];
  }
  
  return dataSource.searchProducts(
    query: filters.query.isEmpty ? null : filters.query,
    category: filters.category,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
    tags: filters.tags,
  );
});
