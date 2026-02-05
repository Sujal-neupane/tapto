import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:tapto/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:tapto/core/services/connectivity/network_info.dart';
import 'package:tapto/features/auth/data/repositories/auth_repository.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordParams {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordParams({
    required this.email,
    required this.otp,
    required this.newPassword,
  });
}

class ResetPasswordUsecase implements UsecaseWithParms<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    if (params.email.isEmpty || !params.email.contains('@')) {
      return Left(LocalDatabaseFailure(message: 'Invalid email address'));
    }

    if (params.otp.isEmpty || params.otp.length != 6) {
      return Left(LocalDatabaseFailure(message: 'Invalid OTP code'));
    }

    if (params.newPassword.isEmpty || params.newPassword.length < 6) {
      return Left(LocalDatabaseFailure(message: 'Password must be at least 6 characters'));
    }

    try {
      await repository.resetPassword(params.email, params.otp, params.newPassword);
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

final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ResetPasswordUsecase(authRepository);
});