abstract class ApiException implements Exception {
  final String message;
  final int? statusCode; // Optional: HTTP status code

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}

// Specific exception for network issues (e.g., no internet, DNS failure)
class NetworkException extends ApiException {
  NetworkException({super.message = "Network error occurred. Please check your connection."});
}

// Specific exception for server-side errors (5xx)
class ServerException extends ApiException {
  ServerException({super.message = "Server error occurred. Please try again later.", super.statusCode});
}

// Specific exception for client-side errors (4xx, e.g., Not Found, Unauthorized)
class ClientException extends ApiException {
  final dynamic errorData; // Optional: To carry additional error details from API response

  ClientException({
    required super.message,
    super.statusCode,
    this.errorData,
  });

  @override
  String toString() => 'ClientException: $message (Status Code: $statusCode, Data: $errorData)';
}

// Specific exception for authentication failures (401, 403)
class UnauthorizedException extends ClientException {
  UnauthorizedException({super.message = "Unauthorized. Please login again.", super.statusCode = 401});
}

// Specific exception for when the API returns an unexpected response format
class UnexpectedResponseException extends ApiException {
  UnexpectedResponseException({super.message = "Received an unexpected response from the server."});
}

class TimeoutException extends ApiException {
  TimeoutException({super.message = "Received an unexpected response from the server."});
}