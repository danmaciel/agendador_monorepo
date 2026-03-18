import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_mobile/core/widget/snackbar_message.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_bloc.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_event.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_state.dart';
import 'package:projeto_mobile/features/servico/data/models/servico_model.dart';
import '../widget/servicos_admin_card_widget.dart';

class ServicosAdminPage extends StatefulWidget {
  const ServicosAdminPage({super.key});

  @override
  State<ServicosAdminPage> createState() => _ServicosAdminPageState();
}

class _ServicosAdminPageState extends State<ServicosAdminPage> {
  @override
  void initState() {
    super.initState();
    _loadServicos();
  }

  void _loadServicos() {
    context.read<AgendamentoBloc>().add(const GetServicosRequested(page: 0));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AgendamentoBloc, AgendamentoState>(
      listenWhen: (previous, current) => 
          current.status == AgendamentoStatus.creationSuccess || current.status == AgendamentoStatus.error,
      listener: (context, state) {
        if (state.status == AgendamentoStatus.creationSuccess) {
          SnackbarMessage.sucesso(context, 'Operação realizada com sucesso!');
        } else if (state.status == AgendamentoStatus.error) {
          SnackbarMessage.erro(context, state.errorMessage ?? 'Erro ao realizar operação');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestão de Serviços'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showServicoDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<AgendamentoBloc, AgendamentoState>(
          builder: (context, state) {
            if (state.status == AgendamentoStatus.loading && state.servicos.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.servicos.isEmpty && state.status != AgendamentoStatus.loading) {
              return const Center(child: Text('Nenhum serviço cadastrado.'));
            }

            return RefreshIndicator(
              onRefresh: () async => _loadServicos(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_,_) => const SizedBox(height: 12),
                itemCount: state.servicos.length,
                itemBuilder: (context, index) {
                  final servico = state.servicos[index];
                  return ServicosAdminCardWidget(
                    servico: servico,
                    chamarDialog: () => _showServicoDialog(context, servico: servico),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showServicoDialog(BuildContext context, {ServicoModel? servico}) {
    final nomeController = TextEditingController(text: servico?.nome);
    final valorController = TextEditingController(text: servico?.valor.toString());
    final tempoController = TextEditingController(text: servico?.tempoExecucao.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(servico == null ? 'Novo Serviço' : 'Editar Serviço'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Serviço',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tempoController,
                decoration: const InputDecoration(
                  labelText: 'Tempo de Execução (min)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final novoServico = ServicoModel(
                id: servico?.id ?? 0,
                nome: nomeController.text,
                valor: double.tryParse(valorController.text) ?? 0.0,
                tempoExecucao: int.tryParse(tempoController.text) ?? 0,
              );

              if (servico == null) {
                context.read<AgendamentoBloc>().add(CriarServicoRequested(novoServico));
              } else {
                context.read<AgendamentoBloc>().add(EditarServicoRequested(novoServico));
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );
  }
}
