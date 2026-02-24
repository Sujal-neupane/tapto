import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/exceptions.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/features/addresses/data/datasource/local/address_local_datasource.dart';
import 'package:tapto/features/addresses/data/datasource/remote/address_remote_datasource.dart';
import 'package:tapto/features/addresses/data/models/address_model.dart';
import 'package:tapto/features/addresses/domain/entities/address_entity.dart';
import 'package:tapto/features/addresses/domain/repository/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  final AddressLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AddressRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses() async {
    final isConnected = await networkInfo.isConnected;
    print('📍 getUserAddresses - isConnected: $isConnected');
    
    if (isConnected) {
      try {
        print('📍 Fetching addresses from remote...');
        final addresses = await remoteDataSource.getUserAddresses();
        print('📍 Got ${addresses.length} addresses from remote');
        // Cache the addresses for offline access
        try {
          await localDataSource.cacheAddresses(addresses);
          print('📍 Cached ${addresses.length} addresses');
        } catch (e) {
          print('⚠️ Failed to cache addresses: $e');
        }
        return Right(addresses.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        print('❌ Server error: ${e.message}');
        // If server fails, try cache as fallback
        try {
          final cachedAddresses = await localDataSource.getCachedAddresses();
          print('📍 Using ${cachedAddresses.length} cached addresses as fallback');
          return Right(cachedAddresses.map((model) => model.toEntity()).toList());
        } catch (cacheError) {
          print('❌ Cache fallback failed: $cacheError');
          return Left(ServerFailure(message: e.message));
        }
      }
    } else {
      print('📍 Network offline, loading from cache...');
      try {
        final cachedAddresses = await localDataSource.getCachedAddresses();
        print('📍 Loaded ${cachedAddresses.length} cached addresses');
        return Right(cachedAddresses.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        print('📍 No cache found: $e - returning empty list');
        // Return empty list instead of error on first load
        return const Right([]);
      } catch (e) {
        print('❌ Cache error: $e - clearing and returning empty');
        // Clear corrupt cache and return empty list
        try {
          await localDataSource.clearCache();
        } catch (_) {}
        return const Right([]);
      }
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> getAddressById(String addressId) async {
    if (await networkInfo.isConnected) {
      try {
        final address = await remoteDataSource.getAddressById(addressId);
        await localDataSource.cacheAddress(address);
        return Right(address.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedAddress = await localDataSource.getCachedAddress(addressId);
        if (cachedAddress != null) {
          return Right(cachedAddress.toEntity());
        }
        return const Left(CacheFailure(message: 'Address not found in cache'));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
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
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final addressData = <String, dynamic>{
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
      // Cache the newly created address and update the cached list
      try {
        await localDataSource.cacheAddress(address);
        // Also update the cached addresses list
        final currentAddresses = await localDataSource.getCachedAddresses().catchError((_) => <AddressModel>[]);
        final updatedList = [...currentAddresses, address];
        await localDataSource.cacheAddresses(updatedList);
      } catch (_) {}
      return Right(address.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
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
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final addressData = <String, dynamic>{
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
      // Cache the updated address and update the cached list
      try {
        await localDataSource.cacheAddress(address);
        // Also update the cached addresses list
        final currentAddresses = await localDataSource.getCachedAddresses().catchError((_) => <AddressModel>[]);
        final updatedList = currentAddresses.map((a) => a.id == addressId ? address : a).toList();
        await localDataSource.cacheAddresses(updatedList);
      } catch (_) {}
      return Right(address.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAddress(String addressId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.deleteAddress(addressId);
      // Update cached list by removing the deleted address
      try {
        final currentAddresses = await localDataSource.getCachedAddresses().catchError((_) => <AddressModel>[]);
        final updatedList = currentAddresses.where((a) => a.id != addressId).toList();
        await localDataSource.cacheAddresses(updatedList);
      } catch (_) {}
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> setDefaultAddress(String addressId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final address = await remoteDataSource.setDefaultAddress(addressId);
      // Cache the updated address and update cached list
      try {
        await localDataSource.cacheAddress(address);
        // Update the cached addresses list - reset all default flags then set the new one
        final currentAddresses = await localDataSource.getCachedAddresses().catchError((_) => <AddressModel>[]);
        final updatedList = currentAddresses.map((a) {
          if (a.id == addressId) {
            return address;
          } else {
            // Create updated model with isDefault = false for all others
            return AddressModel.fromJson({...a.toJson(), 'isDefault': false});
          }
        }).toList();
        await localDataSource.cacheAddresses(updatedList);
      } catch (_) {}
      return Right(address.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
