
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_mobile/core/util/agendamento_status_color.dart';
import 'package:projeto_mobile/features/agendamento/data/models/agendamento_model.dart';


class AgendaDiariaWidget extends StatelessWidget{

  final List<AgendamentoModel> agendamentos;
  const AgendaDiariaWidget({super.key, required this.agendamentos});

  @override
  Widget build(BuildContext context) {
    if (agendamentos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text('Nenhum agendamento para hoje.')),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: agendamentos.length,
      separatorBuilder: (_,_) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = agendamentos[index];

        final Map<String, dynamic> agendamentoData = {
          'agendamento': item,
          'readonly': true,
        };

        return Card(
          child: ListTile(
            leading: AgendamentoStatusBadge.getBadge(item.status),
            title: Text(item.nomeUsuario ?? 'Cliente'),
            subtitle: Text('${item.horario} - ${item.servicos.length} serviços'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/agendamento-detalhe', extra: agendamentoData);
            },
          ),
        );
      },
    );
  }
}
