import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/local/auth_local_datasource.dart';

/// Implementation of auth repository
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<User> login(String email, String password) async {
    try {
      final userModel = await localDataSource.login(email, password);
      return userModel?.toEntity() ?? (throw Exception('User model is null'));
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
      final userModel = await localDataSource.register(
        name: name,
        email: email,
        password: password,
        preference: preference,
      );
      return userModel.toEntity();
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
    await localDataSource.logout();
  }
}
