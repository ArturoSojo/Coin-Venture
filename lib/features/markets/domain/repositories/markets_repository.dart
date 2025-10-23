import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/crypto_asset.dart';
import '../entities/ohlc.dart';
import '../entities/ticker.dart';

abstract class MarketsRepository {
  Future<Either<Failure, List<Ticker>>> getMarkets({
    String? query,
    MarketSortOption sort = MarketSortOption.volume,
  });

  Stream<Ticker> watchTicker(String symbol);

  Future<Either<Failure, List<OHLC>>> getOhlc(
    String symbol, {
    String interval = '1h',
  });

  Future<Either<Failure, CryptoAsset>> getAsset(String symbol);
}

enum MarketSortOption { name, price, change, volume }
