import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'servico_model.g.dart';

@JsonSerializable()
class ServicoModel extends Equatable {
  final int id;
  final String nome;
  final String? descricao;
  final double valor;
  final int tempoExecucao;
  
  @JsonKey(defaultValue: true)
  final bool confirmado;

  const ServicoModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.valor,
    required this.tempoExecucao,
    this.confirmado = true,
  });

  factory ServicoModel.fromJson(Map<String, dynamic> json) => _$ServicoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServicoModelToJson(this);

  ServicoModel copyWith({bool? confirmado}) {
    return ServicoModel(
      id: id,
      nome: nome,
      descricao: descricao,
      valor: valor,
      tempoExecucao: tempoExecucao,
      confirmado: confirmado ?? this.confirmado,
    );
  }

  @override
  List<Object?> get props => [id, nome, descricao, valor, tempoExecucao, confirmado];
}
