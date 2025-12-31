import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tapto/features/auth/domain/usecases/login_usecase.dart';
import 'package:tapto/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tapto/features/auth/domain/usecases/register_usecase.dart';
import 'package:tapto/features/auth/domain/usecases/auth_params.dart';
import 'package:tapto/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? preference,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterParams(
        name: name,
        email: email,
        password: password,
        preference: preference,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.registered, user: user),
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
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: user,
      ),
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
      (_) => state = state.copyWith(status: AuthStatus.loggedOut, user: null),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void resetAuthState() {
    state = const AuthState();
  }
}

/// ==================== CONVENIENCE PROVIDERS ====================

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.status == AuthStatus.authenticated;
});

/// Provider to get current user
final currentUserProvider = Provider((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.user;
});

/// Provider to get auth error message
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.errorMessage;
});

/// Provider to check if loading
final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.status == AuthStatus.loading;
});
