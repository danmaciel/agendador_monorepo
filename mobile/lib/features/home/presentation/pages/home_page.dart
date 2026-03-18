import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_mobile/core/widget/filtro_periodo_widget.dart';
import 'package:projeto_mobile/core/widget/snackbar_message.dart';
import 'package:projeto_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:projeto_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:projeto_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_bloc.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_event.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_state.dart';
import 'package:projeto_mobile/features/home/presentation/widgets/agendamento_card_widget.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  void initState() {
    super.initState();
    _checkAndFetch();
  }

  void _checkAndFetch() {
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated) {
      _dispatchFetch(authState.userId);
    }
  }

  void _dispatchFetch(String? userId) {
    final id = int.tryParse(userId ?? '0') ?? 0;
    if (id > 0) {
      context.read<AgendamentoBloc>().add(GetMeusAgendamentosRequested(
            usuarioId: id,
            dataInicio: _dataInicio != null ? DateFormat('yyyy-MM-dd').format(_dataInicio!) : null,
            dataFim: _dataFim != null ? DateFormat('yyyy-MM-dd').format(_dataFim!) : null,
          ));
    }
  }

  void _clearFilters(String? userId) {
    setState(() {
      _dataInicio = null;
      _dataFim = null;
    });
    _dispatchFetch(userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState.status == AuthStatus.authenticated) {
          _dispatchFetch(authState.userId);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState.status != AuthStatus.authenticated) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Meus agendamentos'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FiltroPeriodoWidget(
                  dataInicio: _dataInicio,
                  dataFim: _dataFim,
                  onDateSelected: (picked) {
                    setState(() {
                      _dataInicio = picked.start;
                      _dataFim = picked.end;
                    });
                    _dispatchFetch(authState.userId);
                  },
                  onClear: () => _clearFilters(authState.userId),
                ),
                Expanded(
                  child: BlocBuilder<AgendamentoBloc, AgendamentoState>(
                    builder: (context, state) {
                      if (state.status == AgendamentoStatus.loading && state.agendamentos.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.status == AgendamentoStatus.error) {
                        return _buildErrorState(authState.userId, state.errorMessage);
                      }

                      if (state.agendamentos.isEmpty && state.status != AgendamentoStatus.loading) {
                        return const Center(child: Text('Nenhum agendamento encontrado para este período.'));
                      }

                      return RefreshIndicator(
                        onRefresh: () async => _dispatchFetch(authState.userId),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.agendamentos.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = state.agendamentos[index];
                            return AgendamentoCardWidget(
                                item: item,
                                onEdit: () => context.push('/agendar', extra: item),
                                onBlock: () => _showBloqueioAlteracao(context));
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Agendar'),
                BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
              ],
              onTap: (index) {
                if (index == 1) context.push('/agendar');
                if (index == 2) context.push('/historico');
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String? userId, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message ?? 'Erro ao carregar dados'),
          TextButton(
            onPressed: () => _dispatchFetch(userId),
            child: const Text('TENTAR NOVAMENTE'),
          ),
        ],
      ),
    );
  }

  void _showBloqueioAlteracao(BuildContext context) {
    SnackbarMessage.erro(context, 'Alteração bloqueada: prazo inferior a 2 dias.');
  }
}
