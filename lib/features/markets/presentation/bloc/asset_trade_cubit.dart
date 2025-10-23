import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../trade/domain/entities/quote.dart';
import '../../../trade/domain/entities/trade_pair.dart';
import '../../../trade/domain/usecases/execute_trade.dart';
import '../../../wallet/domain/usecases/get_balances.dart';
import '../../../wallet/domain/entities/balance.dart';
import 'asset_trade_state.dart';

class AssetTradeCubit extends Cubit<AssetTradeState> {
  AssetTradeCubit({
    required ExecuteTrade executeTrade,
    required GetBalances getBalances,
    required String baseSymbol,
    required String quoteSymbol,
  })  : _executeTrade = executeTrade,
        _getBalances = getBalances,
        super(AssetTradeState(baseSymbol: baseSymbol, quoteSymbol: quoteSymbol));

  final ExecuteTrade _executeTrade;
  final GetBalances _getBalances;

  Future<void> initialize() async {
    emit(state.copyWith(loadingBalances: true, errorMessage: null, successMessage: null));
    final result = await _getBalances();
    result.fold(
      (failure) => emit(state.copyWith(
        loadingBalances: false,
        errorMessage: failure.message,
      )),
      (balances) {
        final normalized = _normalizeBalances(balances);
        emit(state.copyWith(
          loadingBalances: false,
          availableBase: normalized[state.baseSymbol] ?? 0,
          availableQuote: normalized[state.quoteSymbol] ?? 0,
          errorMessage: null,
        ));
      },
    );
  }

  void setSide(TradeSide side) {
    emit(state.copyWith(
      side: side,
      errorMessage: null,
      successMessage: null,
    ));
  }

  void setAmount(double amount) {
    emit(state.copyWith(
      amount: amount,
      errorMessage: null,
      successMessage: null,
    ));
  }

  void setPrice(double price) {
    emit(state.copyWith(price: price));
  }

  Future<void> submit() async {
    if (state.amount <= 0 || state.price <= 0) {
      emit(state.copyWith(errorMessage: 'Ingresa una cantidad valida', successMessage: null));
      return;
    }

    final totalCost = state.amount * state.price;
    if (state.side == TradeSide.buy && totalCost > state.availableQuote + 1e-8) {
      emit(state.copyWith(errorMessage: 'Fondos insuficientes', successMessage: null));
      return;
    }
    if (state.side == TradeSide.sell && state.amount > state.availableBase + 1e-8) {
      emit(state.copyWith(errorMessage: 'No tienes suficientes ${state.baseSymbol}', successMessage: null));
      return;
    }

    emit(state.copyWith(submitting: true, errorMessage: null, successMessage: null));
    final result = await _executeTrade(
      ExecuteTradeParams(
        pair: TradePair(base: state.baseSymbol, quote: state.quoteSymbol),
        side: state.side,
        amount: state.amount,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        submitting: false,
        errorMessage: failure.message,
      )),
      (exchange) async {
        emit(state.copyWith(
          submitting: false,
          amount: 0,
          successMessage: exchange.message,
        ));
        await initialize();
      },
    );
  }

  Map<String, double> _normalizeBalances(List<Balance> balances) {
    final map = <String, double>{};
    for (final balance in balances) {
      map[balance.symbol.toUpperCase()] = balance.amount;
    }
    return map;
  }
}
