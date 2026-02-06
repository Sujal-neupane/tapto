import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/addresses/domain/entities/address_entity.dart';
import 'package:tapto/features/addresses/domain/repository/address_repository.dart';

class GetUserAddresses implements UseCase<List<AddressEntity>, NoParams> {
  final AddressRepository repository;

  GetUserAddresses(this.repository);

  @override
  Future<Either<Failure, List<AddressEntity>>> call(NoParams params) {
    return repository.getUserAddresses();
  }
}

class GetAddressById implements UseCase<AddressEntity, String> {
  final AddressRepository repository;

  GetAddressById(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(String addressId) {
    return repository.getAddressById(addressId);
  }
}

class CreateAddress implements UseCase<AddressEntity, CreateAddressParams> {
  final AddressRepository repository;

  CreateAddress(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(CreateAddressParams params) {
    return repository.createAddress(
      fullName: params.fullName,
      phone: params.phone,
      street: params.street,
      city: params.city,
      state: params.state,
      zipCode: params.zipCode,
      country: params.country,
      isDefault: params.isDefault,
    );
  }
}

class UpdateAddress implements UseCase<AddressEntity, UpdateAddressParams> {
  final AddressRepository repository;

  UpdateAddress(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(UpdateAddressParams params) {
    return repository.updateAddress(
      addressId: params.addressId,
      fullName: params.fullName,
      phone: params.phone,
      street: params.street,
      city: params.city,
      state: params.state,
      zipCode: params.zipCode,
      country: params.country,
      isDefault: params.isDefault,
    );
  }
}

class DeleteAddress implements UseCase<bool, String> {
  final AddressRepository repository;

  DeleteAddress(this.repository);

  @override
  Future<Either<Failure, bool>> call(String addressId) {
    return repository.deleteAddress(addressId);
  }
}

class SetDefaultAddress implements UseCase<AddressEntity, String> {
  final AddressRepository repository;

  SetDefaultAddress(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(String addressId) {
    return repository.setDefaultAddress(addressId);
  }
}

// Parameter classes
class CreateAddressParams {
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String? state;
  final String zipCode;
  final String country;
  final bool? isDefault;

  const CreateAddressParams({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    this.state,
    required this.zipCode,
    required this.country,
    this.isDefault,
  });
}

class UpdateAddressParams {
  final String addressId;
  final String? fullName;
  final String? phone;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final bool? isDefault;

  const UpdateAddressParams({
    required this.addressId,
    this.fullName,
    this.phone,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.isDefault,
  });
}