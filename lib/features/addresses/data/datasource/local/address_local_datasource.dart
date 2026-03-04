import 'package:tapto/core/error/exceptions.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:tapto/features/addresses/data/models/address_model.dart';

abstract class AddressLocalDataSource {
  Future<List<AddressModel>> getCachedAddresses();
  Future<void> cacheAddresses(List<AddressModel> addresses);
  Future<AddressModel?> getCachedAddress(String addressId);
  Future<void> cacheAddress(AddressModel address);
  Future<void> clearCache();
  bool isCacheValid();
}

class AddressLocalDataSourceImpl implements AddressLocalDataSource {
  final HiveService hiveService;

  AddressLocalDataSourceImpl({required this.hiveService});

  /// Helper to deeply cast Map<dynamic, dynamic> to Map<String, dynamic>
  Map<String, dynamic> _deepCastMap(dynamic item) {
    if (item == null) return {};
    if (item is Map<String, dynamic>) return item;
    if (item is Map) {
      return item.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _deepCastMap(value));
        } else if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((e) => e is Map ? _deepCastMap(e) : e).toList(),
          );
        }
        return MapEntry(key.toString(), value);
      });
    }
    return {};
  }

  @override
  Future<List<AddressModel>> getCachedAddresses() async {
    try {
      final cachedData = hiveService.getAddresses();
      if (cachedData == null || cachedData.isEmpty) {
        throw CacheException(message: 'No cached addresses found');
      }
      return cachedData
          .map((json) => AddressModel.fromJson(_deepCastMap(json)))
          .toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      // If there's a type error, clear the corrupt cache
      try {
        await hiveService.clearAddresses();
      } catch (_) {}
      throw CacheException(message: 'Failed to get cached addresses: $e');
    }
  }

  @override
  Future<void> cacheAddresses(List<AddressModel> addresses) async {
    try {
      final jsonList = addresses.map((address) => address.toJson()).toList();
      await hiveService.saveAddresses(jsonList);
    } catch (e) {
      throw CacheException(message: 'Failed to cache addresses: $e');
    }
  }

  @override
  Future<AddressModel?> getCachedAddress(String addressId) async {
    try {
      final cachedData = hiveService.getAddress(addressId);
      if (cachedData == null) return null;
      return AddressModel.fromJson(_deepCastMap(cachedData));
    } catch (e) {
      throw CacheException(message: 'Failed to get cached address: $e');
    }
  }

  @override
  Future<void> cacheAddress(AddressModel address) async {
    try {
      await hiveService.saveAddress(address.id, address.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to cache address: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await hiveService.clearAddresses();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  bool isCacheValid() {
    return hiveService.isAddressCacheValid(maxAgeInMinutes: 30);
  }
}
