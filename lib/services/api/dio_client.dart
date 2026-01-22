import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../helpera/constants.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;
  factory DioClient() {
    return _instance;
  }
  DioClient._internal() {

    final host =
        kIsWeb ? 'localhost' : (Platform.isAndroid ? '10.0.2.2' : 'localhost');
    final baseUrl = 'http://$host:3000';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: AppConstants.apiConnectTimeout),
        receiveTimeout: const Duration(seconds: AppConstants.apiReceiveTimeout),
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
      ),
    );


    _dio.interceptors.add(LogInterceptor(
        requestBody: true, responseBody: true, requestHeader: true));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {

          final storage = GetStorage();
          var token = storage.read(AppConstants.keyToken) as String?;
          if (token == null) {
            final settingsBox = Hive.box(AppConstants.boxSettings);
            token = settingsBox.get(AppConstants.keyToken) as String?;
          }
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
