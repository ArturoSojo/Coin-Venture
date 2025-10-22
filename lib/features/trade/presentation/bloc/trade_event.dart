import '../../domain/entities/quote.dart';
import '../../domain/entities/trade_pair.dart';

abstract class TradeEvent {}

class TradeStarted extends TradeEvent {}

class TradePairSelected extends TradeEvent {
  TradePairSelected(this.pair);

  final TradePair pair;
}

class TradeSideChanged extends TradeEvent {
  TradeSideChanged(this.side);

  final TradeSide side;
}

class TradeAmountChanged extends TradeEvent {
  TradeAmountChanged(this.amount);

  final double amount;
}

class TradeQuoteRequested extends TradeEvent {}

class TradeSubmitted extends TradeEvent {}
