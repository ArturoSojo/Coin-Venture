import 'package:equatable/equatable.dart';

class Ticker extends Equatable {
  const Ticker({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.volume24h,
    required this.marketCap,
    this.sparkline,
  });

  final String symbol;
  final double price;
  final double change24h;
  final double volume24h;
  final double marketCap;
  final List<double>? sparkline;

  @override
  List<Object?> get props => [symbol, price, change24h, volume24h, marketCap, sparkline];
}
