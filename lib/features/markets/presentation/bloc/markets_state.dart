import 'package:equatable/equatable.dart';

import '../../domain/entities/ticker.dart';
import '../../domain/repositories/markets_repository.dart';

enum MarketsStatus { initial, loading, loaded, failure }

class MarketsState extends Equatable {
  const MarketsState({
    this.status = MarketsStatus.initial,
    this.tickers = const [],
    this.query = '',
    this.sort = MarketSortOption.marketCap,
    this.errorMessage,
    this.lastUpdated,
  });

  final MarketsStatus status;
  final List<Ticker> tickers;
  final String query;
  final MarketSortOption sort;
  final String? errorMessage;
  final DateTime? lastUpdated;

  MarketsState copyWith({
    MarketsStatus? status,
    List<Ticker>? tickers,
    String? query,
    MarketSortOption? sort,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return MarketsState(
      status: status ?? this.status,
      tickers: tickers ?? this.tickers,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [status, tickers, query, sort, errorMessage, lastUpdated];
}
