import 'package:equatable/equatable.dart';

import '../../../trade/domain/entities/order.dart';
import '../../../trade/domain/entities/trade_pair.dart';
import '../../../trade/domain/entities/quote.dart';

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.pair,
    required this.side,
    required this.amountBase,
    required this.amountQuote,
    required this.price,
    required this.status,
    required this.timestamp,
  });

  final String id;
  final TradePair pair;
  final OrderStatus status;
  final TradeSide side;
  final double amountBase;
  final double amountQuote;
  final double price;
  final DateTime timestamp;

  @override
  List<Object?> get props => [id, pair, side, amountBase, amountQuote, price, status, timestamp];
}
