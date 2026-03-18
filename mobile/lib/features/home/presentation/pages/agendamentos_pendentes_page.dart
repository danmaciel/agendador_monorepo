import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_bloc.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_event.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_state.dart';
import 'package:projeto_mobile/features/agendamento/presentation/widgets/agendamento_pendente_card_widget.dart';

class AgendamentosPendentesPage extends StatefulWidget {
  const AgendamentosPendentesPage({super.key});

  @override
  State<AgendamentosPendentesPage> createState() => _AgendamentosPendentesPageState();
}

class _AgendamentosPendentesPageState extends State<AgendamentosPendentesPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchPendentes(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<AgendamentoBloc>().state;
      if (!state.hasReachedMaxPendentes && state.status != AgendamentoStatus.loading) {
        _fetchPendentes(reset: false);
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _fetchPendentes({bool reset = false}) {
    final agendamentoBloc = context.read<AgendamentoBloc>();
    final nextPage = reset ? 0 : agendamentoBloc.state.pendentesPage + 1;
    
    agendamentoBloc.add(GetAgendamentosPendentesRequested(page: nextPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitações Pendentes')),
      body: BlocBuilder<AgendamentoBloc, AgendamentoState>(
        builder: (context, state) {
          if (state.status == AgendamentoStatus.loading && state.pendentes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.pendentes.isEmpty) {
            return const Center(child: Text('Nenhum agendamento pendente.'));
          }

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.hasReachedMaxPendentes ? state.pendentes.length : state.pendentes.length + 1,
            separatorBuilder: (_,_) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index >= state.pendentes.length) {
                return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
              }

              final item = state.pendentes[index];
              return AgendametnoPendenteCardWidget(item: item, callback: () =>  _fetchPendentes(reset: true));
            },
          );
        },
      ),
    );
  }
}
