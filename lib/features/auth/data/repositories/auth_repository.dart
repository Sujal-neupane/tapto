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
      // Check if network is available
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // Try remote login first
        try {
          final authApiModel = await remoteDataSource.login(email, password);

          // Convert to UserModel and save locally
          final userModel = UserModel(
            id:
                authApiModel.id ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: authApiModel.fullName,
            email: authApiModel.email,
            password: password, // Store hashed in production
            preference: authApiModel.preference,
          );

          // Save user to local database
          await localDataSource.saveUser(userModel);

          return authApiModel.toEntity();
        } catch (e) {
          // If remote login fails, try local login as fallback
          final userModel = await localDataSource.login(email, password);
          if (userModel == null) {
            throw Exception('Login failed: ${e.toString()}');
          }
          return userModel.toEntity();
        }
      } else {
        // No network, use local login
        final userModel = await localDataSource.login(email, password);
        if (userModel == null) {
          throw Exception('No internet connection and user not found locally');
        }
        return userModel.toEntity();
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
      // Check if network is available
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // Try to register with remote server
        try {
          final authApiModel = await remoteDataSource.register(
            email: email,
            password: password,
            name: name,
            preference: preference,
          );

          // Convert to UserModel and save locally
          final userModel = UserModel(
            id:
                authApiModel.id ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: authApiModel.fullName,
            email: authApiModel.email,
            password: password, // Store hashed in production
            preference: authApiModel.preference,
          );

          await localDataSource.saveUser(userModel);

          return authApiModel.toEntity();
        } catch (e) {
          // If remote registration fails (backend not running), fall back to local registration
          try {
            final userModel = await localDataSource.register(
              name: name,
              email: email,
              password: password,
              preference: preference,
            );
            return userModel.toEntity();
          } catch (localError) {
            throw Exception('Registration failed: ${localError.toString()}');
          }
        }
      } else {
        // No network, register locally only
        final userModel = await localDataSource.register(
          name: name,
          email: email,
          password: password,
          preference: preference,
        );
        return userModel.toEntity();
      }
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
}
