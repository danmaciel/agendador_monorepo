import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_mobile/core/widget/filtro_periodo_widget.dart';
import 'package:projeto_mobile/core/util/agendamento_status_color.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_bloc.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_event.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_state.dart';
import 'package:projeto_mobile/core/extensions/string.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AdminRelatorioDetalhadoPage extends StatefulWidget {
  const AdminRelatorioDetalhadoPage({super.key});

  @override
  State<AdminRelatorioDetalhadoPage> createState() => _AdminRelatorioDetalhadoPageState();
}

class _AdminRelatorioDetalhadoPageState extends State<AdminRelatorioDetalhadoPage> {
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  void initState() {
    super.initState();
    // Inicia com o mês atual por padrão
    final now = DateTime.now();
    _dataInicio = DateTime(now.year, now.month, 1);
    _dataFim = DateTime(now.year, now.month + 1, 0);
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  void _fetch() {
    context.read<AgendamentoBloc>().add(GetAgendamentosRequested(
          dataInicio: _dataInicio != null ? DateFormat('yyyy-MM-dd').format(_dataInicio!) : null,
          dataFim: _dataFim != null ? DateFormat('yyyy-MM-dd').format(_dataFim!) : null,
          sortBy: "data",
          sortDir: "desc"
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatório Detalhado')),
      body: Column(
        children: [
          FiltroPeriodoWidget(
            dataInicio: _dataInicio,
            dataFim: _dataFim,
            onDateSelected: (picked) {
              setState(() {
                _dataInicio = picked.start;
                _dataFim = picked.end;
              });
              _fetch();
            },
            onClear: () {
              setState(() {
                _dataInicio = null;
                _dataFim = null;
              });
              _fetch();
            },
          ),
          Expanded(
            child: BlocBuilder<AgendamentoBloc, AgendamentoState>(
              builder: (context, state) {
                if (state.status == AgendamentoStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.agendamentos.isEmpty) {
                  return const Center(child: Text('Nenhum agendamento encontrado no período.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.agendamentos.length,
                  separatorBuilder: (_,_) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.agendamentos[index];
                    return Card(
                      child: ListTile(
                        leading: AgendamentoStatusBadge.getBadge(item.status),
                        title: Text(item.nomeUsuario ?? 'Cliente'),
                        subtitle: Text('${item.data.toDate(formatoSaida: "dd/MM/yyyy")} às ${item.horario}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/agendamento-detalhe', extra: {
                          'agendamento': item,
                          'readonly': true,
                        }),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
