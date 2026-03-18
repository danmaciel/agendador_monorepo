import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:projeto_mobile/core/logger/app_logger.dart';

import 'package:projeto_mobile/features/agendamento/data/models/dashboard_model.dart';
import 'package:projeto_mobile/features/agendamento/data/models/agendamento_model.dart';
import 'package:projeto_mobile/features/agendamento/data/repositories/agendamento_repository.dart';
import 'package:projeto_mobile/features/servico/data/models/servico_model.dart';
import 'agendamento_event.dart';
import 'agendamento_state.dart';

class AgendamentoBloc extends Bloc<AgendamentoEvent, AgendamentoState> {
  final AgendamentoRepository _repository;

  AgendamentoBloc(this._repository) : super(const AgendamentoState()) {
    on<GetMeusAgendamentosRequested>(_onGetMeusAgendamentosRequested);
    on<GetAgendamentosRequested>(_onGetAgendamentosRequested);
    on<GetAgendamentoByIdRequested>(_onGetAgendamentoByIdRequested);
    on<GetAgendamentosPendentesRequested>(_onGetAgendamentosPendentesRequested);
    on<GetHistoricoRequested>(_onGetHistoricoRequested);
    on<GetServicosRequested>(_onGetServicosRequested);
    on<CriarAgendamentoRequested>(_onCriarAgendamentoRequested);
    on<UnirAgendamentoRequested>(_onUnirAgendamentoRequested);
    on<ForcarAgendamentoRequested>(_onForcarAgendamentoRequested);
    on<AlterarAgendamentoRequested>(_onAlterarAgendamentoRequested);
    on<CriarServicoRequested>(_onCriarServicoRequested);
    on<EditarServicoRequested>(_onEditarServicoRequested);
    on<ExcluirServicoRequested>(_onExcluirServicoRequested);
    on<AprovarAgendamentoRequested>(_onAprovarAgendamentoRequested);
    on<RejeitarAgendamentoRequested>(_onRejeitarAgendamentoRequested);
    on<GetDashboardRequested>(_onGetDashboardRequested);
    on<ToggleServicoStatusRequested>(_onToggleServicoStatusRequested);
  }

  Future<void> _onGetMeusAgendamentosRequested(
    GetMeusAgendamentosRequested event,
    Emitter<AgendamentoState> emit,
  ) async {
    emit(state.copyWith(status: AgendamentoStatus.loading, agendamentos: []));
    try {
      final items = await _repository.getMeusAgendamentos(
        usuarioId: event.usuarioId,
        page: event.page,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
      );
      emit(state.copyWith(status: AgendamentoStatus.success, agendamentos: items));
    } catch (e) {
      AppLogger.e('Erro ao carregar agendamentos atuais', e);
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetAgendamentosRequested(
    GetAgendamentosRequested event,
    Emitter<AgendamentoState> emit,
  ) async {
    emit(state.copyWith(status: AgendamentoStatus.loading, agendamentos: []));
    try {
      final items = await _repository.getAgendamentos(
        page: event.page,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
        size: event.size,
        sortBy: event.sortBy,
        sortDir: event.sortDir,
      );
      emit(state.copyWith(status: AgendamentoStatus.success, agendamentos: items));
    } catch (e) {
      AppLogger.e('Erro ao listar agendamentos', e);
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetAgendamentoByIdRequested(
    GetAgendamentoByIdRequested event,
    Emitter<AgendamentoState> emit,
  ) async {
    emit(state.copyWith(status: AgendamentoStatus.loading));
    try {
      final item = await _repository.getAgendamentoById(event.id);
      // Atualiza o item na lista se ele existir para manter a UI sincronizada
      final novosAgendamentos = state.agendamentos.map((a) => a.id == item.id ? item : a).toList();
      emit(state.copyWith(status: AgendamentoStatus.success, agendamentos: novosAgendamentos));
    } catch (e) {
      AppLogger.e('Erro ao buscar agendamento por ID', e);
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetAgendamentosPendentesRequested(
    GetAgendamentosPendentesRequested event,
    Emitter<AgendamentoState> emit,
  ) async {
    final isFirstPage = event.page == 0;
    if (isFirstPage) {
      emit(state.copyWith(status: AgendamentoStatus.loading, pendentes: [], pendentesPage: 0, hasReachedMaxPendentes: false));
    } else if (state.hasReachedMaxPendentes) {
      return;
    }

    try {
      final newItems = await _repository.getAgendamentosPendentes(page: event.page);
      emit(state.copyWith(
        status: AgendamentoStatus.success,
        pendentes: isFirstPage ? newItems : [...state.pendentes, ...newItems],
        pendentesPage: event.page,
        hasReachedMaxPendentes: newItems.isEmpty || newItems.length < 10,
      ));
    } catch (e) {
      AppLogger.e('Erro ao carregar pendências', e);
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetHistoricoRequested(GetHistoricoRequested event, Emitter<AgendamentoState> emit) async {
    final isFirstPage = event.page == 0;
    if (isFirstPage) {
      emit(state.copyWith(status: AgendamentoStatus.loading, historico: [], currentPage: 0, hasReachedMax: false));
    } else if (state.hasReachedMax) {
      return;
    }
    try {
      final newItems = await _repository.getHistorico(usuarioId: event.usuarioId, page: event.page, dataInicio: event.dataInicio, dataFim: event.dataFim);
      emit(state.copyWith(
        status: AgendamentoStatus.success,
        historico: isFirstPage ? newItems : [...state.historico, ...newItems],
        currentPage: event.page,
        hasReachedMax: newItems.isEmpty || newItems.length < 10,
      ));
    } catch (e) {
      AppLogger.e('Erro ao carregar histórico', e);
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetServicosRequested(GetServicosRequested event, Emitter<AgendamentoState> emit) async {
    final isFirstPage = event.page == 0;
    if (isFirstPage) {
      emit(state.copyWith(status: AgendamentoStatus.loading, servicos: [], servicosPage: 0, hasReachedMaxServicos: false));
    } else if (state.hasReachedMaxServicos) {
      return;
    }
    try {
      final newServicos = await _repository.getServicos(page: event.page);
      emit(state.copyWith(
        status: AgendamentoStatus.success,
        servicos: isFirstPage ? newServicos : [...state.servicos, ...newServicos],
        servicosPage: event.page,
        hasReachedMaxServicos: newServicos.isEmpty || newServicos.length < 10,
      ));
    } catch (e) {
      AppLogger.e('Erro ao carregar serviços', e);
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCriarAgendamentoRequested(CriarAgendamentoRequested event, Emitter<AgendamentoState> emit) async {
    emit(state.copyWith(status: AgendamentoStatus.loading, sugestaoData: null));
    try {
      await _repository.criarAgendamento(usuarioId: event.usuarioId, servicosIds: event.servicosIds, dataHora: event.dataHora);
      emit(state.copyWith(status: AgendamentoStatus.creationSuccess));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409 || e.response?.statusCode == 422) {
        final sugestao = e.response?.data['dataSugerida'] ?? e.response?.data['sugestaoData'];
        emit(state.copyWith(status: AgendamentoStatus.error, sugestaoData: sugestao, errorMessage: e.response?.data['message']));
      } else {
        emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.response?.data['message'] ?? e.toString()));
      }
    } catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAprovarAgendamentoRequested(AprovarAgendamentoRequested event, Emitter<AgendamentoState> emit) async {
    emit(state.copyWith(status: AgendamentoStatus.loading));
    try {
      await _repository.aprovarAgendamento(event.agendamentoId, event.servicosAprovadosIds);
      emit(state.copyWith(status: AgendamentoStatus.creationSuccess));
    } catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onRejeitarAgendamentoRequested(RejeitarAgendamentoRequested event, Emitter<AgendamentoState> emit) async {
    emit(state.copyWith(status: AgendamentoStatus.loading));
    try {
      await _repository.rejeitarAgendamento(event.agendamentoId);
      emit(state.copyWith(status: AgendamentoStatus.creationSuccess));
    } catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUnirAgendamentoRequested(UnirAgendamentoRequested event, Emitter<AgendamentoState> emit) async {
    emit(state.copyWith(status: AgendamentoStatus.loading));
    try {
      await _repository.unirAgendamento(usuarioId: event.usuarioId, servicosIds: event.servicosIds, dataSugerida: event.dataSugerida);
      emit(state.copyWith(status: AgendamentoStatus.creationSuccess));
    } catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onForcarAgendamentoRequested(ForcarAgendamentoRequested event, Emitter<AgendamentoState> emit) async {
    emit(state.copyWith(status: AgendamentoStatus.loading));
    try {
      await _repository.forcarAgendamento(usuarioId: event.usuarioId, servicosIds: event.servicosIds, dataHora: event.dataHora);
      emit(state.copyWith(status: AgendamentoStatus.creationSuccess));
    } catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAlterarAgendamentoRequested(AlterarAgendamentoRequested event, Emitter<AgendamentoState> emit) async {
    emit(state.copyWith(status: AgendamentoStatus.loading));
    try {
      await _repository.alterarAgendamento(
        usuarioId: event.usuarioId, 
        agendamentoId: event.agendamentoId, 
        servicosIds: event.servicosIds, 
        dataHora: event.dataHora
      );
      emit(state.copyWith(status: AgendamentoStatus.creationSuccess));
    } on DioException catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.response?.data['message'] ?? 'Erro ao alterar.'));
    } catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCriarServicoRequested(CriarServicoRequested event, Emitter<AgendamentoState> emit) async {
    emit(state.copyWith(status: AgendamentoStatus.loading));
    try {
      await _repository.criarServico(event.servico);
      emit(state.copyWith(status: AgendamentoStatus.creationSuccess));
      add(const GetServicosRequested(page: 0));
    } catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onEditarServicoRequested(EditarServicoRequested event, Emitter<AgendamentoState> emit) async {
    emit(state.copyWith(status: AgendamentoStatus.loading));
    try {
      await _repository.editarServico(event.servico);
      emit(state.copyWith(status: AgendamentoStatus.creationSuccess));
      add(const GetServicosRequested(page: 0));
    } catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onExcluirServicoRequested(ExcluirServicoRequested event, Emitter<AgendamentoState> emit) async {
    emit(state.copyWith(status: AgendamentoStatus.loading));
    try {
      await _repository.excluirServico(event.id);
      emit(state.copyWith(status: AgendamentoStatus.creationSuccess));
      add(const GetServicosRequested(page: 0));
    } catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetDashboardRequested(GetDashboardRequested event, Emitter<AgendamentoState> emit) async {
    emit(state.copyWith(status: AgendamentoStatus.loading));
    try {
      final data = await _repository.getRelatorioDashboard(
        dataInicio: event.dataInicio ?? '',
        dataFim: event.dataFim ?? '',
      );

      final dashboard = DashboardModel.fromJson(data);

      emit(state.copyWith(
        status: AgendamentoStatus.success, 
        dashboard: dashboard,
        agendamentos: dashboard.agendamentosHoje, 
      ));
    } catch (e) {
      AppLogger.e('Erro ao carregar dashboard', e);
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleServicoStatusRequested(ToggleServicoStatusRequested event, Emitter<AgendamentoState> emit) async {
    try {
      await _repository.atualizarStatusServico(
        agendamentoId: event.agendamentoId,
        servicoId: event.servicoId,
        confirmado: event.confirmado,
      );
    } catch (e) {
      emit(state.copyWith(status: AgendamentoStatus.error, errorMessage: e.toString()));
    }
  }
}
