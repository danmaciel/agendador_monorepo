import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse extends Equatable {
  final String token;
  final String tipo;
  final int expiracao;
  final String refreshToken;

  const LoginResponse({
    required this.token,
    required this.tipo,
    required this.expiracao,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  List<Object?> get props => [token, tipo, expiracao, refreshToken];
}
