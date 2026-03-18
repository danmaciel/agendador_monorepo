import 'package:get_it/get_it.dart';
import 'package:projeto_mobile/core/auth/storage/token_storage.dart';
import 'package:projeto_mobile/core/config/env_config.dart';
import 'package:projeto_mobile/core/network/dio_client.dart';
import 'package:projeto_mobile/features/auth/data/datasources/auth_datasource.dart';
import 'package:projeto_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:projeto_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:projeto_mobile/features/agendamento/data/datasources/agendamento_datasource.dart';
import 'package:projeto_mobile/features/servico/data/datasources/servico_datasource.dart';
import 'package:projeto_mobile/features/agendamento/data/repositories/agendamento_repository.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_bloc.dart';
import 'package:projeto_mobile/core/navigation/app_router.dart';

final getIt = GetIt.instance;

void configureDependencies(String env) {
  // 1. Configuração de Ambiente
  if (env == 'dev') {
    getIt.registerSingleton<EnvConfig>(DevConfig());
  } else {
    getIt.registerSingleton<EnvConfig>(ProdConfig());
  }

  // 2. Core / Infra
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerSingleton(NetworkModule.dio(getIt<EnvConfig>(), getIt<TokenStorage>()));

  // 3. Features - Auth
  getIt.registerLazySingleton<AuthDataSource>(() => AuthDataSource(
    NetworkModule.noAuthDio(getIt<EnvConfig>())
  ));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(
    getIt<AuthDataSource>(),
    getIt<TokenStorage>(),
  ));
  getIt.registerSingleton<AuthBloc>(AuthBloc(getIt<AuthRepository>()));

  // 4. Features - Agendamento & Serviços
  getIt.registerLazySingleton<AgendamentoDataSource>(() => AgendamentoDataSource(getIt()));
  getIt.registerLazySingleton<ServicoDataSource>(() => ServicoDataSource(getIt()));
  
  getIt.registerLazySingleton<AgendamentoRepository>(() => AgendamentoRepository(
    getIt<AgendamentoDataSource>(), 
    getIt<ServicoDataSource>()
  ));

  getIt.registerLazySingleton<AgendamentoBloc>(() => AgendamentoBloc(getIt()));

  // 5. Navegação
  getIt.registerSingleton<AppRouter>(AppRouter(getIt<AuthBloc>()));
}

abstract class Env {
  static const dev = 'dev';
  static const prod = 'prod';
}
