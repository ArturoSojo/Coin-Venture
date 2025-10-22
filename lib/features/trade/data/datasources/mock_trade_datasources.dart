import '../../domain/entities/quote.dart';
import '../../domain/entities/trade_pair.dart';
import 'markets_datasource.dart';

class MockMarketsPriceDataSource implements MarketsPriceDataSource {
  @override
  Future<double> fetchPrice(TradePair pair) async {
    return switch (pair.symbol) {
      'BTCUSDT' => 108653.0,
      'ETHUSDT' => 3875.58,
      _ => 1.0,
    };
  }
}

class MockLocalTradeDataSource implements LocalTradeDataSource {
  final List<Map<String, Object>> orders = [];

  @override
  Future<void> persistOrder({
    required TradePair pair,
    required TradeSide side,
    required double amount,
  }) async {
    orders.add({
      'pair': pair.symbol,
      'side': side.name,
      'amount': amount,
    });
  }
}
