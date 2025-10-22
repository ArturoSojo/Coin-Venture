import 'package:bloc/bloc.dart';

import '../../domain/entities/quote.dart';
import '../../domain/usecases/execute_trade.dart';
import '../../domain/usecases/get_pairs.dart';
import '../../domain/usecases/get_quote.dart';
import 'trade_event.dart';
import 'trade_state.dart';

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  TradeBloc({
    required GetPairs getPairs,
    required GetQuote getQuote,
    required ExecuteTrade executeTrade,
  })  : _getPairs = getPairs,
        _getQuote = getQuote,
        _executeTrade = executeTrade,
        super(const TradeState()) {
    on<TradeStarted>(_onStarted);
    on<TradePairSelected>(_onPairSelected);
    on<TradeSideChanged>(_onSideChanged);
    on<TradeAmountChanged>(_onAmountChanged);
    on<TradeQuoteRequested>(_onQuoteRequested);
    on<TradeSubmitted>(_onSubmitted);
  }

  final GetPairs _getPairs;
  final GetQuote _getQuote;
  final ExecuteTrade _executeTrade;

  Future<void> _onStarted(TradeStarted event, Emitter<TradeState> emit) async {
    emit(state.copyWith(status: TradeStatus.loading));
    final result = await _getPairs();
    result.fold(
      (failure) => emit(state.copyWith(
        status: TradeStatus.failure,
        errorMessage: failure.message,
      )),
      (pairs) => emit(state.copyWith(
        status: TradeStatus.loaded,
        pairs: pairs,
        selectedPair: pairs.isNotEmpty ? pairs.first : null,
      )),
    );
  }

  void _onPairSelected(TradePairSelected event, Emitter<TradeState> emit) {
    emit(state.copyWith(selectedPair: event.pair));
  }

  void _onSideChanged(TradeSideChanged event, Emitter<TradeState> emit) {
    emit(state.copyWith(side: event.side == TradeSide.buy ? TradeTab.buy : TradeTab.sell));
  }

  void _onAmountChanged(TradeAmountChanged event, Emitter<TradeState> emit) {
    emit(state.copyWith(amount: event.amount));
  }

  Future<void> _onQuoteRequested(
    TradeQuoteRequested event,
    Emitter<TradeState> emit,
  ) async {
    final pair = state.selectedPair;
    if (pair == null) return;
    emit(state.copyWith(status: TradeStatus.quoting));
    final result = await _getQuote(
      GetQuoteParams(pair: pair, side: state.domainSide, amount: state.amount),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: TradeStatus.failure,
        errorMessage: failure.message,
      )),
      (quote) => emit(state.copyWith(
        status: TradeStatus.quoted,
        quote: quote,
      )),
    );
  }

  Future<void> _onSubmitted(
    TradeSubmitted event,
    Emitter<TradeState> emit,
  ) async {
    final pair = state.selectedPair;
    if (pair == null) return;
    emit(state.copyWith(status: TradeStatus.submitting));
    final result = await _executeTrade(
      ExecuteTradeParams(pair: pair, side: state.domainSide, amount: state.amount),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: TradeStatus.failure,
        errorMessage: failure.message,
      )),
      (exchange) => emit(state.copyWith(
        status: TradeStatus.success,
        result: exchange,
      )),
    );
  }
}
