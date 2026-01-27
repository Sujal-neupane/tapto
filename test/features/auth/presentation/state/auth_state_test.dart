import 'package:flutter_test/flutter_test.dart';
import 'package:tapto/features/auth/presentation/state/auth_state.dart';

void main() {
  test('AuthState copyWith updates fields', () {
    final state = AuthState(status: AuthStatus.loading, errorMessage: null);
    final newState = state.copyWith(status: AuthStatus.authenticated, errorMessage: null);
    expect(newState.status, AuthStatus.authenticated);
    expect(newState.errorMessage, null);
  });
}