import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_mobile/core/extensions/string.dart';
import 'package:projeto_mobile/core/widget/snackbar_message.dart';
import 'package:intl/intl.dart';
import '../../../servico/data/models/servico_model.dart';
import '../../data/models/agendamento_model.dart';
import '../bloc/agendamento_bloc.dart';
import '../bloc/agendamento_event.dart';
import '../bloc/agendamento_state.dart';

class AdminAgendamentoDetalhePage extends StatefulWidget {
  final AgendamentoModel agendamento;
  final bool readonly;

  const AdminAgendamentoDetalhePage({
    super.key, 
    required this.agendamento,
    this.readonly = false,
  });

  @override
  State<AdminAgendamentoDetalhePage> createState() => _AdminAgendamentoDetalhePageState();
}

class _AdminAgendamentoDetalhePageState extends State<AdminAgendamentoDetalhePage> {
  late AgendamentoModel _currentAgendamento;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _currentAgendamento = widget.agendamento;
    _syncSelectorsWithAgendamento();
  }

  void _syncSelectorsWithAgendamento() {
    _selectedDate = _currentAgendamento.data.toDateTime() ?? DateTime.now();
    
    if (_currentAgendamento.horario != null && _currentAgendamento.horario!.contains(':')) {
      final parts = _currentAgendamento.horario!.split(':');
      if (parts.length >= 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    _selectedTime ??= const TimeOfDay(hour: 9, minute: 0);
  }

  bool get _podeAprovar => _currentAgendamento.servicos.any((s) => s.confirmado);

  bool get _dataHoraAlterada {
    if (_selectedDate == null || _selectedTime == null) return false;
    
    final dataOriginalStr = _currentAgendamento.data.toDate(formatoSaida: 'yyyy-MM-dd');
    final dataSelecionadaStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    
    final horaOriginalStr = _currentAgendamento.horario;
    final horaSelecionadaStr = "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

    return dataSelecionadaStr != dataOriginalStr || horaSelecionadaStr != horaOriginalStr;
  }

  String _getFormattedDateTime() {
    if (_selectedDate == null || _selectedTime == null) return '';
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    ).toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Agendamento')),
      body: BlocListener<AgendamentoBloc, AgendamentoState>(
        listener: (context, state) {
          if (state.status == AgendamentoStatus.error) {
            SnackbarMessage.erro(context, state.errorMessage ?? 'Erro na operação');
          }
          
          if (state.status == AgendamentoStatus.creationSuccess) {
             // Se o status ainda é PENDENTE, recarrega para refletir a nova data/hora
             if (_currentAgendamento.status == 'PENDENTE') {
                context.read<AgendamentoBloc>().add(GetAgendamentoByIdRequested(_currentAgendamento.id));
                SnackbarMessage.sucesso(context, 'Data e horário atualizados!');
                Navigator.pop(context);
             } else {
                // Se foi aprovação/rejeição, volta para a lista
                Navigator.pop(context);
             }
          }

          // Se a busca por ID teve sucesso, atualizamos o objeto local na tela
          if (state.status == AgendamentoStatus.success && state.agendamentos.any((a) => a.id == widget.agendamento.id)) {
            setState(() {
              _currentAgendamento = state.agendamentos.firstWhere((a) => a.id == widget.agendamento.id);
              _syncSelectorsWithAgendamento();
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const Divider(height: 32),
              if (!widget.readonly && _currentAgendamento.status == 'PENDENTE') ...[
                const Text('Alterar Data/Hora:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildDateTimePicker(),
                if (_dataHoraAlterada) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _salvarAlteracaoDataHora,
                      icon: const Icon(Icons.save),
                      label: const Text('SALVAR NOVO HORÁRIO'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                  ),
                ],
                const Divider(height: 32),
              ],
              const Text(
                'Serviços Solicitados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildServicosList(),
              const SizedBox(height: 24),
              _buildResumoFinanceiro(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  void _salvarAlteracaoDataHora() {
    final idsServicos = _currentAgendamento.servicos.map((s) => s.id).toList();
    context.read<AgendamentoBloc>().add(AlterarAgendamentoRequested(
      usuarioId: _currentAgendamento.usuarioId,
      agendamentoId: _currentAgendamento.id,
      servicosIds: idsServicos,
      dataHora: _getFormattedDateTime(),
    ));
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickDate(),
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(_selectedDate == null ? 'Data' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickTime(),
            icon: const Icon(Icons.access_time, size: 18),
            label: Text(_selectedTime == null ? 'Hora' : _selectedTime!.format(context)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(_currentAgendamento.nomeUsuario ?? 'Cliente', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Status: ${_currentAgendamento.status}'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoTile(Icons.calendar_today, _currentAgendamento.data.toDate() ?? ''),
                _infoTile(Icons.access_time, _currentAgendamento.horario ?? '--:--'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildServicosList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _currentAgendamento.servicos.length,
      itemBuilder: (context, index) {
        final servico = _currentAgendamento.servicos[index];
        return SwitchListTile(
          title: Text(servico.nome),
          subtitle: Text('R\$ ${servico.valor.toStringAsFixed(2)} | ${servico.tempoExecucao} min'),
          value: servico.confirmado,
          onChanged: widget.readonly ? null : (bool value) {
            setState(() {
              final novosServicos = List<ServicoModel>.from(_currentAgendamento.servicos);
              novosServicos[index] = servico.copyWith(confirmado: value);
              _currentAgendamento = AgendamentoModel(
                id: _currentAgendamento.id,
                usuarioId: _currentAgendamento.usuarioId,
                nomeUsuario: _currentAgendamento.nomeUsuario,
                servicos: novosServicos,
                data: _currentAgendamento.data,
                horario: _currentAgendamento.horario,
                status: _currentAgendamento.status,
              );
            });
          },
        );
      },
    );
  }

  Widget _buildResumoFinanceiro() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _resumoRow('Tempo Total Estimado:', '${_currentAgendamento.tempoTotalCalculado} min'),
          const SizedBox(height: 8),
          _resumoRow('Valor Total:', 'R\$ ${_currentAgendamento.valorTotalCalculado.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _resumoRow(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: isBold ? Colors.blue : null,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }

  Widget _buildActionButtons() {
    if (widget.readonly || _currentAgendamento.status != 'PENDENTE') return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.read<AgendamentoBloc>().add(RejeitarAgendamentoRequested(_currentAgendamento.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('REJEITAR'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _podeAprovar ? () {
              final idsAprovados = _currentAgendamento.servicos
                  .where((s) => s.confirmado)
                  .map((s) => s.id)
                  .toList();

              context.read<AgendamentoBloc>().add(AprovarAgendamentoRequested(
                agendamentoId: _currentAgendamento.id,
                servicosAprovadosIds: idsAprovados,
              ));
            } : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('APROVAR'),
          ),
        ),
      ],
    );
  }
}
