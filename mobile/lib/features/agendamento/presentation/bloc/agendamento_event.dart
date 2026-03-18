import 'package:equatable/equatable.dart';
import '../../../servico/data/models/servico_model.dart';

abstract class AgendamentoEvent extends Equatable {
  const AgendamentoEvent();

  @override
  List<Object?> get props => [];
}

class GetMeusAgendamentosRequested extends AgendamentoEvent {
  final int usuarioId;
  final int page;
  final String? dataInicio;
  final String? dataFim;

  const GetMeusAgendamentosRequested({
    required this.usuarioId,
    this.page = 0,
    this.dataInicio,
    this.dataFim,
  });

  @override
  List<Object?> get props => [usuarioId, page, dataInicio, dataFim];
}

class GetAgendamentosRequested extends AgendamentoEvent {
  final String? dataInicio;
  final String? dataFim;
  final int page;
  final int size;
  final String? sortBy;
  final String? sortDir;

  const GetAgendamentosRequested({
    this.dataInicio,
    this.dataFim,
    this.page = 0,
    this.size = 10,
    this.sortBy = "id",
    this.sortDir = "asc",
  });

  @override
  List<Object?> get props => [page, size, dataInicio, dataFim, sortBy, sortDir];
}

class GetAgendamentoByIdRequested extends AgendamentoEvent {
  final int id;
  const GetAgendamentoByIdRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class GetAgendamentosPendentesRequested extends AgendamentoEvent {
  final int page;
  const GetAgendamentosPendentesRequested({this.page = 0});
  @override
  List<Object?> get props => [page];
}

class GetHistoricoRequested extends AgendamentoEvent {
  final int usuarioId;
  final int page;
  final String? dataInicio;
  final String? dataFim;

  const GetHistoricoRequested({
    required this.usuarioId,
    this.page = 0,
    this.dataInicio,
    this.dataFim,
  });

  @override
  List<Object?> get props => [usuarioId, page, dataInicio, dataFim];
}

class GetServicosRequested extends AgendamentoEvent {
  final int page;
  const GetServicosRequested({this.page = 0});

  @override
  List<Object?> get props => [page];
}

class CriarAgendamentoRequested extends AgendamentoEvent {
  final int usuarioId;
  final List<int> servicosIds;
  final String dataHora;

  const CriarAgendamentoRequested({
    required this.usuarioId,
    required this.servicosIds,
    required this.dataHora,
  });

  @override
  List<Object?> get props => [usuarioId, servicosIds, dataHora];
}

class UnirAgendamentoRequested extends AgendamentoEvent {
  final int usuarioId;
  final List<int> servicosIds;
  final String dataSugerida;

  const UnirAgendamentoRequested({
    required this.usuarioId,
    required this.servicosIds,
    required this.dataSugerida,
  });

  @override
  List<Object?> get props => [usuarioId, servicosIds, dataSugerida];
}

class ForcarAgendamentoRequested extends AgendamentoEvent {
  final int usuarioId;
  final List<int> servicosIds;
  final String dataHora;

  const ForcarAgendamentoRequested({
    required this.usuarioId,
    required this.servicosIds,
    required this.dataHora,
  });

  @override
  List<Object?> get props => [usuarioId, servicosIds, dataHora];
}

class AlterarAgendamentoRequested extends AgendamentoEvent {
  final int usuarioId;
  final int agendamentoId;
  final List<int> servicosIds;
  final String dataHora;

  const AlterarAgendamentoRequested({
    required this.usuarioId,
    required this.agendamentoId,
    required this.servicosIds,
    required this.dataHora,
  });

  @override
  List<Object?> get props => [usuarioId, agendamentoId, servicosIds, dataHora];
}

class AprovarAgendamentoRequested extends AgendamentoEvent {
  final int agendamentoId;
  final List<int> servicosAprovadosIds;

  const AprovarAgendamentoRequested({
    required this.agendamentoId,
    required this.servicosAprovadosIds,
  });

  @override
  List<Object?> get props => [agendamentoId, servicosAprovadosIds];
}

class RejeitarAgendamentoRequested extends AgendamentoEvent {
  final int agendamentoId;
  const RejeitarAgendamentoRequested(this.agendamentoId);
  @override
  List<Object?> get props => [agendamentoId];
}

class CriarServicoRequested extends AgendamentoEvent {
  final ServicoModel servico;
  const CriarServicoRequested(this.servico);
  @override
  List<Object?> get props => [servico];
}

class EditarServicoRequested extends AgendamentoEvent {
  final ServicoModel servico;
  const EditarServicoRequested(this.servico);
  @override
  List<Object?> get props => [servico];
}

class ExcluirServicoRequested extends AgendamentoEvent {
  final int id;
  const ExcluirServicoRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class GetDashboardRequested extends AgendamentoEvent {
  final String? dataInicio;
  final String? dataFim;

  const GetDashboardRequested({this.dataInicio, this.dataFim});

  @override
  List<Object?> get props => [dataInicio, dataFim];
}

class ToggleServicoStatusRequested extends AgendamentoEvent {
  final int agendamentoId;
  final int servicoId;
  final bool confirmado;

  const ToggleServicoStatusRequested({
    required this.agendamentoId,
    required this.servicoId,
    required this.confirmado,
  });

  @override
  List<Object?> get props => [agendamentoId, servicoId, confirmado];
}
