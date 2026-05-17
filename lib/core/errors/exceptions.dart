/// Low-level exceptions thrown by data sources. Repositories catch these
/// and convert them to Failure (below) before they cross the domain boundary.
class AppException implements Exception {
  AppException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException: $message${cause != null ? ' ($cause)' : ''}';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.cause});
}

class CacheException extends AppException {
  CacheException(super.message, {super.cause});
}

class NotFoundException extends AppException {
  NotFoundException(super.message, {super.cause});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.cause});
}