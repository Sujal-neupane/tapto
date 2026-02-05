import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapto/core/api/api_client.dart';
import 'package:tapto/core/api/api_endpoint.dart';
import 'package:tapto/core/services/storage/storage_provider.dart';
import 'package:tapto/core/services/storage/token_storage_service.dart';
import 'package:tapto/features/auth/data/models/auth_api_model.dart';

/// Provider for AuthRemoteDatasource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(apiClient: ref.read(apiClientProvider), tokenService: ref.read(tokenStorageServiceProvider));
});

/// Abstract interface for remote authentication data source
abstract class AuthRemoteDataSource {
  Future<AuthApiModel> register({
    required String email,
    required String password,
    required String name,
    String? preference,
    String? phoneNumber,
    String? country,
  });

  Future<AuthApiModel> login(String email, String password);
  Future<AuthApiModel> getCurrentUser();
  Future<AuthApiModel> getUserById(String authId);
  Future<AuthApiModel> updateUser(AuthApiModel user);
  Future<AuthApiModel> uploadProfilePicture(File image);
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);
}

/// Implementation of remote authentication data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final TokenStorageService _tokenService;

  AuthRemoteDataSourceImpl({required ApiClient apiClient, required TokenStorageService tokenService})
      : _apiClient = apiClient,
        _tokenService = tokenService;

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

            // Save token to storage for later use
            final token = response.data['token'] as String;
            await _tokenService.saveToken(token);
            await _tokenService.saveUserId(loggedInUser.id!);
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
  Future<AuthApiModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.currentUser);

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final data = response.data['data'] as Map<String, dynamic>;
          return AuthApiModel.fromJson(data);
        }
      }
      throw Exception('Failed to get current user');
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<AuthApiModel> register({
    required String email,
    required String password,
    required String name,
    String? preference,
    String? phoneNumber,
    String? country,
  }) async {
    try {
      final authModel = AuthApiModel(
        fullName: name,
        email: email,
        password: password,
        preference: preference,
        phoneNumber: phoneNumber ?? '',
        country: country ?? 'United States', // Use passed country or default
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

            // Save token to storage for later use
            final prefs = await SharedPreferences.getInstance();
            final tokenService = TokenStorageService(prefs);
            await tokenService.saveToken(response.data['token']);
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

  @override
  Future<AuthApiModel> uploadProfilePicture(File image) async {
    try {
      String fileName = image.path.split('/').last;
      AuthApiModel formData = AuthApiModel.fromJson({
        "profileImage": await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.uploadImage, // Ensure this exists in your ApiEndpoints
        data: formData,
      );

      if (response.statusCode == 200) {
        // Return the image name returned by backend (e.g., "123-profile.jpg")
        return response.data['data'];
      }
      throw Exception('Upload failed');
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.requestPasswordReset,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return;
      }
      throw Exception('Failed to request password reset');
    } catch (e) {
      throw Exception('Failed to request password reset: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return;
      }
      throw Exception('Failed to reset password');
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }
}