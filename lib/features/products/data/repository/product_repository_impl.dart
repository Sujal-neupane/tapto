import 'package:tapto/features/products/data/datasource/local/product_local_datasource.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repository/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ProductEntity>> getProducts({String? category, bool? isActive}) async {
    final models = await localDataSource.getProducts(category: category, isActive: isActive);
    return models;
  }

  @override
  Future<ProductEntity> addProduct(ProductEntity product) async {
    final model = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.category,
      isActive: product.isActive,
      images: product.images,
      stock: product.stock,
      tags: product.tags,
      sizes: product.sizes,
      colors: product.colors,
      createdBy: product.createdBy,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
    await localDataSource.addProduct(model);
    return model;
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    final model = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.category,
      isActive: product.isActive,
      images: product.images,
      stock: product.stock,
      tags: product.tags,
      sizes: product.sizes,
      colors: product.colors,
      createdBy: product.createdBy,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
    await localDataSource.updateProduct(model);
    return model;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await localDataSource.deleteProduct(productId);
  }
}