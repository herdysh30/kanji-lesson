import 'package:flutter/foundation.dart';

/// Custom exception types for the application
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  /// User-friendly error message
  String get userMessage;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);

  @override
  String get userMessage => 'Unable to connect. Please check your internet connection.';
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error']);
  final int? statusCode = null;

  @override
  String get userMessage => 'Something went wrong on our end. Please try again later.';
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);

  @override
  String get userMessage => 'The requested data was not found.';
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);

  @override
  String get userMessage => 'The request took too long. Please try again.';
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);

  @override
  String get userMessage => 'Unable to load saved data.';
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Unknown error']);

  @override
  String get userMessage => 'An unexpected error occurred. Please try again.';
}

/// Generic API result wrapper
@immutable
sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.exception);
  final AppException exception;
}
