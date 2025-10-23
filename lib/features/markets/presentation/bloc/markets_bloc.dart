import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_markets.dart';
import '../../domain/entities/ticker.dart';
import 'markets_event.dart';
import 'markets_state.dart';

class MarketsBloc extends Bloc<MarketsEvent, MarketsState> {
  MarketsBloc(this._getMarkets) : super(const MarketsState()) {
    on<MarketsStarted>(_onStarted);
    on<MarketsRefreshRequested>(_onRefreshRequested);
    on<MarketsSearchChanged>(_onSearchChanged);
    on<MarketsSortChanged>(_onSortChanged);
  }

  final GetMarkets _getMarkets;
  Timer? _timer;

  Future<void> _onStarted(MarketsStarted event, Emitter<MarketsState> emit) async {
    await _refresh(emit);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      add(MarketsRefreshRequested());
    });
  }

  Future<void> _onRefreshRequested(
    MarketsRefreshRequested event,
    Emitter<MarketsState> emit,
  ) async {
    final keepLoading = state.status == MarketsStatus.loaded && state.tickers.isNotEmpty;
    await _refresh(emit, keepLoading: keepLoading);
  }

  Future<void> _onSearchChanged(
    MarketsSearchChanged event,
    Emitter<MarketsState> emit,
  ) async {
    emit(state.copyWith(query: event.query));
    await _refresh(emit, keepLoading: true);
  }

  Future<void> _onSortChanged(
    MarketsSortChanged event,
    Emitter<MarketsState> emit,
  ) async {
    emit(state.copyWith(sort: event.sort));
    await _refresh(emit, keepLoading: true);
  }

  Future<void> _refresh(Emitter<MarketsState> emit, {bool keepLoading = false}) async {
    if (!keepLoading) {
      emit(state.copyWith(status: MarketsStatus.loading));
    }
    final result = await _getMarkets(
      GetMarketsParams(query: state.query, sort: state.sort),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: MarketsStatus.failure,
        errorMessage: failure.message,
      )),
      (tickers) {
        final metrics = _calculateMetrics(tickers);
        emit(state.copyWith(
          status: MarketsStatus.loaded,
          tickers: tickers,
          lastUpdated: DateTime.now(),
          totalMarketCap: metrics.totalMarketCap,
          totalVolume: metrics.totalVolume,
          btcDominance: metrics.btcDominance,
          assetCount: metrics.assetCount,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  _MarketMetrics _calculateMetrics(List<Ticker> tickers) {
    double totalMarketCap = 0;
    double totalVolume = 0;
    double btcDominance = 0;
    final int assetCount = tickers.length;

    for (final ticker in tickers) {
      totalMarketCap += ticker.marketCap;
      totalVolume += ticker.volume24h;
      if (ticker.symbol.startsWith('BTC')) {
        btcDominance = ticker.marketCap;
      }
    }
    final dominance = totalMarketCap == 0
        ? 0.0
        : (btcDominance / totalMarketCap) * 100;

    return _MarketMetrics(
      totalMarketCap: totalMarketCap,
      totalVolume: totalVolume,
      btcDominance: dominance,
      assetCount: assetCount,
    );
  }
}

class _MarketMetrics {
  const _MarketMetrics({
    required this.totalMarketCap,
    required this.totalVolume,
    required this.btcDominance,
    required this.assetCount,
  });

  final double totalMarketCap;
  final double totalVolume;
  final double btcDominance;
  final int assetCount;
}
