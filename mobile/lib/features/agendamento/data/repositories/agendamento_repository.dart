import '../datasources/agendamento_datasource.dart';
import '../../../servico/data/datasources/servico_datasource.dart';
import '../models/agendamento_model.dart';
import '../../../servico/data/models/servico_model.dart';

class AgendamentoRepository {
  final AgendamentoDataSource _dataSource;
  final ServicoDataSource _servicoDataSource;

  AgendamentoRepository(this._dataSource, this._servicoDataSource);

  Future<AgendamentoModel> getAgendamentoById(int id) => _dataSource.getAgendamentoById(id);

  Future<List<AgendamentoModel>> getMeusAgendamentos({
    required int usuarioId,
    String? dataInicio,
    String? dataFim,
    int page = 0,
  }) async {
    return await _dataSource.getMeusAgendamentos(
      usuarioId: usuarioId,
      dataInicio: dataInicio,
      dataFim: dataFim,
      page: page,
    );
  }

  Future<List<AgendamentoModel>> getAgendamentos({
    String? dataInicio,
    String? dataFim,
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDir
  }) async {
    return await _dataSource.getAgendamentos(
      dataInicio: dataInicio,
      dataFim: dataFim,
      page: page,
      size: 10,
      sortBy: sortBy,
      sortDir: sortDir,
    );
  }

  Future<List<AgendamentoModel>> getAgendamentosPendentes({
    int page = 0,
  }) async {
    return await _dataSource.getAgendamentosPendentes(
      page: page,
    );
  }

  Future<List<AgendamentoModel>> getHistorico({
    required int usuarioId,
    String? dataInicio,
    String? dataFim,
    int page = 0,
  }) async {
    return await _dataSource.getHistorico(
      usuarioId: usuarioId,
      dataInicio: dataInicio,
      dataFim: dataFim,
      page: page,
    );
  }

  Future<List<ServicoModel>> getServicos({int page = 0}) async {
    return await _servicoDataSource.getServicos(page: page);
  }

  Future<void> criarAgendamento({
    required int usuarioId,
    required List<int> servicosIds,
    required String dataHora,
  }) async {
    await _dataSource.criarAgendamento(
      usuarioId: usuarioId,
      servicosIds: servicosIds,
      dataHora: dataHora,
    );
  }

  Future<void> unirAgendamento({
    required int usuarioId,
    required List<int> servicosIds,
    required String dataSugerida,
  }) async {
    await _dataSource.unirAgendamento(
      usuarioId: usuarioId,
      servicosIds: servicosIds,
      dataSugerida: dataSugerida,
    );
  }

  Future<void> forcarAgendamento({
    required int usuarioId,
    required List<int> servicosIds,
    required String dataHora,
  }) async {
    await _dataSource.forcarAgendamento(
      usuarioId: usuarioId,
      servicosIds: servicosIds,
      dataHora: dataHora,
    );
  }

  Future<void> alterarAgendamento({
    required int usuarioId,
    required int agendamentoId,
    required List<int> servicosIds,
    required String dataHora,
  }) async {
    await _dataSource.alterarAgendamento(
      usuarioId: usuarioId,
      agendamentoId: agendamentoId,
      servicosIds: servicosIds,
      dataHora: dataHora,
    );
  }

  Future<void> aprovarAgendamento(int id, List<int> servicosAprovados) =>
      _dataSource.aprovarAgendamento(id, servicosAprovados);

  Future<void> rejeitarAgendamento(int id) => _dataSource.rejeitarAgendamento(id);

  // Métodos de Gestão de Serviços (Admin)
  Future<void> criarServico(ServicoModel servico) => _servicoDataSource.criarServico(servico);
  Future<void> editarServico(ServicoModel servico) => _servicoDataSource.editarServico(servico);
  Future<void> excluirServico(int id) => _servicoDataSource.excluirServico(id);

  Future<Map<String, dynamic>> getRelatorioDashboard({
    required String dataInicio,
    required String dataFim,
  }) => _dataSource.getRelatorioDashboard(
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
  
  Future<void> atualizarStatusServico({
    required int agendamentoId,
    required int servicoId,
    required bool confirmado,
  }) => _dataSource.atualizarStatusServico(
        agendamentoId: agendamentoId,
        servicoId: servicoId,
        confirmado: confirmado,
      );
}
