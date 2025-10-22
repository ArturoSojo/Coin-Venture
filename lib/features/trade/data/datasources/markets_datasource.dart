import '../../domain/entities/quote.dart';
import '../../domain/entities/trade_pair.dart';

abstract class MarketsPriceDataSource {
  Future<double> fetchPrice(TradePair pair);
}

abstract class LocalTradeDataSource {
  Future<void> persistOrder({required TradePair pair, required TradeSide side, required double amount});
}
