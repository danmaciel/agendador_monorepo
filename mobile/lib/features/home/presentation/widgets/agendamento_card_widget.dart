import 'package:flutter/material.dart';
import 'package:projeto_mobile/core/extensions/string.dart';
import 'package:projeto_mobile/core/util/agendamento_status_color.dart';
import 'package:projeto_mobile/features/agendamento/data/models/agendamento_model.dart';

class AgendamentoCardWidget extends StatelessWidget {
  final AgendamentoModel item;
  final VoidCallback onEdit;
  final VoidCallback onBlock;

  const AgendamentoCardWidget({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final nomesServicos = item.servicos.map((s) => s.nome).join(", ");

    final dataAgendamento = item.data.toDateTime();
    final podeAlterar = dataAgendamento != null &&
        dataAgendamento.difference(DateTime.now()).inDays >= 2;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        isThreeLine: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dia ${item.data.toDate(formatoSaida: "dd/MM/yyyy")}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Horário: ${item.horario}',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Serviços: $nomesServicos',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AgendamentoStatusBadge.getBadge(item.status),
              if (item.status.toUpperCase() == 'PENDENTE')
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: podeAlterar ? onEdit : onBlock,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.edit,
                          size: 22,
                          color: podeAlterar ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
