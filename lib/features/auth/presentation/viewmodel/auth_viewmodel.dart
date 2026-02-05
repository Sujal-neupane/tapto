import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/api/api_endpoint.dart';
import 'package:tapto/core/services/hive/hive_services.dart';
import 'package:tapto/core/services/storage/user_session_service.dart';
import 'package:tapto/core/services/storage/token_storage_service.dart';
import 'package:tapto/core/services/storage/storage_provider.dart';
import 'package:tapto/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tapto/features/auth/domain/usecases/login_usecase.dart';
import 'package:tapto/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tapto/features/auth/domain/usecases/register_usecase.dart';
import 'package:tapto/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:tapto/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:tapto/features/auth/domain/usecases/auth_params.dart';
import 'package:tapto/features/auth/presentation/state/auth_state.dart';
import 'package:tapto/features/auth/data/models/user_model.dart'; // <-- Import UserModel

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final RequestPasswordResetUsecase _requestPasswordResetUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _requestPasswordResetUsecase = ref.read(requestPasswordResetUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? preference,
    required String country,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterParams(
        name: name,
        email: email,
        password: password,
        preference: preference,
        country: country,
        phoneNumber: phoneNumber,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) async {
        final hiveService = ref.read(hiveServiceProvider);
        // Save as UserModel, using the password provided at registration
        await hiveService.saveUser(
          UserModel.fromEntity(user, password),
        );
        // Save selected country for currency determination
        await hiveService.put('user_country', country);

        // Set current user in session service
        final userSessionService = UserSessionService();
        await userSessionService.setCurrentUser(user.id);

        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) async {
        final hiveService = ref.read(hiveServiceProvider);
        // Save as UserModel, using the password provided at login
        await hiveService.saveUser(
          UserModel.fromEntity(user, password),
        );
        
        // Set current user in session service
        final userSessionService = UserSessionService();
        await userSessionService.setCurrentUser(user.id);

        // Set authenticated state immediately with login user data
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        
        // Fetch complete user data including preference from backend in background
        // This will update the state with more complete data if available
        try {
          await getCurrentUser();
        } catch (e) {
          // If getCurrentUser fails, we already have the user from login
          // so we can continue with the authenticated state
        }
      },
    );
  }

  Future<void> getCurrentUser() async {
  state = state.copyWith(status: AuthStatus.loading);

  final tokenStorage = ref.read(tokenStorageServiceProvider);
  final String? token = tokenStorage.getToken();

  if (token == null || token.isEmpty) {
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
    return;
  }

  // Always fetch from backend for freshness
  final result = await _getCurrentUserUsecase();

  result.fold(
    (failure) => state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: failure.message,
    ),
    (user) async {
      if (user != null) {
        final hiveService = ref.read(hiveServiceProvider);
        await hiveService.saveUser(UserModel.fromEntity(user, ''));
        // Save country for currency determination
        if (user.country != null && user.country!.isNotEmpty) {
          await hiveService.put('user_country', user.country);
        }

        // Ensure current user is set in session service
        final userSessionService = UserSessionService();
        await userSessionService.setCurrentUser(user.id);
      }
      state = state.copyWith(
        status: user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: user,
      );
    },
  );
}

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) async {
        final tokenStorage = ref.read(tokenStorageServiceProvider);
        final userId = tokenStorage.getUserId();
        if (userId != null) {
          final hiveService = ref.read(hiveServiceProvider);
          await hiveService.deleteUser(userId);
        }
        state = state.copyWith(status: AuthStatus.loggedOut, user: null);
      },
    );
  }

  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _requestPasswordResetUsecase(email);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.initial,
        errorMessage: null,
      ),
    );
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _resetPasswordUsecase(
      ResetPasswordParams(
        email: email,
        otp: otp,
        newPassword: newPassword,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.authenticated, // Consider this as successful reset
        errorMessage: null,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void resetAuthState() {
    state = const AuthState();
  }

  Future<void> uploadProfilePicture(File image) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final dio = Dio();
      final String url = "${ApiEndpoints.baseUrl}${ApiEndpoints.uploadImage}";

      final tokenStorage = ref.read(tokenStorageServiceProvider);
      final String? token = tokenStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      debugPrint('Uploading profile picture to: $url');
      debugPrint('Image path: ${image.path}');
      debugPrint('Image exists: ${await image.exists()}');
      debugPrint('Image size: ${await image.length()} bytes');

      debugPrint('Creating FormData...');
      final formData = FormData();
      formData.files.add(MapEntry(
        'profilePicture',
        await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      ));
      debugPrint('FormData created with ${formData.files.length} files');

      debugPrint('Sending upload request...');
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('Upload response status: ${response.statusCode}');
      debugPrint('Upload response data: ${response.data}');

      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        final profilePicturePath = data['data']['profilePicture'];
        debugPrint('Profile picture uploaded successfully: $profilePicturePath');

        if (state.user != null) {
          final updatedUser = state.user!.copyWith(profilePicture: profilePicturePath);
          final hiveService = ref.read(hiveServiceProvider);
          await hiveService.saveUser(
            UserModel.fromEntity(updatedUser, ''),
          );
          // Refresh user from backend to ensure latest info
          await getCurrentUser();
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: updatedUser,
          );
        }
      } else {
        debugPrint('Upload failed: ${data['message']}');
        throw Exception(data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateProfile({
    required String name,
    String? phoneNumber,
    String? preference,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final dio = Dio();
      final tokenStorage = ref.read(tokenStorageServiceProvider);
      final String? token = tokenStorage.getToken();
      final String? userId = tokenStorage.getUserId();

      if (token == null || token.isEmpty || userId == null) {
        throw Exception('No auth token or user ID found');
      }

      final response = await dio.put(
        "${ApiEndpoints.baseUrl}${ApiEndpoints.userById(userId)}",
        data: {
          'fullName': name,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (preference != null) 'shoppingPreference': preference,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        // Refresh user from backend to ensure latest info
        await getCurrentUser();
      } else {
        throw Exception(data['message'] ?? 'Update failed');
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.status == AuthStatus.authenticated;
});

final currentUserProvider = Provider((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.user;
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);  
  return user?.isAdmin ?? false;
});

final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.errorMessage;
});

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.status == AuthStatus.loading;
});