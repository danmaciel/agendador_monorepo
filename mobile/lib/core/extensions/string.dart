import 'package:intl/intl.dart';

extension StringDateTimeExtension on String {
  /// Converte string para DateTime com suporte a múltiplos formatos
  DateTime? toDateTime() {
    // Lista de formatos comuns para tentar
    final formatos = [
      "dd/MM/yyyy HH:mm:ss",
      "dd/MM/yyyy HH:mm",
      "dd/MM/yyyy",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-ddTHH:mm:ss",
      "yyyy-MM-dd HH:mm",
      "yyyy-MM-dd",
      "dd-MM-yyyy HH:mm:ss",
      "dd-MM-yyyy HH:mm",
      "dd-MM-yyyy",
      "MM/dd/yyyy HH:mm:ss",
      "MM/dd/yyyyTHH:mm:ss",
      "MM/dd/yyyy HH:mm",
      "MM/dd/yyyy",
    ];

    for (var formato in formatos) {
      try {
        return DateFormat(formato).parse(this);
      } catch (_) {
        continue;
      }
    }

    // Tenta o parse padrão do DateTime (ISO 8601)
    try {
      return DateTime.parse(this);
    } catch (_) {
      return null;
    }
  }

  /// Retorna apenas a data formatada
  String? toDate({
    String formatoSaida = "dd/MM/yyyy",
    String? locale,
  }) {
    final dateTime = toDateTime();
    if (dateTime == null) return null;

    final formatter = locale != null
        ? DateFormat(formatoSaida, locale)
        : DateFormat(formatoSaida);

    return formatter.format(dateTime);
  }

  /// Retorna apenas a hora formatada
  String? toTime({
    String formatoSaida = "HH:mm",
    bool includeSeconds = false,
    String? locale,
  }) {
    final dateTime = toDateTime();
    if (dateTime == null) return null;

    final formato = includeSeconds ? "HH:mm:ss" : formatoSaida;
    final formatter = locale != null
        ? DateFormat(formato, locale)
        : DateFormat(formato);

    return formatter.format(dateTime);
  }

  /// Retorna um mapa com data e hora separados
  Map<String, String>? toDateTimeSeparated({
    String formatoData = "dd/MM/yyyy",
    String formatoHora = "HH:mm",
    bool includeSeconds = false,
    String? locale,
  }) {
    final dateTime = toDateTime();
    if (dateTime == null) return null;

    final formatoHoraFinal = includeSeconds ? "HH:mm:ss" : formatoHora;

    final dateFormatter = locale != null
        ? DateFormat(formatoData, locale)
        : DateFormat(formatoData);

    final timeFormatter = locale != null
        ? DateFormat(formatoHoraFinal, locale)
        : DateFormat(formatoHoraFinal);

    return {
      'data': dateFormatter.format(dateTime),
      'hora': timeFormatter.format(dateTime),
      'dataCompleta': dateTime.toIso8601String(),
      'timestamp': dateTime.millisecondsSinceEpoch.toString(),
    };
  }

  /// Versão simplificada que retorna tupla (data, hora)
  (String? data, String? hora) toDateTimeTuple({
    String formatoData = "dd/MM/yyyy",
    String formatoHora = "HH:mm",
    bool includeSeconds = false,
  }) {
    final separado = toDateTimeSeparated(
      formatoData: formatoData,
      formatoHora: formatoHora,
      includeSeconds: includeSeconds,
    );

    if (separado == null) return (null, null);

    return (separado['data'], separado['hora']);
  }

  /// Formata para o padrão brasileiro (dd/MM/yyyy HH:mm)
  String? toBrazilianFormat({bool includeSeconds = false}) {
    final separado = toDateTimeSeparated(
      includeSeconds: includeSeconds,
    );

    if (separado == null) return null;

    return "${separado['data']} ${separado['hora']}";
  }

  /// Retorna data por extenso
  String? toDateExtended({String? locale = 'pt_BR'}) {
    final dateTime = toDateTime();
    if (dateTime == null) return null;

    final formatter = DateFormat.yMMMMd(locale);
    return formatter.format(dateTime);
  }

  /// Retorna data relativa (hoje, ontem, etc)
  String toRelative({String? locale = 'pt_BR'}) {
    final dateTime = toDateTime();
    if (dateTime == null) return this;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final dateWithoutTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day
    );

    if (dateWithoutTime == today) {
      return "Hoje às ${toTime()}";
    } else if (dateWithoutTime == yesterday) {
      return "Ontem às ${toTime()}";
    } else if (dateWithoutTime == tomorrow) {
      return "Amanhã às ${toTime()}";
    } else {
      return toBrazilianFormat() ?? this;
    }
  }

  /// Valida se a string é uma data válida
  bool isValidDateTime() {
    return toDateTime() != null;
  }

  /// Compara com outra data string
  int? compareTo(String other) {
    final thisDt = toDateTime();
    final otherDt = other.toDateTime();

    if (thisDt == null || otherDt == null) return null;

    return thisDt.compareTo(otherDt);
  }

  /// Verifica se é depois de outra data
  bool? isAfter(String other) {
    final thisDt = toDateTime();
    final otherDt = other.toDateTime();

    if (thisDt == null || otherDt == null) return null;

    return thisDt.isAfter(otherDt);
  }

  /// Verifica se é antes de outra data
  bool? isBefore(String other) {
    final thisDt = toDateTime();
    final otherDt = other.toDateTime();

    if (thisDt == null || otherDt == null) return null;

    return thisDt.isBefore(otherDt);
  }

  /// Adiciona dias à data
  String? addDays(int days, {String formatoSaida = "dd/MM/yyyy HH:mm"}) {
    final dateTime = toDateTime();
    if (dateTime == null) return null;

    final newDate = dateTime.add(Duration(days: days));
    return DateFormat(formatoSaida).format(newDate);
  }

  /// Subtrai dias da data
  String? subtractDays(int days, {String formatoSaida = "dd/MM/yyyy HH:mm"}) {
    final dateTime = toDateTime();
    if (dateTime == null) return null;

    final newDate = dateTime.subtract(Duration(days: days));
    return DateFormat(formatoSaida).format(newDate);
  }

  /// Retorna a diferença em dias entre duas datas
  int? differenceInDays(String other) {
    final thisDt = toDateTime();
    final otherDt = other.toDateTime();

    if (thisDt == null || otherDt == null) return null;

    return thisDt.difference(otherDt).inDays;
  }
}