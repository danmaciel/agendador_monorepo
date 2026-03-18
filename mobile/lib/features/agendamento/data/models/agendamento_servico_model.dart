import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:projeto_mobile/features/servico/data/models/servico_model.dart';

part 'agendamento_servico_model.g.dart';

@JsonSerializable()
class AgendamentoServicoModel extends Equatable {
  final ServicoModel servico;
  final bool confirmado;

  const AgendamentoServicoModel({
    required this.servico,
    this.confirmado = true,
  });

  factory AgendamentoServicoModel.fromJson(Map<String, dynamic> json) => _$AgendamentoServicoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoServicoModelToJson(this);

  AgendamentoServicoModel copyWith({
    ServicoModel? servico,
    bool? confirmado,
  }) {
    return AgendamentoServicoModel(
      servico: servico ?? this.servico,
      confirmado: confirmado ?? this.confirmado,
    );
  }

  @override
  List<Object?> get props => [servico, confirmado];
}
