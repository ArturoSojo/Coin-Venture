import '../../domain/entities/order.dart';
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
  final List<Order> orders = [];

  @override
  Future<void> persistOrder(Order order) async {
    orders.add(order);
  }
}
