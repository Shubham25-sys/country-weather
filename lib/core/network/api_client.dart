import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'app_exception.dart';

/// Thin wrapper around Dio that turns every failure into an [AppException].
class ApiClient {
  final Dio _dio;
  final Connectivity _connectivity;

  ApiClient({Dio? dio, Connectivity? connectivity})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: AppConfig.requestTimeout,
              receiveTimeout: AppConfig.requestTimeout,
            )),
        _connectivity = connectivity ?? Connectivity();

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    await _ensureConnected();
    try {
      final response = await _dio.get(
        url,
        queryParameters: query,
        options: Options(headers: headers),
      );
      if (response.data == null) throw const AppException.invalidResponse();
      return response.data;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<void> _ensureConnected() async {
    final results = await _connectivity.checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) {
      throw const AppException.noInternet();
    }
  }

  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException.timeout();
      case DioExceptionType.connectionError:
        return const AppException.noInternet();
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 401 || code == 403) {
          return const AppException(
            'Access denied by the server. Please check the API key.',
            type: AppErrorType.server,
          );
        }
        if (code == 429) {
          return const AppException(
            'Too many requests. Please wait a moment and try again.',
            type: AppErrorType.server,
          );
        }
        return AppException(
          'Server error ($code). Please try again later.',
          type: AppErrorType.server,
        );
      default:
        return const AppException('Something went wrong. Please try again.');
    }
  }
}
