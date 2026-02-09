import 'package:mockito/mockito.dart';
import 'package:tapto/features/auth/domain/entities/user.dart';
import 'package:tapto/features/auth/domain/repositories/auth_repository.dart';

// Manual mock since build_runner has issues with other files
class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<User> login(String? email, String? password) =>
      super.noSuchMethod(
        Invocation.method(#login, [email, password]),
        returnValue: Future.value(
          const User(id: '', name: '', email: ''),
        ),
        returnValueForMissingStub: Future.value(
          const User(id: '', name: '', email: ''),
        ),
      );

  @override
  Future<User> register({
    required String? name,
    required String? email,
    required String? password,
    String? preference,
    String? country,
    String? phoneNumber,
  }) =>
      super.noSuchMethod(
        Invocation.method(#register, [], {
          #name: name,
          #email: email,
          #password: password,
          #preference: preference,
          #country: country,
          #phoneNumber: phoneNumber,
        }),
        returnValue: Future.value(
          const User(id: '', name: '', email: ''),
        ),
        returnValueForMissingStub: Future.value(
          const User(id: '', name: '', email: ''),
        ),
      );

  @override
  Future<User?> getCurrentUser() =>
      super.noSuchMethod(
        Invocation.method(#getCurrentUser, []),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      );

  @override
  Future<bool> isLoggedIn() =>
      super.noSuchMethod(
        Invocation.method(#isLoggedIn, []),
        returnValue: Future.value(false),
        returnValueForMissingStub: Future.value(false),
      );

  @override
  Future<void> logout() =>
      super.noSuchMethod(
        Invocation.method(#logout, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> requestPasswordReset(String? email) =>
      super.noSuchMethod(
        Invocation.method(#requestPasswordReset, [email]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> resetPassword(
    String? email,
    String? otp,
    String? newPassword,
  ) =>
      super.noSuchMethod(
        Invocation.method(#resetPassword, [email, otp, newPassword]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}
