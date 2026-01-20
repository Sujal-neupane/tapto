import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/api/api_endpoint.dart';
import 'package:tapto/features/auth/data/models/auth_api_model.dart';

/// Provider for AuthRemoteDatasource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider));
});

/// Abstract interface for remote authentication data source
abstract class AuthRemoteDataSource {
  Future<AuthApiModel> register({
    required String email,
    required String password,
    required String name,
    String? preference,
    String? phoneNumber,
  });

  Future<AuthApiModel> login(String email, String password);
  Future<AuthApiModel> getUserById(String authId);
  Future<AuthApiModel> updateUser(AuthApiModel user);
}

/// Implementation of remote authentication data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<AuthApiModel> getUserById(String authId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userById(authId));

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final data = response.data['data'] as Map<String, dynamic>;
          return AuthApiModel.fromJson(data);
        }
      }
      throw Exception('Failed to get user');
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<AuthApiModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.userLogin,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final data = response.data['data'] as Map<String, dynamic>;
          final loggedInUser = AuthApiModel.fromJson(data);

          // Set auth token if available - token is at root level in response
          if (response.data['token'] != null) {
            _apiClient.setAuthToken(response.data['token']);
          }

          return loggedInUser;
        }
      }
      throw Exception(response.data['message'] ?? 'Login failed');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthApiModel> register({
    required String email,
    required String password,
    required String name,
    String? preference,
    String? phoneNumber,
  }) async {
    try {
      final authModel = AuthApiModel(
        fullName: name,
        email: email,
        password: password,
        preference: preference,
        phoneNumber: phoneNumber ?? '',
      );

      final response = await _apiClient.post(
        ApiEndpoints.userRegister,
        data: authModel.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data['success'] == true) {
          final data = response.data['data'] as Map<String, dynamic>;
          final registeredUser = AuthApiModel.fromJson(data);

          // Set auth token if available - token is at root level in response
          if (response.data['token'] != null) {
            _apiClient.setAuthToken(response.data['token']);
          }

          return registeredUser;
        }
      }
      throw Exception(response.data['message'] ?? 'Registration failed');
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthApiModel> updateUser(AuthApiModel user) async {
    try {
      if (user.id == null) {
        throw Exception('User ID is required for update');
      }

      final response = await _apiClient.put(
        ApiEndpoints.userById(user.id!),
        data: user.toJson(),
      );

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final data = response.data['data'] as Map<String, dynamic>;
          return AuthApiModel.fromJson(data);
        }
      }
      throw Exception(response.data['message'] ?? 'Update failed');
    } catch (e) {
      throw Exception('Update failed: ${e.toString()}');
    }
  }
}
