import 'package:dio/dio.dart';
import '../models/login_response.dart';

class AuthDataSource {
  final Dio _dio;

  AuthDataSource(this._dio);

  Future<LoginResponse> login(String login, String senha) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {
          'login': login,
          'senha': senha,
        },
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Extrai a mensagem de erro do backend se disponível
      final errorMessage = e.response?.data['message'] ?? 'Erro ao realizar login';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> register(String nome, String login, String senha) async {
    try {
      await _dio.post(
        '/api/v1/usuario',
        data: {
          'nome': nome,
          'login': login,
          'senha': senha,
        },
      );
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Erro ao realizar cadastro';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
