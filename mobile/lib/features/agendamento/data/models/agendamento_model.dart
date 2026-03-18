import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../servico/data/models/servico_model.dart';

part 'agendamento_model.g.dart';

@JsonSerializable()
class AgendamentoModel extends Equatable {
  final int id;
  final int usuarioId;
  final String? nomeUsuario;
  final List<ServicoModel> servicos;
  final String data;
  final String? horario;
  final String status;
  final int? tempoTotal;

  const AgendamentoModel({
    required this.id,
    required this.usuarioId,
    this.nomeUsuario,
    required this.servicos,
    required this.data,
    this.horario,
    required this.status,
    this.tempoTotal,
  });

  factory AgendamentoModel.fromJson(Map<String, dynamic> json) => _$AgendamentoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoModelToJson(this);

  // Calcula o valor total dinamicamente (para o Admin poder desmarcar serviços)
  double get valorTotalCalculado {
    return servicos
        .where((s) => s.confirmado)
        .fold(0.0, (total, s) => total + s.valor);
  }

  // Calcula o tempo total dinamicamente (para o Admin poder desmarcar serviços)
  int get tempoTotalCalculado {
    return servicos
        .where((s) => s.confirmado)
        .fold(0, (total, s) => total + s.tempoExecucao);
  }

  @override
  List<Object?> get props => [id, usuarioId, nomeUsuario, servicos, data, horario, status, tempoTotal];
}
