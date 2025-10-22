import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_markets.dart';
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
    await _refresh(emit);
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
      (tickers) => emit(state.copyWith(
        status: MarketsStatus.loaded,
        tickers: tickers,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
