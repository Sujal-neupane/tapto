import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tapto/features/auth/domain/usecases/logout_usecase.dart';

import '../../../../mocks/mock_auth_repository.dart';

void main() {
  late LogoutUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LogoutUsecase(mockRepository);
  });

  // Test 7: Logout succeeds
  test('should return Right(null) when logout is successful', () async {
    when(mockRepository.logout()).thenAnswer((_) async {});

    final result = await usecase();

    expect(result, const Right(null));
    verify(mockRepository.logout());
    verifyNoMoreInteractions(mockRepository);
  });

  // Test 8: Logout fails when repository throws
  test('should return Failure when logout throws an exception', () async {
    when(mockRepository.logout()).thenThrow(Exception('Session expired'));

    final result = await usecase();

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, contains('Session expired')),
      (_) => fail('Should be Left'),
    );
  });
}
