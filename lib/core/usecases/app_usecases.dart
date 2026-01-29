import 'package:dartz/dartz.dart';
import 'package:tapto/core/error/failures.dart';

abstract interface class UsecaseWithParms<SucessType, Params> {
  Future<Either<Failure, SucessType>> call(Params params);
}

abstract interface class UsecaseWithoutParms<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}


