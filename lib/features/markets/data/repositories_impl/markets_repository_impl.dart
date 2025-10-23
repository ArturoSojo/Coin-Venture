import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/crypto_asset.dart';
import '../../domain/entities/ohlc.dart';
import '../../domain/entities/ticker.dart';
import '../../domain/repositories/markets_repository.dart';
import '../datasources/binance_remote_datasource.dart';
import '../models/ticker_model.dart';

class MarketsRepositoryImpl implements MarketsRepository {
  MarketsRepositoryImpl(this._remoteDataSource);

  final BinanceRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, CryptoAsset>> getAsset(String symbol) async {
    try {
      final tickers = await _remoteDataSource.getTickers();
      final ticker = tickers.firstWhere(
        (item) => item.symbol == symbol,
        orElse: () => TickerModel(
          symbol: symbol,
          price: 0,
          change24h: 0,
          volume24h: 0,
          marketCap: 0,
          quoteVolume: 0,
          openPrice: 0,
          highPrice: 0,
          lowPrice: 0,
        ),
      );
      final asset = CryptoAsset(
        id: ticker.symbol,
        symbol: ticker.symbol,
        name: _formatName(ticker.symbol),
      );
      return Right(asset);
    } on DioException catch (error) {
      return Left(NetworkFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<Ticker>>> getMarkets({
    String? query,
    MarketSortOption sort = MarketSortOption.volume,
  }) async {
    try {
      final rawTickers = await _remoteDataSource.getTickers();
      final filtered = _filterTickers(rawTickers, query);
      final enriched = await _attachSparkline(filtered);
      final sorted = _sortTickers(enriched, sort);
      return Right(sorted);
    } on DioException catch (error) {
      return Left(NetworkFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<OHLC>>> getOhlc(
    String symbol, {
    String interval = '1h',
  }) async {
    try {
      final data = await _remoteDataSource.getKlines(
        symbol: symbol,
        interval: interval,
        limit: 168,
      );
      return Right(data);
    } on DioException catch (error) {
      return Left(NetworkFailure(message: error.message));
    }
  }

  @override
  Stream<Ticker> watchTicker(String symbol) {
    return Stream<Ticker>.periodic(
      const Duration(seconds: 15),
      (_) => symbol,
    ).asyncMap((pair) async {
      final tickers = await _remoteDataSource.getTickers();
      final ticker = tickers.firstWhere(
        (item) => item.symbol == pair,
        orElse: () => TickerModel(
          symbol: pair,
          price: 0,
          change24h: 0,
          volume24h: 0,
          marketCap: 0,
          quoteVolume: 0,
          openPrice: 0,
          highPrice: 0,
          lowPrice: 0,
        ),
      );
      return ticker;
    });
  }

  List<Ticker> _sortTickers(List<Ticker> data, MarketSortOption sort) {
    final tickers = List<Ticker>.from(data);
    switch (sort) {
      case MarketSortOption.name:
        tickers.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
      case MarketSortOption.price:
        tickers.sort((a, b) => b.price.compareTo(a.price));
        break;
      case MarketSortOption.change:
        tickers.sort((a, b) => b.change24h.compareTo(a.change24h));
        break;
      case MarketSortOption.volume:
        tickers.sort((a, b) => b.volume24h.compareTo(a.volume24h));
        break;
    }
    return tickers;
  }

  List<TickerModel> _filterTickers(List<TickerModel> data, String? query) {
    final filtered = data.where((ticker) {
      if (!_isSupportedQuote(ticker.symbol)) {
        return false;
      }
      if (query == null || query.isEmpty) {
        return true;
      }
      final normalized = query.toUpperCase();
      return ticker.symbol.contains(normalized);
    }).toList();
    return filtered;
  }

  Future<List<TickerModel>> _attachSparkline(List<TickerModel> data) async {
    final topSymbols = data.take(40).map((ticker) => ticker.symbol).toList();
    final sparklineFutures = <Future<List<double>>>[];
    for (final symbol in topSymbols) {
      sparklineFutures.add(
        _remoteDataSource
            .getKlines(symbol: symbol, interval: '1h', limit: 168)
            .then((value) => value.map((e) => e.close).toList(growable: false))
            .catchError((_) => <double>[]),
      );
    }
    final sparklines = await Future.wait(sparklineFutures);
    final Map<String, List<double>> sparklineMap = <String, List<double>>{};
    for (var i = 0; i < topSymbols.length; i++) {
      sparklineMap[topSymbols[i]] = sparklines[i];
    }

    return data
        .map(
          (ticker) => ticker.copyWith(
            sparkline: sparklineMap[ticker.symbol],
          ),
        )
        .toList(growable: false);
  }

  bool _isSupportedQuote(String symbol) {
    const supportedQuotes = <String>['USDT', 'BUSD', 'USDC', 'FDUSD', 'TRY'];
    for (final quote in supportedQuotes) {
      if (symbol.endsWith(quote)) {
        return true;
      }
    }
    return false;
  }

  String _formatName(String symbol) {
    if (symbol.length <= 3) {
      return symbol.toUpperCase();
    }
    final buffer = StringBuffer();
    for (final rune in symbol.runes) {
      final char = String.fromCharCode(rune);
      if (RegExp(r'[0-9]').hasMatch(char)) {
        break;
      }
      if (char == char.toUpperCase()) {
        if (buffer.isNotEmpty) {
          buffer.write(' ');
        }
      }
      buffer.write(char.toUpperCase());
    }
    final value = buffer.toString().trim();
    return value.isEmpty ? symbol.toUpperCase() : value;
  }
}
