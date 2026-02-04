import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/local/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.read(authLocalDataSourceProvider),
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

/// Implementation of auth repository
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<User> login(String email, String password) async {
    try {
      // Try remote login first - API call will fail naturally if no network
      try {
        final authApiModel = await remoteDataSource.login(email, password);

        // Convert to UserModel and save locally for caching
        final userModel = UserModel(
          id:
              authApiModel.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: authApiModel.fullName,
          email: authApiModel.email,
          password: password,
          preference: authApiModel.preference,
        );

        // Save user to local database for offline access
        await localDataSource.saveUser(userModel);

        return authApiModel.toEntity();
      } catch (e) {
        // If remote fails, check if we're offline and have local data
        final isConnected = await networkInfo.isConnected;
        if (!isConnected) {
          final userModel = await localDataSource.login(email, password);
          if (userModel != null) {
            return userModel.toEntity();
          }
        }
        rethrow;
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? preference,
  }) async {
    try {
      // Register with remote server - API call will fail naturally if no network
      final authApiModel = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        preference: preference,
      );

      // Convert to UserModel and save locally for caching
      final userModel = UserModel(
        id: authApiModel.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: authApiModel.fullName,
        email: authApiModel.email,
        password: password,
        preference: authApiModel.preference,
      );

      await localDataSource.saveUser(userModel);

      return authApiModel.toEntity();
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCurrentUser();
      return userModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await localDataSource.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localDataSource.logout();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await remoteDataSource.requestPasswordReset(email);
    } catch (e) {
      throw Exception('Request password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      await remoteDataSource.resetPassword(email, otp, newPassword);
    } catch (e) {
      throw Exception('Reset password failed: ${e.toString()}');
    }
  }
}
