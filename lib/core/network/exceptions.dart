import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final NetworkExceptionType type;
  final dynamic originalError;

  NetworkException(
    this.message, {
    this.statusCode,
    this.type = NetworkExceptionType.unknown,
    this.originalError,
  });

  factory NetworkException.fromDioError(dynamic error) {
    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is NetworkException) {
      return error;
    }

    final errorString = error.toString();
    if (errorString.contains('SocketException')) {
      return NetworkException(
        'No internet connection. Please check your network.',
        type: NetworkExceptionType.connection,
        originalError: error,
      );
    }

    return NetworkException(
      'An unexpected error occurred. Please try again.',
      type: NetworkExceptionType.unknown,
      originalError: error,
    );
  }

  static NetworkException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          'Connection is taking too long. Please check your internet.',
          type: NetworkExceptionType.timeout,
          originalError: error,
        );

      case DioExceptionType.sendTimeout:
        return NetworkException(
          'Request is taking too long. Please try again.',
          type: NetworkExceptionType.timeout,
          originalError: error,
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Server is not responding. Please try again.',
          type: NetworkExceptionType.timeout,
          originalError: error,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return NetworkException(
          'Request was cancelled',
          type: NetworkExceptionType.cancelled,
          originalError: error,
        );

      case DioExceptionType.connectionError:
        final errorMessage = error.message ?? '';
        if (errorMessage.contains('SocketException')) {
          return NetworkException(
            'No internet connection. Please check your network.',
            type: NetworkExceptionType.connection,
            originalError: error,
          );
        } else if (errorMessage.contains('Connection refused')) {
          return NetworkException(
            'Cannot reach the server. Please try again later.',
            type: NetworkExceptionType.connection,
            originalError: error,
          );
        }
        return NetworkException(
          'Connection error. Please check your internet.',
          type: NetworkExceptionType.connection,
          originalError: error,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'Security certificate error. Please try again later.',
          type: NetworkExceptionType.security,
          originalError: error,
        );

      case DioExceptionType.unknown:
        final errorMessage = error.message ?? '';
        if (errorMessage.contains('SocketException')) {
          return NetworkException(
            'No internet connection available.',
            type: NetworkExceptionType.connection,
            originalError: error,
          );
        } else if (errorMessage.contains('HandshakeException')) {
          return NetworkException(
            'Secure connection failed. Please try again.',
            type: NetworkExceptionType.security,
            originalError: error,
          );
        }
        return NetworkException(
          'Network error occurred. Please check your connection.',
          type: NetworkExceptionType.unknown,
          originalError: error,
        );
    }
  }

  static NetworkException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] ?? responseData['error'];
    }

    switch (statusCode) {
      case 400:
        return NetworkException(
          serverMessage ?? 'Invalid request. Please try again.',
          statusCode: statusCode,
          type: NetworkExceptionType.badRequest,
          originalError: error,
        );

      case 401:
        return NetworkException(
          'Session expired. Please login again.',
          statusCode: statusCode,
          type: NetworkExceptionType.unauthorized,
          originalError: error,
        );

      case 403:
        return NetworkException(
          'Access denied. You don\'t have permission.',
          statusCode: statusCode,
          type: NetworkExceptionType.forbidden,
          originalError: error,
        );

      case 404:
        return NetworkException(
          'Content not found. Please try again.',
          statusCode: statusCode,
          type: NetworkExceptionType.notFound,
          originalError: error,
        );

      case 408:
        return NetworkException(
          'Request timeout. Please try again.',
          statusCode: statusCode,
          type: NetworkExceptionType.timeout,
          originalError: error,
        );

      case 429:
        return NetworkException(
          'Too many requests. Please wait and try again.',
          statusCode: statusCode,
          type: NetworkExceptionType.tooManyRequests,
          originalError: error,
        );

      case 500:
      case 501:
      case 502:
      case 503:
        return NetworkException(
          'Server error. Please try again later.',
          statusCode: statusCode,
          type: NetworkExceptionType.server,
          originalError: error,
        );

      case 504:
        return NetworkException(
          'Server timeout. Please try again later.',
          statusCode: statusCode,
          type: NetworkExceptionType.timeout,
          originalError: error,
        );

      default:
        return NetworkException(
          serverMessage ?? 'Something went wrong. Please try again.',
          statusCode: statusCode,
          type: NetworkExceptionType.unknown,
          originalError: error,
        );
    }
  }

  @override
  String toString() => message;

  bool get isConnectivityIssue =>
      type == NetworkExceptionType.connection ||
      type == NetworkExceptionType.timeout;

  bool get isServerError =>
      type == NetworkExceptionType.server ||
      (statusCode != null && statusCode! >= 500 && statusCode! < 600);

  bool get isClientError =>
      type == NetworkExceptionType.badRequest ||
      type == NetworkExceptionType.unauthorized ||
      type == NetworkExceptionType.forbidden ||
      type == NetworkExceptionType.notFound ||
      (statusCode != null && statusCode! >= 400 && statusCode! < 500);

  bool get isRetryable =>
      type == NetworkExceptionType.timeout ||
      type == NetworkExceptionType.connection ||
      type == NetworkExceptionType.server ||
      statusCode == 503 ||
      statusCode == 504;
}

enum NetworkExceptionType {
  timeout,
  connection,
  server,
  cancelled,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  tooManyRequests,
  security,
  unknown,
}
