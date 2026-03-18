import 'package:equatable/equatable.dart';
import 'agendamento_model.dart';

class DashboardModel extends Equatable {
  final int aprovados;
  final int rejeitados;
  final int pendentes;
  final Map<String, int> agendamentosPorDia;
  final List<AgendamentoModel> agendamentosHoje;

  const DashboardModel({
    required this.aprovados,
    required this.rejeitados,
    required this.pendentes,
    required this.agendamentosPorDia,
    required this.agendamentosHoje,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      aprovados: json['aprovados'] ?? 0,
      rejeitados: json['rejeitados'] ?? 0,
      pendentes: json['pendentes'] ?? 0,
      agendamentosPorDia: Map<String, int>.from(json['agendamentosPorDia'] ?? {}),
      agendamentosHoje: (json['agendamentosHoje'] as List? ?? [])
          .map((item) => AgendamentoModel.fromJson(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [aprovados, rejeitados, pendentes, agendamentosPorDia, agendamentosHoje];
}
