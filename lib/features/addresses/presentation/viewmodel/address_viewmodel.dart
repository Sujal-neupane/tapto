import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/addresses/data/datasource/remote/address_remote_datasource.dart';
import 'package:tapto/features/addresses/data/repository/address_repository_impl.dart';
import 'package:tapto/features/addresses/domain/entities/address_entity.dart';
import 'package:tapto/features/addresses/domain/repository/address_repository.dart';
import 'package:tapto/features/addresses/domain/usecases/address_usecases.dart';

final addressRemoteDataSourceProvider = Provider<AddressRemoteDataSource>((ref) {
  return AddressRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepositoryImpl(
    remoteDataSource: ref.watch(addressRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getUserAddressesProvider = Provider<GetUserAddresses>((ref) {
  return GetUserAddresses(ref.watch(addressRepositoryProvider));
});

final getAddressByIdProvider = Provider<GetAddressById>((ref) {
  return GetAddressById(ref.watch(addressRepositoryProvider));
});

final createAddressProvider = Provider<CreateAddress>((ref) {
  return CreateAddress(ref.watch(addressRepositoryProvider));
});

final updateAddressProvider = Provider<UpdateAddress>((ref) {
  return UpdateAddress(ref.watch(addressRepositoryProvider));
});

final deleteAddressProvider = Provider<DeleteAddress>((ref) {
  return DeleteAddress(ref.watch(addressRepositoryProvider));
});

final setDefaultAddressProvider = Provider<SetDefaultAddress>((ref) {
  return SetDefaultAddress(ref.watch(addressRepositoryProvider));
});

class AddressState {
  final List<AddressEntity> addresses;
  final bool isLoading;
  final String? errorMessage;
  final AddressEntity? selectedAddress;

  const AddressState({
    required this.addresses,
    required this.isLoading,
    this.errorMessage,
    this.selectedAddress,
  });

  AddressState copyWith({
    List<AddressEntity>? addresses,
    bool? isLoading,
    String? errorMessage,
    AddressEntity? selectedAddress,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }

  factory AddressState.initial() {
    return const AddressState(
      addresses: [],
      isLoading: false,
    );
  }
}

class AddressViewModel extends Notifier<AddressState> {
  late final GetUserAddresses _getUserAddresses;
  late final CreateAddress _createAddress;
  late final UpdateAddress _updateAddress;
  late final DeleteAddress _deleteAddress;
  late final SetDefaultAddress _setDefaultAddress;

  @override
  AddressState build() {
    _getUserAddresses = ref.watch(getUserAddressesProvider);
    _createAddress = ref.watch(createAddressProvider);
    _updateAddress = ref.watch(updateAddressProvider);
    _deleteAddress = ref.watch(deleteAddressProvider);
    _setDefaultAddress = ref.watch(setDefaultAddressProvider);
    
    return AddressState.initial();
  }

  Future<void> loadUserAddresses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getUserAddresses(const NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (addresses) {
        final defaultAddress = addresses.where((addr) => addr.isDefault).firstOrNull;
        state = state.copyWith(
          addresses: addresses,
          isLoading: false,
          selectedAddress: defaultAddress,
        );
      },
    );
  }

  Future<void> createAddress({
    required String fullName,
    required String phone,
    required String street,
    required String city,
    String? addressState,
    required String zipCode,
    required String country,
    bool? isDefault,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final params = CreateAddressParams(
      fullName: fullName,
      phone: phone,
      street: street,
      city: city,
      state: addressState,
      zipCode: zipCode,
      country: country,
      isDefault: isDefault,
    );

    final result = await _createAddress(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (address) {
        final updatedAddresses = [...state.addresses, address];
        state = state.copyWith(
          addresses: updatedAddresses,
          isLoading: false,
          selectedAddress: address.isDefault ? address : state.selectedAddress,
        );
      },
    );
  }

  Future<void> updateAddress({
    required String addressId,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? addressState,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final params = UpdateAddressParams(
      addressId: addressId,
      fullName: fullName,
      phone: phone,
      street: street,
      city: city,
      state: addressState,
      zipCode: zipCode,
      country: country,
      isDefault: isDefault,
    );

    final result = await _updateAddress(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (updatedAddress) {
        final updatedAddresses = state.addresses.map((addr) {
          return addr.id == addressId ? updatedAddress : addr;
        }).toList();

        state = state.copyWith(
          addresses: updatedAddresses,
          isLoading: false,
          selectedAddress: updatedAddress.isDefault ? updatedAddress : state.selectedAddress,
        );
      },
    );
  }

  Future<void> deleteAddress(String addressId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _deleteAddress(addressId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (success) {
        final updatedAddresses = state.addresses.where((addr) => addr.id != addressId).toList();
        final wasSelected = state.selectedAddress?.id == addressId;

        state = state.copyWith(
          addresses: updatedAddresses,
          isLoading: false,
          selectedAddress: wasSelected ? (updatedAddresses.isNotEmpty ? updatedAddresses.first : null) : state.selectedAddress,
        );
      },
    );
  }

  Future<void> setDefaultAddress(String addressId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _setDefaultAddress(addressId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (defaultAddress) {
        final updatedAddresses = state.addresses.map((addr) {
          return addr.id == addressId ? defaultAddress : addr.copyWith(isDefault: false);
        }).toList();

        state = state.copyWith(
          addresses: updatedAddresses,
          isLoading: false,
          selectedAddress: defaultAddress,
        );
      },
    );
  }

  void selectAddress(AddressEntity address) {
    state = state.copyWith(selectedAddress: address);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final addressViewModelProvider = NotifierProvider<AddressViewModel, AddressState>(() {
  return AddressViewModel();
});