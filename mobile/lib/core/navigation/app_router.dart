import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/admin_home_page.dart';
import '../../features/servico/presentation/pages/servicos_admin_page.dart';
import '../../features/agendamento/presentation/pages/agendamento_page.dart';
import '../../features/historico/presentation/pages/historico_page.dart';
import '../../features/agendamento/data/models/agendamento_model.dart';
import '../../features/home/presentation/pages/agendamentos_pendentes_page.dart';
import '../../features/agendamento/presentation/pages/admin_agendamento_detalhe_page.dart';
import '../../features/home/presentation/pages/admin_relatorio_detalhado_page.dart';

class AppRouter {
  final AuthBloc _authBloc;

  AppRouter(this._authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) {
      final authState = _authBloc.state;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authState.status == AuthStatus.unauthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (authState.status == AuthStatus.authenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          return BlocBuilder<AuthBloc, AuthState>(
            bloc: _authBloc,
            builder: (context, authState) {
              if (authState.status == AuthStatus.loading || authState.status == AuthStatus.initial) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final role = authState.userRole;
              final userRoles = role?.split(",") ?? [];
              
              if (userRoles.contains('ROLE_ADMIN')) {
                return const AdminHomePage();
              }
              return const HomePage();
            },
          );
        },
      ),
      GoRoute(
        path: '/agendar',
        builder: (context, state) {
          final agendamento = state.extra as AgendamentoModel?;
          return AgendamentoPage(agendamentoParaEdicao: agendamento);
        },
      ),
      GoRoute(
        path: '/historico',
        builder: (context, state) => const HistoricoPage(),
      ),
      GoRoute(
        path: '/servicos-admin',
        builder: (context, state) => const ServicosAdminPage(),
      ),
      GoRoute(
        path: '/agendamentos-pendentes',
        builder: (context, state) => const AgendamentosPendentesPage(),
      ),
      GoRoute(
        path: '/agendamento-detalhe',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return AdminAgendamentoDetalhePage(
              agendamento: extra['agendamento'] as AgendamentoModel,
              readonly: extra['readonly'] as bool? ?? false,
            );
          }
          return AdminAgendamentoDetalhePage(
            agendamento: extra as AgendamentoModel,
            readonly: false,
          );
        },
      ),
      GoRoute(
        path: '/admin/relatorio-detalhado',
        builder: (context, state) => const AdminRelatorioDetalhadoPage(),
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
