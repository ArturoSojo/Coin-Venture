import 'dart:async';

import '../../domain/entities/crypto_asset.dart';
import '../../domain/entities/ohlc.dart';
import '../../domain/entities/ticker.dart';
import 'binance_remote_datasource.dart';

class MockBinanceRemoteDataSource implements BinanceRemoteDataSource {
  final Map<String, Ticker> _tickers = {
    'BTCUSDT': const Ticker(
      symbol: 'BTCUSDT',
      price: 108653.0,
      change24h: -1.89,
      volume24h: 105.0,
      marketCap: 2168.0,
      sparkline: [100, 105, 102, 110],
    ),
    'ETHUSDT': const Ticker(
      symbol: 'ETHUSDT',
      price: 3875.58,
      change24h: 2.25,
      volume24h: 87.0,
      marketCap: 600.0,
      sparkline: [3500, 3600, 3700, 3800],
    ),
  };

  @override
  Future<CryptoAsset> fetchAsset(String symbol) async {
    final ticker = _tickers[symbol];
    return CryptoAsset(
      id: symbol,
      symbol: symbol,
      name: ticker?.symbol ?? symbol.substring(0, 3),
      iconUrl: null,
    );
  }

  @override
  Future<List<Ticker>> fetchMarkets({String? query}) async {
    final values = _tickers.values
        .where((ticker) => query == null || ticker.symbol.contains(query.toUpperCase()))
        .toList();
    return values;
  }

  @override
  Future<List<OHLC>> fetchOhlc(String symbol, {String interval = '1h'}) async {
    return List.generate(
      12,
      (index) => OHLC(
        time: DateTime.now().subtract(Duration(hours: index)),
        open: 100 + index.toDouble(),
        high: 110 + index.toDouble(),
        low: 90 + index.toDouble(),
        close: 105 + index.toDouble(),
        volume: 10 + index.toDouble(),
      ),
    );
  }

  @override
  Stream<Ticker> watchTicker(String symbol) {
    final controller = StreamController<Ticker>();
    controller.add(_tickers[symbol] ?? _tickers.values.first);
    return controller.stream;
  }
}
