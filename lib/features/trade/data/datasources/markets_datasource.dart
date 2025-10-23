import '../../domain/entities/order.dart';
import '../../domain/entities/trade_pair.dart';

abstract class MarketsPriceDataSource {
  Future<double> fetchPrice(TradePair pair);
}

abstract class LocalTradeDataSource {
  Future<void> persistOrder(Order order);
}
