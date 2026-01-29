import 'package:hive/hive.dart';
import 'package:tapto/features/products/data/models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts({String? category, bool? isActive});
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box<ProductModel> productBox;

  ProductLocalDataSourceImpl(this.productBox);

  @override
  Future<List<ProductModel>> getProducts({String? category, bool? isActive}) async {
    final products = productBox.values.where((product) {
      final matchesCategory = category == null || product.category == category;
      final matchesActive = isActive == null || product.isActive == isActive;
      return matchesCategory && matchesActive;
    }).toList();
    return products;
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await productBox.put(product.id, product);
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await productBox.put(product.id, product);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await productBox.delete(productId);
  }
}