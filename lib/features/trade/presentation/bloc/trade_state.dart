import 'package:equatable/equatable.dart';

import '../../domain/entities/exchange_result.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/trade_pair.dart';

enum TradeStatus { initial, loading, quoting, quoted, submitting, success, failure }

enum TradeTab { buy, sell }

class TradeState extends Equatable {
  const TradeState({
    this.status = TradeStatus.initial,
    this.pairs = const [],
    this.selectedPair,
    this.side = TradeTab.buy,
    this.amount = 0,
    this.quote,
    this.result,
    this.errorMessage,
  });

  final TradeStatus status;
  final List<TradePair> pairs;
  final TradePair? selectedPair;
  final TradeTab side;
  final double amount;
  final Quote? quote;
  final ExchangeResult? result;
  final String? errorMessage;

  TradeState copyWith({
    TradeStatus? status,
    List<TradePair>? pairs,
    TradePair? selectedPair,
    TradeTab? side,
    double? amount,
    Quote? quote,
    ExchangeResult? result,
    String? errorMessage,
  }) {
    return TradeState(
      status: status ?? this.status,
      pairs: pairs ?? this.pairs,
      selectedPair: selectedPair ?? this.selectedPair,
      side: side ?? this.side,
      amount: amount ?? this.amount,
      quote: quote ?? this.quote,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }

  TradeSide get domainSide => side == TradeTab.buy ? TradeSide.buy : TradeSide.sell;

  @override
  List<Object?> get props => [status, pairs, selectedPair, side, amount, quote, result, errorMessage];
}
