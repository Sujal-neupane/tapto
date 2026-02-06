import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/features/addresses/domain/entities/address_entity.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses();
  Future<Either<Failure, AddressEntity>> getAddressById(String addressId);
  Future<Either<Failure, AddressEntity>> createAddress({
    required String fullName,
    required String phone,
    required String street,
    required String city,
    String? state,
    required String zipCode,
    required String country,
    bool? isDefault,
  });
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
  });
  Future<Either<Failure, bool>> deleteAddress(String addressId);
  Future<Either<Failure, AddressEntity>> setDefaultAddress(String addressId);
}