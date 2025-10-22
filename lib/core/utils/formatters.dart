import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double value, {String currency = 'USD'}) {
    return NumberFormat.simpleCurrency(name: currency).format(value);
  }

  static String formatPercent(double value) {
    final number = NumberFormat.percentPattern();
    return number.format(value);
  }

  static String formatCompact(double value) {
    return NumberFormat.compactCurrency(symbol: String.fromCharCode(36)).format(value);
  }
}
