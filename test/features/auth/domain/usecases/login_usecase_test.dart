import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tapto/features/auth/domain/entities/user.dart';
import 'package:tapto/features/auth/domain/usecases/auth_params.dart';
import 'package:tapto/features/auth/domain/usecases/login_usecase.dart';

import '../../../../mocks/mock_auth_repository.dart';

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(mockRepository);
  });

  const tUser = User(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    country: 'Nepal',
  );

  // Test 1: Login succeeds with valid credentials
  test('should return User when login is successful', () async {
    when(mockRepository.login('test@example.com', 'password123'))
        .thenAnswer((_) async => tUser);

    final result = await usecase(
      const LoginParams(email: 'test@example.com', password: 'password123'),
    );

    expect(result, const Right(tUser));
    verify(mockRepository.login('test@example.com', 'password123'));
    verifyNoMoreInteractions(mockRepository);
  });

  // Test 2: Login fails with invalid email
  test('should return Failure when email is invalid', () async {
    final result = await usecase(
      const LoginParams(email: 'invalid', password: 'password123'),
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, 'Invalid email address'),
      (_) => fail('Should be Left'),
    );
    verifyZeroInteractions(mockRepository);
  });

  // Test 3: Login fails with short password
  test('should return Failure when password is too short', () async {
    final result = await usecase(
      const LoginParams(email: 'test@example.com', password: '123'),
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) =>
          expect(failure.message, 'Password must be at least 6 characters'),
      (_) => fail('Should be Left'),
    );
    verifyZeroInteractions(mockRepository);
  });

  // Test 4: Login fails with empty email
  test('should return Failure when email is empty', () async {
    final result = await usecase(
      const LoginParams(email: '', password: 'password123'),
    );

    expect(result.isLeft(), true);
    verifyZeroInteractions(mockRepository);
  });
}
