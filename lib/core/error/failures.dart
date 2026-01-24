import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({String message = "Local Database Failure"})
    : super(message);
}

class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({String message = "API Failure", this.statusCode})
    : super(message);
}
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({String message = "Authentication Failure"})
    : super(message);
}
class ServerFailure extends Failure {
  final int? statusCode;
  final dynamic data;

  const ServerFailure({
    String message = "Server Failure",
    this.statusCode,
    this.data,
  }) : super(message);
}
class CacheFailure extends Failure {
  const CacheFailure({String message = "Cache Failure"})
    : super(message);
}
class NetworkFailure extends Failure {
  const NetworkFailure({String message = "Network Failure"})
    : super(message);
}


