import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_mobile/features/agendamento/data/models/agendamento_model.dart';
import '../../../../core/extensions/string.dart';

class AgendametnoPendenteCardWidget extends StatelessWidget {
  final AgendamentoModel item;
  final Function() callback;

  const AgendametnoPendenteCardWidget({
    super.key,
    required this.item,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text('Data: ${item.data.toDate(formatoSaida: "dd/MM/yyyy")} às ${item.horario}'),
        subtitle: Text('Tempo Est.: ${item.tempoTotalCalculado} min | Valor: R\$ ${item.valorTotalCalculado.toStringAsFixed(2)}'),
        onTap: () {
          // Passa o objeto e a flag readonly: false para permitir edição
          context.push('/agendamento-detalhe', extra: {
            'agendamento': item,
            'readonly': false,
          }).whenComplete(callback);
        },
      ),
    );
  }
}