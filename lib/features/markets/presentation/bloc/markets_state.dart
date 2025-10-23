import 'package:equatable/equatable.dart';

import '../../domain/entities/ticker.dart';
import '../../domain/repositories/markets_repository.dart';

enum MarketsStatus { initial, loading, loaded, failure }

class MarketsState extends Equatable {
  const MarketsState({
    this.status = MarketsStatus.initial,
    this.tickers = const [],
    this.query = '',
    this.sort = MarketSortOption.volume,
    this.errorMessage,
    this.lastUpdated,
    this.totalMarketCap = 0,
    this.totalVolume = 0,
    this.btcDominance = 0,
    this.assetCount = 0,
  });

  final MarketsStatus status;
  final List<Ticker> tickers;
  final String query;
  final MarketSortOption sort;
  final String? errorMessage;
  final DateTime? lastUpdated;
  final double totalMarketCap;
  final double totalVolume;
  final double btcDominance;
  final int assetCount;

  MarketsState copyWith({
    MarketsStatus? status,
    List<Ticker>? tickers,
    String? query,
    MarketSortOption? sort,
    String? errorMessage,
    DateTime? lastUpdated,
    double? totalMarketCap,
    double? totalVolume,
    double? btcDominance,
    int? assetCount,
  }) {
    return MarketsState(
      status: status ?? this.status,
      tickers: tickers ?? this.tickers,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalMarketCap: totalMarketCap ?? this.totalMarketCap,
      totalVolume: totalVolume ?? this.totalVolume,
      btcDominance: btcDominance ?? this.btcDominance,
      assetCount: assetCount ?? this.assetCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tickers,
        query,
        sort,
        errorMessage,
        lastUpdated,
        totalMarketCap,
        totalVolume,
        btcDominance,
        assetCount,
      ];
}
