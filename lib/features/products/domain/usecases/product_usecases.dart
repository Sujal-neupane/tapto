import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/products/data/repository/product_repository_impl.dart';
import 'package:tapto/features/products/domain/entities/product_entity.dart';
import 'package:tapto/features/products/domain/repository/product_repository.dart';

final getProductsUsecaseProvider = Provider<GetProductsUsecase>((ref) {
  return GetProductsUsecase(ref.watch(productRepositoryProvider));
});

final addProductUsecaseProvider = Provider<AddProductUsecase>((ref) {
  return AddProductUsecase(ref.watch(productRepositoryProvider));
});

final updateProductUsecaseProvider = Provider<UpdateProductUsecase>((ref) {
  return UpdateProductUsecase(ref.watch(productRepositoryProvider));
});

final deleteProductUsecaseProvider = Provider<DeleteProductUsecase>((ref) {
  return DeleteProductUsecase(ref.watch(productRepositoryProvider));
});

class GetProductsUsecase implements UsecaseWithParms<List<ProductEntity>, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUsecase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(GetProductsParams params) async {
    try {
      final result = await repository.getProducts(
        category: params.category,
        isActive: params.isActive,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class AddProductUsecase implements UsecaseWithParms<ProductEntity, AddProductParams> {
  final ProductRepository repository;

  AddProductUsecase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(AddProductParams params) async {
    try {
      final result = await repository.addProduct(params.product);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class UpdateProductUsecase implements UsecaseWithParms<ProductEntity, UpdateProductParams> {
  final ProductRepository repository;

  UpdateProductUsecase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(UpdateProductParams params) async {
    try {
      final result = await repository.updateProduct(params.product);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class DeleteProductUsecase implements UsecaseWithParms<void, DeleteProductParams> {
  final ProductRepository repository;

  DeleteProductUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteProductParams params) async {
    try {
      await repository.deleteProduct(params.productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

// Parameters
class GetProductsParams {
  final String? category;
  final bool? isActive;

  GetProductsParams({
    this.category,
    this.isActive,
  });
}

class AddProductParams {
  final ProductEntity product;

  AddProductParams({required this.product});
}

class UpdateProductParams {
  final ProductEntity product;

  UpdateProductParams({required this.product});
}

class DeleteProductParams {
  final String productId;

  DeleteProductParams({required this.productId});
}