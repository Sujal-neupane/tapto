/// Custom exceptions for the application
library;

/// Network related exceptions
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => message;
}

/// API related exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'ApiException ($statusCode): $message'
      : 'ApiException: $message';
}

/// Local database exceptions
class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Authentication exceptions
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Server exceptions
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ServerException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}


class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException({
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}
class PermissionException implements Exception {
  final String message;

  PermissionException({required this.message});

  @override
  String toString() => 'PermissionException: $message';
}
class TimeoutException implements Exception {
  final String message;

  TimeoutException({required this.message});

  @override
  String toString() => 'TimeoutException: $message';
}
class UnknownException implements Exception {
  final String message;

  UnknownException({required this.message});

  @override
  String toString() => 'UnknownException: $message';
}


