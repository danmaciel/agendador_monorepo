
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_bloc.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_event.dart';

import '../../data/models/servico_model.dart';

class ServicosAdminCardWidget extends StatelessWidget{
  final ServicoModel servico;
  final VoidCallback? chamarDialog;
  const ServicosAdminCardWidget({super.key, required this.servico, required this.chamarDialog});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(servico.nome),
        subtitle: Text(
            'R\$ ${servico.valor.toStringAsFixed(2)} - ${servico.tempoExecucao} min'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: chamarDialog
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmarExcluir(context, servico),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarExcluir(BuildContext context, ServicoModel servico) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: Text('Deseja realmente excluir o serviço "${servico.nome}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              context
                  .read<AgendamentoBloc>()
                  .add(ExcluirServicoRequested(servico.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
  }
}