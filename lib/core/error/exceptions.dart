/// Custom exceptions for the application

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
  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'ServerException ($statusCode): $message'
      : 'ServerException: $message';
}

/// Cache exceptions
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}
