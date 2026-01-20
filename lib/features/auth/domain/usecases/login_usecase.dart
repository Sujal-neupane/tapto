import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/auth/domain/usecases/get_current_user_usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import './auth_params.dart';

class LoginUsecase implements UsecaseWithParms<User, LoginParams> {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    if (params.email.isEmpty || !params.email.contains('@')) {
      return Left(LocalDatabaseFailure(message: 'Invalid email address'));
    }

    if (params.password.isEmpty || params.password.length < 6) {
      return Left(
        LocalDatabaseFailure(message: 'Password must be at least 6 characters'),
      );
    }

    try {
      final user = await repository.login(params.email, params.password);
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

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUsecase(authRepository);
});
