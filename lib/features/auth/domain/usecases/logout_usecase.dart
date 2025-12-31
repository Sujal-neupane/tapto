import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/auth/domain/usecases/get_current_user_usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUsecase implements UsecaseWithoutParms<void> {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    try {
      await repository.logout();
      return const Right(null);
    } catch (e) {
      return Left(
        LocalDatabaseFailure(
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LogoutUsecase(authRepository);
});
