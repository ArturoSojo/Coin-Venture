import 'package:equatable/equatable.dart';

import 'quote.dart';
import 'trade_pair.dart';

enum OrderStatus { created, filled, failed }

class Order extends Equatable {
  const Order({
    required this.id,
    required this.pair,
    required this.side,
    required this.amountBase,
    required this.price,
    required this.createdAt,
    this.status = OrderStatus.created,
  });

  final String id;
  final TradePair pair;
  final TradeSide side;
  final double amountBase;
  final double price;
  final DateTime createdAt;
  final OrderStatus status;

  double get totalQuote => amountBase * price;

  Order copyWith({
    OrderStatus? status,
  }) {
    return Order(
      id: id,
      pair: pair,
      side: side,
      amountBase: amountBase,
      price: price,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, pair, side, amountBase, price, createdAt, status];
}
