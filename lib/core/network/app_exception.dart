/// A user-friendly error that the UI can show directly.
class AppException implements Exception {
  final String message;
  final AppErrorType type;

  const AppException(this.message, {this.type = AppErrorType.unknown});

  const AppException.noInternet()
      : message = 'No internet connection. Please check your network and try again.',
        type = AppErrorType.noInternet;

  const AppException.timeout()
      : message = 'The request timed out. Please try again.',
        type = AppErrorType.timeout;

  const AppException.invalidResponse()
      : message = 'We received an unexpected response from the server.',
        type = AppErrorType.invalidResponse;

  @override
  String toString() => message;
}

enum AppErrorType { noInternet, timeout, server, invalidResponse, unknown }
