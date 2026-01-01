import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tapto/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:tapto/features/auth/domain/usecases/auth_params.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../domain/entities/user.dart';

/// User session service provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService();
});

/// Auth local datasource provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final sessionService = ref.watch(userSessionServiceProvider);
  return AuthLocalDataSourceImpl(sessionService: sessionService);
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(localDataSource: localDataSource);
});

/// Login use case provider
final loginUseCaseProvider = Provider<LoginUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUsecase(repository);
});

/// Register use case provider
final registerUseCaseProvider = Provider<RegisterUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUsecase(repository);
});

/// Logout use case provider
final logoutUseCaseProvider = Provider<LogoutUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUsecase(repository);
});

/// Get current user use case provider
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: repository);
});

/// Auth state provider
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth notifier provider
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUsecase loginUseCase;
  final RegisterUsecase registerUseCase;
  final LogoutUsecase logoutUseCase;
  final GetCurrentUserUsecase getCurrentUserUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthState());

  /// Check current auth state
  Future<void> checkAuthStatus() async {
    try {
      final result = await getCurrentUserUseCase();
      result.fold(
        (failure) => state = state.copyWith(isAuthenticated: false),
        (user) => state = state.copyWith(user: user, isAuthenticated: true),
      );
    } catch (e) {
      state = state.copyWith(isAuthenticated: false);
    }
  }

  /// Login
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await loginUseCase(
        LoginParams(email: email, password: password),
      );
      result.fold(
        (failure) =>
            state = state.copyWith(isLoading: false, error: failure.message),
        (user) => state = AuthState(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? preference,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await registerUseCase(
        RegisterParams(
          name: name,
          email: email,
          password: password,
          preference: preference,
        ),
      );
      result.fold(
        (failure) =>
            state = state.copyWith(isLoading: false, error: failure.message),
        (user) => state = AuthState(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    await logoutUseCase();
    state = AuthState();
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
  );
});
