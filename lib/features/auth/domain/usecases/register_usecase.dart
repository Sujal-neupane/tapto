import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/auth/domain/usecases/get_current_user_usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import './auth_params.dart';

class RegisterUsecase implements UsecaseWithParms<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    if (params.name.isEmpty) {
      return Left(LocalDatabaseFailure(message: 'Name is required'));
    }

    if (params.email.isEmpty || !params.email.contains('@')) {
      return Left(LocalDatabaseFailure(message: 'Invalid email address'));
    }

    if (params.password.isEmpty || params.password.length < 6) {
      return Left(
        LocalDatabaseFailure(message: 'Password must be at least 6 characters'),
      );
    }

    try {
      final user = await repository.register(
        name: params.name,
        email: params.email,
        password: params.password,
        preference: params.preference,
        country: params.country,
        phoneNumber: params.phoneNumber,
      );
      return Right(user);
    } catch (e) {
      return Left(
        LocalDatabaseFailure(
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUsecase(authRepository);
});
