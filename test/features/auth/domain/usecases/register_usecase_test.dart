import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tapto/features/auth/domain/entities/user.dart';
import 'package:tapto/features/auth/domain/usecases/auth_params.dart';
import 'package:tapto/features/auth/domain/usecases/register_usecase.dart';

import '../../../../mocks/mock_auth_repository.dart';

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(mockRepository);
  });

  const tUser = User(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    country: 'Nepal',
  );

  // Test 5: Register succeeds with valid params
  test('should return User when registration is successful', () async {
    when(
      mockRepository.register(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        preference: 'Men',
        country: 'Nepal',
        phoneNumber: '9800000000',
      ),
    ).thenAnswer((_) async => tUser);

    final result = await usecase(
      const RegisterParams(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        preference: 'Men',
        country: 'Nepal',
        phoneNumber: '9800000000',
      ),
    );

    expect(result, const Right(tUser));
    verify(
      mockRepository.register(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        preference: 'Men',
        country: 'Nepal',
        phoneNumber: '9800000000',
      ),
    );
  });

  // Test 6: Register fails with empty name
  test('should return Failure when name is empty', () async {
    final result = await usecase(
      const RegisterParams(
        name: '',
        email: 'test@example.com',
        password: 'password123',
        country: 'Nepal',
      ),
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, 'Name is required'),
      (_) => fail('Should be Left'),
    );
    verifyZeroInteractions(mockRepository);
  });
}
