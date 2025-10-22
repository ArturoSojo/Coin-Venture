import 'package:equatable/equatable.dart';

class OHLC extends Equatable {
  const OHLC({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });

  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume;

  @override
  List<Object?> get props => [time, open, high, low, close, volume];
}
