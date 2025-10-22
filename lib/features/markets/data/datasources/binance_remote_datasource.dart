import '../../domain/entities/crypto_asset.dart';
import '../../domain/entities/ohlc.dart';
import '../../domain/entities/ticker.dart';

abstract class BinanceRemoteDataSource {
  Future<List<Ticker>> fetchMarkets({String? query});
  Future<CryptoAsset> fetchAsset(String symbol);
  Future<List<OHLC>> fetchOhlc(String symbol, {String interval});
  Stream<Ticker> watchTicker(String symbol);
}
