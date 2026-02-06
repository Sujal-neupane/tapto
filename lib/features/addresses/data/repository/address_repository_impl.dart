import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/exceptions.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/features/addresses/data/datasource/remote/address_remote_datasource.dart';
import 'package:tapto/features/addresses/domain/entities/address_entity.dart';
import 'package:tapto/features/addresses/domain/repository/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AddressRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses() async {
    if (await networkInfo.isConnected) {
      try {
        final addresses = await remoteDataSource.getUserAddresses();
        return Right(addresses.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> getAddressById(String addressId) async {
    if (await networkInfo.isConnected) {
      try {
        final address = await remoteDataSource.getAddressById(addressId);
        return Right(address.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> createAddress({
    required String fullName,
    required String phone,
    required String street,
    required String city,
    String? state,
    required String zipCode,
    required String country,
    bool? isDefault,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final addressData = {
          'fullName': fullName,
          'phone': phone,
          'street': street,
          'city': city,
          'zipCode': zipCode,
          'country': country,
          if (state != null) 'state': state,
          if (isDefault != null) 'isDefault': isDefault,
        };

        final address = await remoteDataSource.createAddress(addressData);
        return Right(address.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress({
    required String addressId,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final addressData = {
          if (fullName != null) 'fullName': fullName,
          if (phone != null) 'phone': phone,
          if (street != null) 'street': street,
          if (city != null) 'city': city,
          if (state != null) 'state': state,
          if (zipCode != null) 'zipCode': zipCode,
          if (country != null) 'country': country,
          if (isDefault != null) 'isDefault': isDefault,
        };

        final address = await remoteDataSource.updateAddress(addressId, addressData);
        return Right(address.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAddress(String addressId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteAddress(addressId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> setDefaultAddress(String addressId) async {
    if (await networkInfo.isConnected) {
      try {
        final address = await remoteDataSource.setDefaultAddress(addressId);
        return Right(address.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}