import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_mobile/core/extensions/string.dart';
import 'package:projeto_mobile/core/widget/snackbar_message.dart';
import 'package:projeto_mobile/features/agendamento/data/models/agendamento_model.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_bloc.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_event.dart';
import 'package:projeto_mobile/features/agendamento/presentation/bloc/agendamento_state.dart';
import 'package:projeto_mobile/features/auth/presentation/bloc/auth_bloc.dart';

class AgendamentoPage extends StatefulWidget {
  final AgendamentoModel? agendamentoParaEdicao;

  const AgendamentoPage({super.key, this.agendamentoParaEdicao});

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  final List<int> _selectedServicosIds = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool get _isEditing => widget.agendamentoParaEdicao != null;

  @override
  void initState() {
    super.initState();
    context.read<AgendamentoBloc>().add(const GetServicosRequested(page: 0));

    if (_isEditing) {
      final agendamento = widget.agendamentoParaEdicao!;
      _selectedServicosIds.addAll(agendamento.servicos.map((s) => s.id));
      
      final dateTime = agendamento.data.toDateTime();
      if (dateTime != null) {
        _selectedDate = dateTime;
        _selectedTime = TimeOfDay.fromDateTime(dateTime);
      }
    }
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
    final authState = context.read<AuthBloc>().state;
    final usuarioId = int.tryParse(authState.userId ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Alterar Agendamento' : 'Novo Agendamento')),
      body: BlocConsumer<AgendamentoBloc, AgendamentoState>(
        listener: (context, state) {
          if (state.status == AgendamentoStatus.creationSuccess) {
            SnackbarMessage.sucesso(context, _isEditing ? 'Alteração salva!' : 'Agendamento realizado!');
            context.read<AgendamentoBloc>().add(GetMeusAgendamentosRequested(usuarioId: usuarioId));
            context.go('/');
          }

          if (state.status == AgendamentoStatus.error) {
            if (state.sugestaoData != null) {
              _showSugestaoDialog(context, state.sugestaoData!, usuarioId, state.errorMessage ?? '');
              return;
            }
            SnackbarMessage.erro(context, state.errorMessage ?? 'Erro ao processar');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Escolha os serviços:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.servicos.length,
                    itemBuilder: (context, index) {
                      final servico = state.servicos[index];
                      return CheckboxListTile(
                        title: Text(servico.nome),
                        subtitle: Text('R\$ ${servico.valor.toStringAsFixed(2)} - ${servico.tempoExecucao} min'),
                        value: _selectedServicosIds.contains(servico.id),
                        onChanged: (selected) {
                          setState(() {
                            if (selected!) {
                              _selectedServicosIds.add(servico.id);
                            } else {
                              _selectedServicosIds.remove(servico.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                const Text('Data e Hora:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_selectedDate == null ? 'Data' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickTime(context),
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime == null ? 'Hora' : _selectedTime!.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedServicosIds.isNotEmpty && _selectedDate != null && _selectedTime != null
                        ? () => _confirmar(context, usuarioId)
                        : null,
                    child: state.status == AgendamentoStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isEditing ? 'SALVAR ALTERAÇÕES' : 'CONFIRMAR AGENDAMENTO'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final nowPlus3Days = DateTime.now().add(const Duration(days: 3));
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? nowPlus3Days,
      firstDate: nowPlus3Days,
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _confirmar(BuildContext context, int usuarioId) {
    if (_isEditing) {
      context.read<AgendamentoBloc>().add(
        AlterarAgendamentoRequested(
          usuarioId: usuarioId,
          agendamentoId: widget.agendamentoParaEdicao!.id,
          servicosIds: _selectedServicosIds,
          dataHora: _getFormattedDateTime(),
        ),
      );
    } else {
      context.read<AgendamentoBloc>().add(
        CriarAgendamentoRequested(
          usuarioId: usuarioId,
          servicosIds: _selectedServicosIds,
          dataHora: _getFormattedDateTime(),
        ),
      );
    }
  }

  void _showSugestaoDialog(BuildContext context, String sugestao, int usuarioId, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Conflito de Data'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AgendamentoBloc>().add(
                ForcarAgendamentoRequested(
                  usuarioId: usuarioId,
                  servicosIds: _selectedServicosIds,
                  dataHora: _getFormattedDateTime(),
                ),
              );
            },
            child: const Text('FORÇAR REGISTRO'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AgendamentoBloc>().add(
                UnirAgendamentoRequested(
                  usuarioId: usuarioId,
                  servicosIds: _selectedServicosIds,
                  dataSugerida: sugestao,
                ),
              );
            },
            child: const Text('ACEITAR SUGESTÃO'),
          ),
        ],
      ),
    );
  }
}
