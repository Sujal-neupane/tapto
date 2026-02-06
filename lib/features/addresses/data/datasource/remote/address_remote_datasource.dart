import 'package:dio/dio.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/api/api_endpoint.dart';
import 'package:tapto/core/error/exceptions.dart';
import 'package:tapto/features/addresses/data/models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getUserAddresses();
  Future<AddressModel> getAddressById(String addressId);
  Future<AddressModel> createAddress(Map<String, dynamic> addressData);
  Future<AddressModel> updateAddress(String addressId, Map<String, dynamic> addressData);
  Future<bool> deleteAddress(String addressId);
  Future<AddressModel> setDefaultAddress(String addressId);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiClient apiClient;

  AddressRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AddressModel>> getUserAddresses() async {
    try {
      final response = await apiClient.get(ApiEndpoints.addresses);
      final data = response.data;

      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to fetch addresses',
          statusCode: response.statusCode,
        );
      }

      final addressesJson = data['data'] as List<dynamic>;
      return addressesJson
          .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AddressModel> getAddressById(String addressId) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.addresses}/$addressId');
      final data = response.data;

      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to fetch address',
          statusCode: response.statusCode,
        );
      }

      return AddressModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AddressModel> createAddress(Map<String, dynamic> addressData) async {
    try {
      final response = await apiClient.post(ApiEndpoints.addresses, data: addressData);
      final data = response.data;

      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to create address',
          statusCode: response.statusCode,
        );
      }

      return AddressModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AddressModel> updateAddress(String addressId, Map<String, dynamic> addressData) async {
    try {
      final response = await apiClient.put('${ApiEndpoints.addresses}/$addressId', data: addressData);
      final data = response.data;

      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to update address',
          statusCode: response.statusCode,
        );
      }

      return AddressModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<bool> deleteAddress(String addressId) async {
    try {
      final response = await apiClient.delete('${ApiEndpoints.addresses}/$addressId');
      final data = response.data;

      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to delete address',
          statusCode: response.statusCode,
        );
      }

      return true;
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AddressModel> setDefaultAddress(String addressId) async {
    try {
      final response = await apiClient.patch('${ApiEndpoints.addresses}/$addressId/default');
      final data = response.data;

      if (data['success'] == false) {
        throw ServerException(
          message: data['message'] ?? 'Failed to set default address',
          statusCode: response.statusCode,
        );
      }

      return AddressModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: _getDioErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return e.response?.data['message'] ?? 'Server error';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'An error occurred';
    }
  }
}