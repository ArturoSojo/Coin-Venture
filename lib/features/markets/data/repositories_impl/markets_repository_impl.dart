import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/crypto_asset.dart';
import '../../domain/entities/ohlc.dart';
import '../../domain/entities/ticker.dart';
import '../../domain/repositories/markets_repository.dart';
import '../datasources/binance_remote_datasource.dart';

class MarketsRepositoryImpl implements MarketsRepository {
  MarketsRepositoryImpl(this._remoteDataSource);

  final BinanceRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, CryptoAsset>> getAsset(String symbol) async {
    try {
      final asset = await _remoteDataSource.fetchAsset(symbol);
      return Right(asset);
    } on ServerException catch (error) {
      return Left(NetworkFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<Ticker>>> getMarkets({
    String? query,
    MarketSortOption sort = MarketSortOption.marketCap,
  }) async {
    try {
      final tickers = await _remoteDataSource.fetchMarkets(query: query);
      final sorted = _sortTickers(tickers, sort);
      return Right(sorted);
    } on ServerException catch (error) {
      return Left(NetworkFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<OHLC>>> getOhlc(
    String symbol, {
    String interval = '1h',
  }) async {
    try {
      final ohlc = await _remoteDataSource.fetchOhlc(symbol, interval: interval);
      return Right(ohlc);
    } on ServerException catch (error) {
      return Left(NetworkFailure(message: error.message));
    }
  }

  @override
  Stream<Ticker> watchTicker(String symbol) {
    return _remoteDataSource.watchTicker(symbol);
  }

  List<Ticker> _sortTickers(List<Ticker> data, MarketSortOption sort) {
    final tickers = List<Ticker>.from(data);
    switch (sort) {
      case MarketSortOption.marketCap:
        tickers.sort((a, b) => b.marketCap.compareTo(a.marketCap));
        break;
      case MarketSortOption.volume:
        tickers.sort((a, b) => b.volume24h.compareTo(a.volume24h));
        break;
      case MarketSortOption.change:
        tickers.sort((a, b) => b.change24h.compareTo(a.change24h));
        break;
    }
    return tickers;
  }
}
