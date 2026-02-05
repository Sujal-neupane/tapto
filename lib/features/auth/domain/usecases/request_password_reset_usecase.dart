import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:tapto/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/features/auth/data/repositories/auth_repository.dart';
import '../repositories/auth_repository.dart';

class RequestPasswordResetUsecase implements UsecaseWithParms<void, String> {
  final AuthRepository repository;

  RequestPasswordResetUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      return Left(LocalDatabaseFailure(message: 'Invalid email address'));
    }

    try {
      await repository.requestPasswordReset(email);
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

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.read(authLocalDataSourceProvider),
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final requestPasswordResetUsecaseProvider = Provider<RequestPasswordResetUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RequestPasswordResetUsecase(authRepository);
});