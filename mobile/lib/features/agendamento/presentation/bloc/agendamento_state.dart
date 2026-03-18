import 'package:equatable/equatable.dart';
import '../../data/models/agendamento_model.dart';
import '../../../servico/data/models/servico_model.dart';
import '../../data/models/dashboard_model.dart';

enum AgendamentoStatus { initial, loading, success, error, creationSuccess }

class AgendamentoState extends Equatable {
  final AgendamentoStatus status;
  final List<AgendamentoModel> agendamentos;
  final List<AgendamentoModel> historico;
  final List<AgendamentoModel> pendentes;
  final List<ServicoModel> servicos;
  final DashboardModel? dashboard;
  final AgendamentoModel? agendamentoDetalhe; // CAMPO PARA ATUALIZAÇÃO DA TELA DE DETALHES
  final String? errorMessage;
  final String? sugestaoData;
  
  final int currentPage;
  final bool hasReachedMax;
  final int servicosPage;
  final bool hasReachedMaxServicos;
  final int pendentesPage;
  final bool hasReachedMaxPendentes;

  const AgendamentoState({
    this.status = AgendamentoStatus.initial,
    this.agendamentos = const [],
    this.historico = const [],
    this.pendentes = const [],
    this.servicos = const [],
    this.dashboard,
    this.agendamentoDetalhe,
    this.errorMessage,
    this.sugestaoData,
    this.currentPage = 0,
    this.hasReachedMax = false,
    this.servicosPage = 0,
    this.hasReachedMaxServicos = false,
    this.pendentesPage = 0,
    this.hasReachedMaxPendentes = false,
  });

  AgendamentoState copyWith({
    AgendamentoStatus? status,
    List<AgendamentoModel>? agendamentos,
    List<AgendamentoModel>? historico,
    List<AgendamentoModel>? pendentes,
    List<ServicoModel>? servicos,
    DashboardModel? dashboard,
    AgendamentoModel? agendamentoDetalhe,
    String? errorMessage,
    String? sugestaoData,
    int? currentPage,
    bool? hasReachedMax,
    int? servicosPage,
    bool? hasReachedMaxServicos,
    int? pendentesPage,
    bool? hasReachedMaxPendentes,
  }) {
    return AgendamentoState(
      status: status ?? this.status,
      agendamentos: agendamentos ?? this.agendamentos,
      historico: historico ?? this.historico,
      pendentes: pendentes ?? this.pendentes,
      servicos: servicos ?? this.servicos,
      dashboard: dashboard ?? this.dashboard,
      agendamentoDetalhe: agendamentoDetalhe ?? this.agendamentoDetalhe,
      errorMessage: errorMessage ?? this.errorMessage,
      sugestaoData: sugestaoData ?? this.sugestaoData,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      servicosPage: servicosPage ?? this.servicosPage,
      hasReachedMaxServicos: hasReachedMaxServicos ?? this.hasReachedMaxServicos,
      pendentesPage: pendentesPage ?? this.pendentesPage,
      hasReachedMaxPendentes: hasReachedMaxPendentes ?? this.hasReachedMaxPendentes,
    );
  }

  @override
  List<Object?> get props => [
        status,
        agendamentos,
        historico,
        pendentes,
        servicos,
        dashboard,
        agendamentoDetalhe,
        errorMessage,
        sugestaoData,
        currentPage,
        hasReachedMax,
        servicosPage,
        hasReachedMaxServicos,
        pendentesPage,
        hasReachedMaxPendentes,
      ];
}
