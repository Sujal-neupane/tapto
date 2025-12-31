import '../../domain/entities/user.dart';

/// Abstract repository for authentication
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? preference,
  });
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> logout();
}
