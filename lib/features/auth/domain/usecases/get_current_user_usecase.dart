import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/core/error/failures.dart';
import 'package:tapto/core/usecases/app_usecases.dart';
import 'package:tapto/core/services/storage/user_session_service.dart';
import 'package:tapto/core/services/hive/hive_services.dart'; // Import the HiveService
import 'package:tapto/features/auth/domain/entities/user.dart';
import 'package:tapto/features/auth/domain/repositories/auth_repository.dart';
import 'package:tapto/features/auth/data/repositories/auth_repository.dart';
import 'package:tapto/features/auth/data/datasource/local/auth_local_datasource.dart';

/// Provider for UserSessionService
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService();
});

/// Provider for AuthLocalDataSource
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final sessionService = ref.read(userSessionServiceProvider);
  final hiveService = ref.read(hiveServiceProvider); // Now defined
  return AuthLocalDataSourceImpl(
    sessionService: sessionService,
    hiveService: hiveService,
  );
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.read(authLocalDataSourceProvider);
  return AuthRepositoryImpl(localDataSource: localDataSource);
});

/// Provider for GetCurrentUserUsecase
final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(authRepository: authRepository);
});

/// Use case for getting the current logged-in user
class GetCurrentUserUsecase implements UsecaseWithoutParms<User?> {
  final AuthRepository _authRepository;

  GetCurrentUserUsecase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, User?>> call() async {
    try {
      final user = await _authRepository.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(
        LocalDatabaseFailure(
          message: 'Failed to get current user: ${e.toString()}',
        ),
      );
    }
  }
}
