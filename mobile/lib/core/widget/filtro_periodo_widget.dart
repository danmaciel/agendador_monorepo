import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FiltroPeriodoWidget extends StatelessWidget {
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final Function(DateTimeRange picked) onDateSelected;
  final VoidCallback onClear;

  const FiltroPeriodoWidget({
    super.key,
    this.dataInicio,
    this.dataFim,
    required this.onDateSelected,
    required this.onClear,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: dataInicio != null && dataFim != null
          ? DateTimeRange(start: dataInicio!, end: dataFim!)
          : null,
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => _selectDateRange(context),
              child: Text(
                dataInicio == null
                    ? 'Filtrar por período'
                    : '${DateFormat('dd/MM/yyyy').format(dataInicio!)} até ${DateFormat('dd/MM/yyyy').format(dataFim!)}',
                style: TextStyle(
                  color: dataInicio == null ? Colors.grey : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (dataInicio != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
