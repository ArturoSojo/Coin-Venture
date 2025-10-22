import 'package:equatable/equatable.dart';

class Balance extends Equatable {
  const Balance({
    required this.symbol,
    required this.amount,
  });

  final String symbol;
  final double amount;

  @override
  List<Object?> get props => [symbol, amount];
}
