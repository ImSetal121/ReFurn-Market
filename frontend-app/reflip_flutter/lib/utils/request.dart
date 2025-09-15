import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../stores/auth_store.dart';
import '../config/api_config.dart';

class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({required this.code, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic)? fromJson,
  ) {
    return ApiResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : null,
    );
  }
}

class HttpRequest {
  static final Dio _dio = Dio();
  static bool _isInitialized = false;

  // 调试开关：控制是否打印请求响应详细信息
  static bool enableDebugLog = true;

  // 初始化Dio配置
  static void init() {
    if (_isInitialized) return;

    // 使用ApiConfig获取基础URL并打印环境信息
    ApiConfig.printEnvironmentInfo();

    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );

    // 请求拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 添加认证令牌
          final accessToken = authStore.accessToken;
          if (accessToken != null) {
            // 使用标准的Bearer格式
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          // 打印请求信息
          if (enableDebugLog) {
            _printRequestInfo(options);
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // 打印错误信息
          if (enableDebugLog) {
            _printErrorInfo(error);
          }
          _handleError(error);
          return handler.next(error);
        },
        onResponse: (response, handler) {
          // 打印响应信息
          if (enableDebugLog) {
            _printResponseInfo(response);
          }
          return handler.next(response);
        },
      ),
    );

    _isInitialized = true;
  }

  // 打印请求信息
  static void _printRequestInfo(RequestOptions options) {
    print('=== HTTP 请求信息 ===');
    print('请求方法: ${options.method}');
    print('请求地址: ${options.baseUrl}${options.path}');
    print('请求参数: ${options.queryParameters}');
    print('请求头: ${options.headers}');
    if (options.data != null) {
      print('请求负载: ${options.data}');
    }
    print('连接超时: ${options.connectTimeout}');
    print('接收超时: ${options.receiveTimeout}');
    print('==================');
  }

  // 打印响应信息
  static void _printResponseInfo(Response response) {
    print('=== HTTP 响应信息 ===');
    print('响应码: ${response.statusCode}');
    print('响应消息: ${response.statusMessage}');
    print('响应头: ${response.headers.map}');
    print('响应数据: ${response.data}');
    print('==================');
  }

  // 打印错误信息
  static void _printErrorInfo(DioException error) {
    print('=== HTTP 错误信息 ===');
    print('错误类型: ${error.type}');
    print('错误消息: ${error.message}');
    if (error.response != null) {
      print('错误响应码: ${error.response!.statusCode}');
      print('错误响应数据: ${error.response!.data}');
    }
    print('==================');
  }

  // 处理错误
  static void _handleError(DioException error) {
    String errorMessage = '请求失败';

    if (error.response != null) {
      // 服务器返回错误
      final statusCode = error.response!.statusCode;

      try {
        errorMessage = error.response!.data['message'] ?? '服务器错误';
      } catch (e) {
        errorMessage = '服务器错误 ($statusCode)';
      }

      // 处理401未授权错误
      if (statusCode == 401) {
        authStore.reset();
        // 重定向到登录页面的逻辑将在路由部分处理
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      errorMessage = '连接超时，请检查网络';
    } else if (error.type == DioExceptionType.unknown &&
        error.error is SocketException) {
      errorMessage = '网络连接失败，请检查网络设置';
    }

    // 显示错误提示
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  // GET请求
  static Future<T?> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T? Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // POST请求
  static Future<T?> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T? Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // PUT请求
  static Future<T?> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T? Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // DELETE请求
  static Future<T?> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T? Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // 处理响应
  static T? _handleResponse<T>(
    Response response,
    T? Function(dynamic)? fromJson,
  ) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final apiResponse = ApiResponse.fromJson(data, fromJson);

      // 如果接口返回成功状态码
      if (apiResponse.code == 200) {
        return apiResponse.data;
      }

      // 处理错误情况
      Fluttertoast.showToast(
        msg: apiResponse.message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      // 处理未授权情况
      if (apiResponse.code == 401) {
        authStore.reset();
        // 重定向到登录页面的逻辑将在路由部分处理
      }

      return null;
    }

    // 如果响应不是预期的格式
    Fluttertoast.showToast(
      msg: '服务器响应格式错误',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );

    return null;
  }
}
