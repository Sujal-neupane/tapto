import 'package:dio/dio.dart';
import 'package:tapto/features/products/data/models/product_model.dart';


abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts({String? category, bool? isActive});
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductModel>> fetchProducts({String? category, bool? isActive}) async {
    final response = await dio.get('/products', queryParameters: {
      if (category != null) 'category': category,
      if (isActive != null) 'isActive': isActive,
    });
    return (response.data as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final response = await dio.post('/products', data: product.toJson());
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await dio.put('/products/${product.id}', data: product.toJson());
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await dio.delete('/products/$productId');
  }
}