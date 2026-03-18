import 'package:dio/dio.dart';
import '../config/env_config.dart';
import 'interceptors/auth_interceptor.dart';
import '../auth/storage/token_storage.dart';

class NetworkModule {
  static Dio noAuthDio(EnvConfig config) {
    return Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );
  }

  static Dio dio(EnvConfig config, TokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    final noAuth = noAuthDio(config);
    dio.interceptors.add(AuthInterceptor(tokenStorage, noAuth));
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  }
}
