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

  static String formatCompactCurrency(double value, {String currencySymbol = r'$'}) {
    return NumberFormat.compactCurrency(symbol: currencySymbol).format(value);
  }

  static String formatCompactNumber(double value) {
    return NumberFormat.compact().format(value);
  }
}
