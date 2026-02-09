import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tapto/features/auth/domain/usecases/reset_password_usecase.dart';

import '../../../../mocks/mock_auth_repository.dart';

void main() {
  late ResetPasswordUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = ResetPasswordUsecase(mockRepository);
  });

  // Test 9: Reset password fails with invalid OTP
  test('should return Failure when OTP is not 6 characters', () async {
    final result = await usecase(
      ResetPasswordParams(
        email: 'test@example.com',
        otp: '123',
        newPassword: 'newPass123',
      ),
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, 'Invalid OTP code'),
      (_) => fail('Should be Left'),
    );
    verifyZeroInteractions(mockRepository);
  });

  // Test 10: Reset password succeeds with valid params
  test('should return Right(null) when reset password is successful', () async {
    when(
      mockRepository.resetPassword(
        'test@example.com',
        '123456',
        'newPass123',
      ),
    ).thenAnswer((_) async {});

    final result = await usecase(
      ResetPasswordParams(
        email: 'test@example.com',
        otp: '123456',
        newPassword: 'newPass123',
      ),
    );

    expect(result, const Right(null));
    verify(
      mockRepository.resetPassword(
        'test@example.com',
        '123456',
        'newPass123',
      ),
    );
  });
}
