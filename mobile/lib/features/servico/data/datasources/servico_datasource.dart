import 'package:dio/dio.dart';
import '../models/servico_model.dart';
import 'package:projeto_mobile/core/logger/app_logger.dart';

class ServicoDataSource {
  final Dio _dio;

  ServicoDataSource(this._dio);

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

  Future<void> criarServico(ServicoModel servico) async {
    try {
      await _dio.post('/api/v1/servico', data: servico.toJson());
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Erro ao criar serviço';
      AppLogger.e(errorMessage, e);
      throw Exception(errorMessage);
    }
  }

  Future<void> editarServico(ServicoModel servico) async {
    try {
      await _dio.put('/api/v1/servico/${servico.id}', data: servico.toJson());
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Erro ao editar serviço';
      AppLogger.e(errorMessage, e);
      throw Exception(errorMessage);
    }
  }

  Future<void> excluirServico(int id) async {
    try {
      await _dio.delete('/api/v1/servico/$id');
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Erro ao excluir serviço';
      AppLogger.e(errorMessage, e);
      throw Exception(errorMessage);
    }
  }
}
