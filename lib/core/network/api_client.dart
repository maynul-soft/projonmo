import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../../features/auth/controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';
import 'token_storage.dart';

/// Global Production-Ready Network Client powered by Dio
class ApiClient extends GetxService {
  late final Dio _dio;
  final TokenStorage tokenStorage = TokenStorage.instance;

  // Debounce flag to prevent duplicate 401 redirects and duplicate snackbars
  static bool _isRedirecting = false;

  /// Singleton Instance
  static final ApiClient instance = ApiClient._internal();

  ApiClient._internal() {
    _initDio();
  }

  factory ApiClient() => instance;

  Dio get dioClient => _dio;

  void _initDio() {
    final baseOptions = BaseOptions(
      baseUrl: ApiEndpoints.defaultBaseUrl,
      connectTimeout: ApiEndpoints.connectTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      sendTimeout: ApiEndpoints.sendTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.json,
    );

    _dio = Dio(baseOptions);

    // 1. Interceptors (Auth token injection, 401 redirect, Logging)
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Auto-set Authorization header from SharedPreferences cache if token exists
          final token = await tokenStorage.getToken();
          if (token != null && token.isNotEmpty && !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException err, handler) async {
          // Handle 401 Unauthorized globally (exclude login/auth endpoints where 401 means invalid credentials)
          final path = err.requestOptions.path;
          final isAuthEndpoint = path.contains('/auth/login') ||
              path.contains('/auth/register') ||
              path.contains('/auth/send-otp') ||
              path.contains('/auth/verify-otp');

          if (err.response?.statusCode == 401 && !isAuthEndpoint) {
            await _handleUnauthorized();
          }
          return handler.next(err);
        },
      ),
    );

    // 2. Logging Interceptor in Debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('[Dio] $obj'),
        ),
      );
    }
  }

  /// Global 401 Handler: Shows Toast/Snackbar and redirects to Login screen
  Future<void> _handleUnauthorized() async {
    if (_isRedirecting) return;
    _isRedirecting = true;

    // 1. Clear cached token from SharedPreferences
    await tokenStorage.clearToken();

    // 2. Clear current user state in AuthController if registered
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().currentUser.value = null;
    }

    // 3. Show Toast / Snackbar message
    Get.snackbar(
      'Session Expired',
      'Your session has expired. Please sign in again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      icon: const Icon(Icons.lock_clock_outlined, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
    );

    // 4. Directly navigate to login page
    Future.microtask(() {
      Get.offAllNamed(AppRoutes.login);
      // Reset debounce guard after navigation settles
      Future.delayed(const Duration(seconds: 2), () {
        _isRedirecting = false;
      });
    });
  }

  // ==========================================
  // TOKEN HELPER METHODS (via SharedPreferences)
  // ==========================================

  /// Set and persist auth token in SharedPreferences
  Future<void> setToken(String token) async {
    await tokenStorage.saveToken(token);
  }

  /// Retrieve current auth token from SharedPreferences
  Future<String?> getToken() async {
    return await tokenStorage.getToken();
  }

  /// Clear token from SharedPreferences
  Future<void> clearToken() async {
    await tokenStorage.clearToken();
  }

  /// Check if auth token exists
  Future<bool> hasToken() async {
    return await tokenStorage.hasToken();
  }

  // ==========================================
  // CLIENT CONFIGURATION
  // ==========================================

  /// Change base URL at runtime (e.g. environment switch)
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// Set default global header
  void setDefaultHeader(String key, dynamic value) {
    _dio.options.headers[key] = value;
  }

  /// Remove default global header
  void removeDefaultHeader(String key) {
    _dio.options.headers.remove(key);
  }

  // ==========================================
  // MERGE EXTRA HEADERS HELPER
  // ==========================================

  Options _mergeOptions({Options? options, Map<String, dynamic>? headers}) {
    final opts = options ?? Options();
    if (headers != null && headers.isNotEmpty) {
      final mergedHeaders = Map<String, dynamic>.from(opts.headers ?? {});
      mergedHeaders.addAll(headers);
      opts.headers = mergedHeaders;
    }
    return opts;
  }

  // ==========================================
  // HTTP REQUEST METHODS
  // ==========================================

  /// HTTP GET Request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final merged = _mergeOptions(options: options, headers: headers);
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// HTTP POST Request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final merged = _mergeOptions(options: options, headers: headers);
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// HTTP PUT Request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final merged = _mergeOptions(options: options, headers: headers);
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// HTTP PATCH Request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final merged = _mergeOptions(options: options, headers: headers);
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// HTTP DELETE Request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final merged = _mergeOptions(options: options, headers: headers);
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// HTTP File / Multipart Upload Request
  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final opts = _mergeOptions(options: options, headers: headers);
      opts.contentType = 'multipart/form-data';
      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: opts,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// HTTP File Download Request
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final merged = _mergeOptions(options: options, headers: headers);
      return await _dio.download(
        urlPath,
        savePath,
        queryParameters: queryParameters,
        options: merged,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
