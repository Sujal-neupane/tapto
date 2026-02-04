import 'package:dio/dio.dart';
import 'package:tapto/core/api/api_endpoint.dart';
import 'package:tapto/features/products/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts({
    String? category,
    String? fashionType,
    bool? isActive,
  });
  Future<List<ProductModel>> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    List<String>? tags,
  });
  Future<List<ProductModel>> fetchAdminProducts();
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductModel>> fetchProducts({
    String? category,
    String? fashionType,
    bool? isActive,
  }) async {
    // Use public products endpoint for user-facing product listing
    final response = await dio.get(
      ApiEndpoints.products,
      queryParameters: {
        if (category != null) 'category': category,
        if (fashionType != null)
          'category': fashionType, // Backend uses 'category' for filtering
        if (isActive != null) 'isActive': isActive,
      },
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return (data['data'] as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    }
    return (data as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    List<String>? tags,
  }) async {
    final response = await dio.get(
      ApiEndpoints.products,
      queryParameters: {
        if (query != null && query.isNotEmpty) 'search': query,
        if (category != null) 'category': category,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
        'isActive': true,
      },
    );

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return (data['data'] as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    }
    return (data as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> fetchAdminProducts() async {
    final response = await dio.get(ApiEndpoints.adminProducts);

    final data = response.data;
    if (data is Map && data['data'] != null) {
      return (data['data'] as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    }
    return (data as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final response = await dio.post(
      ApiEndpoints.adminProducts,
      data: product.toJson(),
    );
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return ProductModel.fromJson(data['data']);
    }
    return ProductModel.fromJson(data);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await dio.put(
      ApiEndpoints.adminProductById(product.id),
      data: product.toJson(),
    );
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return ProductModel.fromJson(data['data']);
    }
    return ProductModel.fromJson(data);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await dio.delete(ApiEndpoints.adminProductById(productId));
  }
}
