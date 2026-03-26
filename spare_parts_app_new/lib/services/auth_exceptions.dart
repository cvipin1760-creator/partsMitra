
class EmailAlreadyRegisteredException implements Exception {
  final String message;

  EmailAlreadyRegisteredException(this.message);

  @override
  String toString() => message;
}

class TokenExpiredException implements Exception {
  final String message;

  TokenExpiredException([this.message = 'Session expired. Please login again.']);

  @override
  String toString() => message;
}
