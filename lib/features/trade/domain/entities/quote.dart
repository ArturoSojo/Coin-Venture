import 'package:equatable/equatable.dart';

import 'trade_pair.dart';

enum TradeSide { buy, sell }

class Quote extends Equatable {
  const Quote({
    required this.pair,
    required this.side,
    required this.price,
    required this.expiresAt,
  });

  final TradePair pair;
  final TradeSide side;
  final double price;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [pair, side, price, expiresAt];
}
