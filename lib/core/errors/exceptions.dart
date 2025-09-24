enum NetworkErrorType {
  noConnection,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  unknown,
}

class NetworkException implements Exception {
  final String message;
  final NetworkErrorType type;

  NetworkException(this.message, this.type);

  @override
  String toString() => 'NetworkException: $message';

  // Helper getters for UI
  bool get isAuthError => type == NetworkErrorType.unauthorized;
  bool get isConnectionError =>
      type == NetworkErrorType.noConnection || type == NetworkErrorType.timeout;
}

class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class StorageException implements Exception {
  final String message;

  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
