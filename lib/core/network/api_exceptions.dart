import 'package:dio/dio.dart';

/// Standard Custom API Exception Wrapper
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';

  /// Construct an ApiException from a DioException
  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException(
          message: 'Connection timed out. Please check your internet connection.',
          statusCode: null,
        );
      case DioExceptionType.sendTimeout:
        return const ApiException(
          message: 'Send request timed out. Please try again.',
          statusCode: null,
        );
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Response timed out from server. Please try again.',
          statusCode: null,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'SSL certificate verification failed.',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Cannot connect to server. Please verify your internet connection.',
          statusCode: null,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        final responseData = response?.data;
        String extractedMessage = 'Something went wrong. Please try again.';

        bool hasCustomMessage = false;
        if (responseData is Map<String, dynamic>) {
          if (responseData['message'] != null && responseData['message'].toString().trim().isNotEmpty) {
            extractedMessage = responseData['message'].toString();
            hasCustomMessage = true;
          } else if (responseData['error'] != null && responseData['error'].toString().trim().isNotEmpty) {
            extractedMessage = responseData['error'].toString();
            hasCustomMessage = true;
          } else if (responseData['errors'] != null && responseData['errors'].toString().trim().isNotEmpty) {
            extractedMessage = responseData['errors'].toString();
            hasCustomMessage = true;
          }
        } else if (responseData is String && responseData.trim().isNotEmpty) {
          extractedMessage = responseData;
          hasCustomMessage = true;
        }

        if (!hasCustomMessage) {
          if (statusCode == 401) {
            extractedMessage = 'Invalid credentials or session expired.';
          } else if (statusCode == 403) {
            extractedMessage = 'Access denied or account blocked.';
          } else if (statusCode == 404) {
            extractedMessage = 'Requested resource not found.';
          } else if (statusCode != null && statusCode >= 500) {
            extractedMessage = 'Server encountered an error. Please try again later.';
          }
        }

        return ApiException(
          message: extractedMessage,
          statusCode: statusCode,
          data: responseData,
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message ?? 'An unexpected network error occurred.',
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
    }
  }
}
