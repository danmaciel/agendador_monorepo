import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_mobile/core/widget/filtro_periodo_widget.dart';
import 'package:projeto_mobile/core/extensions/string.dart';
import 'package:projeto_mobile/features/agendamento/data/models/agendamento_model.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_bloc.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_event.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_state.dart';
import 'package:projeto_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:intl/intl.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  final _scrollController = ScrollController();
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _buscar(reset: true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<AgendamentoBloc>().state;
      if (!state.hasReachedMax && state.status != AgendamentoStatus.loading) {
        _buscar(reset: false);
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _buscar({bool reset = false}) {
    final authState = context.read<AuthBloc>().state;
    final usuarioId = int.tryParse(authState.userId ?? '0') ?? 0;
    final agendamentoBloc = context.read<AgendamentoBloc>();

    final nextPage = reset ? 0 : agendamentoBloc.state.currentPage + 1;

    agendamentoBloc.add(
      GetHistoricoRequested(
        usuarioId: usuarioId,
        page: nextPage,
        dataInicio: _dataInicio != null ? DateFormat('yyyy-MM-dd').format(_dataInicio!) : null,
        dataFim: _dataFim != null ? DateFormat('yyyy-MM-dd').format(_dataFim!) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
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
              _buscar(reset: true);
            },
            onClear: () {
              setState(() {
                _dataInicio = null;
                _dataFim = null;
              });
              _buscar(reset: true);
            },
          ),
          Expanded(child: _buildLista()),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return BlocBuilder<AgendamentoBloc, AgendamentoState>(
      builder: (context, state) {
        if (state.status == AgendamentoStatus.loading && state.historico.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.historico.isEmpty && state.status != AgendamentoStatus.loading) {
          return const Center(child: Text('Nenhum registro encontrado no período.'));
        }

        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: state.hasReachedMax ? state.historico.length : state.historico.length + 1,
          separatorBuilder: (_,_) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index >= state.historico.length) {
              return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
            }

            final item = state.historico[index];
            final nomesServicos = item.servicos.map((s) => s.nome).join(", ");

            return Card(
              child: ListTile(
                title: Text('Dia ${item.data.toDate(formatoSaida: "dd/MM/yyyy")} às ${item.horario}'),
                subtitle: Text('Serviços: $nomesServicos'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDetalhes(item),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetalhes(AgendamentoModel agendamento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detalhes do Agendamento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Status: ${agendamento.status}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Data: ${agendamento.data.toDate(formatoSaida: "dd/MM/yyyy")}'),
            Text('Hora: ${agendamento.horario}'),
            const Divider(height: 32),
            const Text('Serviços:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...agendamento.servicos.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('- ${s.nome} (R\$ ${s.valor.toStringAsFixed(2)})'),
            )),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('FECHAR'))),
          ],
        ),
      ),
    );
  }
}
