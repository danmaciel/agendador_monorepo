import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:projeto_mobile/core/auth/storage/token_storage.dart';
import '../datasources/auth_datasource.dart';
import '../models/login_response.dart';

class AuthRepository {
  final AuthDataSource _dataSource;
  final TokenStorage _tokenStorage;

  AuthRepository(this._dataSource, this._tokenStorage);

  Future<void> login(String login, String senha) async {
    final LoginResponse response = await _dataSource.login(login, senha);
    await _tokenStorage.saveTokens(
      token: response.token,
      refreshToken: response.refreshToken,
    );
  }

  Future<void> register(String nome, String login, String senha) async {
    await _dataSource.register(nome, login, senha);
  }

  Future<bool> isAuthenticated() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  Future<String?> getUserRole() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return null;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['roles'];
  }

  Future<String?> getUserId() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return null;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['user_id']?.toString();
  }

  Future<String?> getUserName() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return null;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['name'];
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }
}
