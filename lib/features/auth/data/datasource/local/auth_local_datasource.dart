import '../../models/user_model.dart';
import '../../../../../core/services/storage/user_session_service.dart';

/// Local datasource for authentication
abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? preference,
  });
  Future<UserModel?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final UserSessionService sessionService;

  AuthLocalDataSourceImpl({required this.sessionService});

  @override
  Future<UserModel> login(String email, String password) async {
    final user = await sessionService.loginUser(
      email: email,
      password: password,
    );

    return UserModel.fromEntity(user, password);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? preference,
  }) async {
    final user = await sessionService.registerUser(
      name: name,
      email: email,
      password: password,
      preference: preference,
    );

    return UserModel.fromEntity(user, password);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = await sessionService.getCurrentUser();
    if (user == null) return null;

    return UserModel.fromEntity(user, ''); // Password not needed for session
  }

  @override
  Future<bool> isLoggedIn() async {
    return await sessionService.isLoggedIn();
  }

  @override
  Future<void> logout() async {
    await sessionService.logout();
  }
}
