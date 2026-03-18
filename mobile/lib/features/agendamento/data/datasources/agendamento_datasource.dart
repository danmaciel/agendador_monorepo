import 'package:dio/dio.dart';
import 'package:projeto_mobile/core/extensions/string.dart';
import '../models/agendamento_model.dart';
import '../../../servico/data/models/servico_model.dart';
import 'package:projeto_mobile/core/logger/app_logger.dart';

class AgendamentoDataSource {
  final Dio _dio;

  AgendamentoDataSource(this._dio);

  Future<AgendamentoModel> getAgendamentoById(int id) async {
    try {
      final response = await _dio.get('/api/v1/agendamento/$id');
      return AgendamentoModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Erro ao buscar agendamento';
      AppLogger.e(errorMessage, e);
      throw Exception(errorMessage);
    }
  }

  Future<List<AgendamentoModel>> getAgendamentos({
      String? dataInicio,
      String? dataFim,
      int page = 0,
      int size = 10,
      String? sortBy = 'id',
      String? sortDir = 'asc',
    }) async {
    try {
      final response = await _dio.get(
        '/api/v1/agendamento',
        queryParameters: {
          'dataInicio': dataInicio,
          'dataFim': dataFim,
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDir': sortDir
        },
      );
      final List<dynamic> content = response.data['content'] ?? [];
      return content.map((json) => AgendamentoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Erro ao listar agendamentos';
      AppLogger.e(errorMessage, e);
      throw Exception(errorMessage);
    }
  }

  Future<List<AgendamentoModel>> getMeusAgendamentos({
    required int usuarioId,
    String? dataInicio,
    String? dataFim,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/agendamento/meus-agendamentos',
        queryParameters: {
          'usuarioId': usuarioId,
          'dataInicio': dataInicio,
          'dataFim': dataFim,
          'page': page,
          'size': size,
        },
      );
      final List<dynamic> content = response.data['content'] ?? [];
      return content.map((json) => AgendamentoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Erro ao buscar agendamentos ativos';
      AppLogger.e(errorMessage, e);
      throw Exception(errorMessage);
    }
  }

  Future<List<AgendamentoModel>> getAgendamentosPendentes({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/agendamento/pendentes',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      final List<dynamic> content = response.data['content'] ?? [];
      return content.map((json) => AgendamentoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Erro ao buscar pendências';
      AppLogger.e(errorMessage, e);
      throw Exception(errorMessage);
    }
  }

  Future<List<AgendamentoModel>> getHistorico({
    required int usuarioId,
    String? dataInicio,
    String? dataFim,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/agendamento/historico', 
        queryParameters: {
          'usuarioId': usuarioId,
          'dataInicio': dataInicio,
          'dataFim': dataFim,
          'page': page,
          'size': size,
        },
      );
      final List<dynamic> content = response.data['content'] ?? [];
      return content.map((json) => AgendamentoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Erro ao buscar histórico';
      AppLogger.e(errorMessage, e);
      throw Exception(errorMessage);
    }
  }

  Future<List<ServicoModel>> getServicos({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/servico',
        queryParameters: {'page': page, 'size': size},
      );
      final List<dynamic> content = response.data['content'] ?? [];
      return content.map((json) => ServicoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      AppLogger.e('Erro ao buscar serviços', e);
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar serviços');
    }
  }

  Future<void> criarAgendamento({
    required int usuarioId,
    required List<int> servicosIds,
    required String dataHora,
  }) async {
    try {
      await _dio.post(
        '/api/v1/agendamento',
        data: {
          'usuarioId': usuarioId,
          'servicoIds': servicosIds,
          'data': dataHora.toDate(formatoSaida: "yyyy-MM-dd"),
          'horario': dataHora.toTime(),
        },
      );
    } on DioException catch (_) {
      rethrow; 
    }
  }

  Future<void> unirAgendamento({
    required int usuarioId,
    required List<int> servicosIds,
    required String dataSugerida,
  }) async {
    try {
      await _dio.post(
        '/api/v1/agendamento/aceitar-data-sugestao',
        data: {
          'usuarioId': usuarioId,
          'servicoIds': servicosIds,
          'data': dataSugerida.toDate(formatoSaida: "yyyy-MM-dd"),
          'horario': dataSugerida.toTime(),
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao unir agendamentos');
    }
  }

  Future<void> forcarAgendamento({
    required int usuarioId,
    required List<int> servicosIds,
    required String dataHora,
  }) async {
    try {
      await _dio.post(
        '/api/v1/agendamento/criar-forcado',
        data: {
          'usuarioId': usuarioId,
          'servicoIds': servicosIds,
          'data': dataHora.toDate(formatoSaida: "yyyy-MM-dd"),
          'horario': dataHora.toTime(),
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao forçar agendamento');
    }
  }

  Future<void> alterarAgendamento({
    required int usuarioId,
    required int agendamentoId,
    required List<int> servicosIds,
    required String dataHora,
  }) async {
    try {
      await _dio.put(
        '/api/v1/agendamento/$agendamentoId',
        data: {
          'usuarioId': usuarioId,
          'servicoIds': servicosIds,
          'data': dataHora.toDate(formatoSaida: "yyyy-MM-dd"),
          'horario': dataHora.toTime(),
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao alterar agendamento');
    }
  }

  Future<void> aprovarAgendamento(int id, List<int> servicosAprovados) async {
    try {
      await _dio.patch(
        '/api/v1/agendamento/$id/aprovar',
        data: {'servicosAprovados': servicosAprovados},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao aprovar');
    }
  }

  Future<void> rejeitarAgendamento(int id) async {
    try {
      await _dio.patch('/api/v1/agendamento/$id/rejeitar');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao rejeitar');
    }
  }

  Future<Map<String, dynamic>> getRelatorioDashboard({
    required String dataInicio,
    required String dataFim,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/agendamento/relatorio',
        queryParameters: {
          'dataInicio': dataInicio,
          'dataFim': dataFim,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao carregar relatório');
    }
  }

  Future<void> atualizarStatusServico({
    required int agendamentoId,
    required int servicoId,
    required bool confirmado,
  }) async {
    try {
      await _dio.patch(
        '/api/v1/agendamento/$agendamentoId/servico/$servicoId',
        queryParameters: {'confirmado': confirmado},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao atualizar serviço');
    }
  }
}
