import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_mobile/core/logger/app_logger.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final isAuthenticated = await _repository.isAuthenticated();
    if (isAuthenticated) {
      final userId = await _repository.getUserId();
      final userName = await _repository.getUserName();
      final userRole = await _repository.getUserRole();
      
      AppLogger.i('Usuário autenticado: $userName (ID: $userId, Role: $userRole)');
      emit(AuthState.authenticated(userId ?? '', userName ?? '', userRole ?? ''));
    } else {
      AppLogger.d('Usuário não autenticado.');
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await _repository.login(event.login, event.senha);
      final userId = await _repository.getUserId();
      final userName = await _repository.getUserName();
      final userRole = await _repository.getUserRole();
      
      AppLogger.i('Login realizado: $userName');
      emit(AuthState.authenticated(userId ?? '', userName ?? '', userRole ?? ''));
    } catch (e) {
      AppLogger.e('Erro no login', e);
      emit(AuthState(status: AuthStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await _repository.register(event.nome, event.login, event.senha);
      add(AuthLoginRequested(login: event.login, senha: event.senha));
    } catch (e) {
      AppLogger.e('Erro no registro', e);
      emit(AuthState(status: AuthStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(AuthState.unauthenticated());
  }
}
