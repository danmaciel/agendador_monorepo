import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? userId;
  final String? userName;
  final String? userRole;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.userName,
    this.userRole,
    this.errorMessage,
  });

  factory AuthState.authenticated(String userId, String userName, String userRole) {
    return AuthState(
      status: AuthStatus.authenticated,
      userId: userId,
      userName: userName,
      userRole: userRole,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  @override
  List<Object?> get props => [status, userId, userName, userRole, errorMessage];
}
