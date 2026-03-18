abstract class EnvConfig {
  String get baseUrl;
  String get appName;
}

class DevConfig implements EnvConfig {
  @override
  String get baseUrl => 'http://10.0.2.2:8080';

  @override
  String get appName => 'Agendamento (DEV)';
}

class ProdConfig implements EnvConfig {
  @override
  String get baseUrl => 'https://api.seu-projeto.com/api/v1';

  @override
  String get appName => 'Agendamento';
}
