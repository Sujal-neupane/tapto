import 'package:tapto/features/auth/data/models/auth_api_model.dart';
import 'package:tapto/features/auth/data/models/user_model.dart';

abstract interface class IAuthLocalDataSource {
  Future<UserModel> register(UserModel user);
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<bool> logout();
  Future<UserModel?> getUserById(String authId);
  Future<UserModel?> getUserByEmail(String email);
  Future<bool> updateUser(UserModel user);
  Future<bool> deleteUser(String authId);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getUserById(String authId);
}
