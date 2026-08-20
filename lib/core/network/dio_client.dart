import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kanji_lesson/core/constants/api_constants.dart';
import 'package:kanji_lesson/core/network/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  return DioClient().dio;
});

/// Dio HTTP client with interceptors for retry, logging, and error handling
class DioClient {
  DioClient() : _dio = Dio(_baseOptions) {
    _dio.interceptors.addAll([
      _retryInterceptor(),
      if (kDebugMode) _loggingInterceptor(),
    ]);
  }

  final Dio _dio;

  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
    headers: {
      'Accept': 'application/json',
    },
  );

  Dio get dio => _dio;

  /// GET request with error handling
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Convert DioException to AppException
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return const NotFoundException();
        }
        return const ServerException();
      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled');
      default:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return const UnknownException();
    }
  }

  /// Retry interceptor with exponential backoff
  Interceptor _retryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        final shouldRetry = error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError ||
            (error.response?.statusCode ?? 0) >= 500;

        if (shouldRetry) {
          final retryCount =
              error.requestOptions.extra['retryCount'] as int? ?? 0;

          if (retryCount < 3) {
            final delay = Duration(milliseconds: 500 * (retryCount + 1));
            await Future.delayed(delay);

            error.requestOptions.extra['retryCount'] = retryCount + 1;

            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } on DioException catch (e) {
              return handler.next(e);
            }
          }
        }

        return handler.next(error);
      },
    );
  }

  /// Logging interceptor for debug mode
  Interceptor _loggingInterceptor() {
    return LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (log) => debugPrint('[DIO] $log'),
    );
  }
}
