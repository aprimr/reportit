import 'package:app/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio _dio;

  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([_AuthInterceptor(), _ErrorInterceptor()]);
  }

  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _TokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _TokenStorage.refreshToken();
      if (refreshed != null) {
        err.requestOptions.headers['Authorization'] = 'Bearer $refreshed';
        final retry = await Dio().fetch(err.requestOptions);
        handler.resolve(retry);
        return;
      }
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = ApiError.fromDio(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiError,
        message: apiError.message,
      ),
    );
  }
}

class _TokenStorage {
  static String? accessToken;
  static String? refreshTokenValue;

  static Future<String?> refreshToken() async {
    return null;
  }
}

class ApiError {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiError({required this.message, this.statusCode, this.errors});

  factory ApiError.fromDio(DioException err) {
    final data = err.response?.data;

    if (data is Map<String, dynamic>) {
      final extractedMessage = data['error'] ?? data['message'];

      return ApiError(
        message: extractedMessage is String
            ? extractedMessage
            : _defaultMessage(err.type),
        statusCode: err.response?.statusCode,
        errors: data['errors'] as Map<String, dynamic>?,
      );
    }

    return ApiError(
      message: _defaultMessage(err.type),
      statusCode: err.response?.statusCode,
    );
  }

  static String _defaultMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badResponse:
        return 'Something went wrong. Please try again.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
