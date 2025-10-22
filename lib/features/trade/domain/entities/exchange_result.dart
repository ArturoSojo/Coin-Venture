import 'package:equatable/equatable.dart';

import 'order.dart';

class ExchangeResult extends Equatable {
  const ExchangeResult({
    required this.order,
    required this.message,
  });

  final Order order;
  final String message;

  @override
  List<Object?> get props => [order, message];
}
