import 'package:intl/intl.dart';

class Formatters {
  // Formata um valor monetário para o formato brasileiro (R$ 1.234,56)
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  // Formata uma data para o formato brasileiro (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
    return formatter.format(date);
  }

  // Formata uma data e hora para o formato brasileiro (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return formatter.format(dateTime);
  }

  // Capitaliza a primeira letra de uma string
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  // Formata um nome ou título, capitalizando cada palavra
  static String formatName(String value) {
    return value.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Converte um valor monetário de string para double (suporta R$ 1.234,56 ou 1234.56)
  static double? parseCurrency(String value) {
    if (value.isEmpty) return null;
    final cleanedValue = value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleanedValue);
  }
}