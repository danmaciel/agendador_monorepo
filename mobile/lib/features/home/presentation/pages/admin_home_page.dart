import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_bloc.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_event.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_state.dart';
import 'package:projeto_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:projeto_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:intl/intl.dart';
import 'package:projeto_mobile/features/home/presentation/widgets/agenda_diaria_widget.dart';
import 'package:projeto_mobile/features/home/presentation/widgets/grafico_widget.dart';
import 'package:projeto_mobile/features/home/presentation/widgets/kpi_card_widget.dart';
import 'package:projeto_mobile/features/agendamento/data/models/dashboard_model.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late String _dataInicio;
  late String _dataFim;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    
    final formatter = DateFormat('yyyy-MM-dd');
    _dataInicio = formatter.format(firstDay);
    _dataFim = formatter.format(lastDay);

    context.read<AgendamentoBloc>().add(GetDashboardRequested(
      dataInicio: _dataInicio,
      dataFim: _dataFim,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Atualizar dados',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: BlocBuilder<AgendamentoBloc, AgendamentoState>(
        builder: (context, state) {
          if (state.status == AgendamentoStatus.loading && state.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final dashboard = state.dashboard;

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Visão Geral'),
                  const SizedBox(height: 12),
                  _buildKpiCards(dashboard),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Desempenho Mensal'),
                      TextButton(
                        onPressed: () => context.push('/admin/relatorio-detalhado', extra: {
                          'dataInicio': _dataInicio,
                          'dataFim': _dataFim,
                        }).whenComplete(_refreshData),
                        child: const Text('Ver detalhes'),
                      ),
                    ],
                  ),
                  GraficoWidget(
                    chartData: dashboard?.agendamentosPorDia
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Agenda de Hoje'),
                      TextButton(
                        onPressed: () => context.push('/agendamentos-pendentes').whenComplete(_refreshData),
                        child: const Text('Ver Pendências'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AgendaDiariaWidget(agendamentos: state.agendamentos),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/servicos-admin'),
        label: const Text('Gerenciar Serviços'),
        icon: const Icon(Icons.settings),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildKpiCards(DashboardModel? data) {
    return Row(
      children: [
        KpiCardWidget(label: 'Aprovados', value: data?.aprovados.toString() ?? '0', color: Colors.green),
        KpiCardWidget(label: 'Pendentes', value: data?.pendentes.toString() ?? '0', color: Colors.orange),
        KpiCardWidget(label: 'Rejeitados', value: data?.rejeitados.toString() ?? '0', color: Colors.red),
      ],
    );
  }
}
