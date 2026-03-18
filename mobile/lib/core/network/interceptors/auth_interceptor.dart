import 'package:dio/dio.dart';
import '../../auth/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;

  AuthInterceptor(this._tokenStorage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _tokenStorage.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          final response = await _dio.post('/api/v1/auth/refresh', data: {
            'refreshToken': refreshToken,
          });

          if (response.statusCode == 200) {
            final newToken = response.data['token'];
            final newRefreshToken = response.data['refreshToken'];

            await _tokenStorage.saveTokens(
              token: newToken,
              refreshToken: newRefreshToken,
            );

            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            
            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          await _tokenStorage.clearTokens();
        }
      }
    }
    return handler.next(err);
  }
}
