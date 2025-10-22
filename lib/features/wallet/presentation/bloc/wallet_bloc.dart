import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_balances.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc(this._getBalances) : super(const WalletState()) {
    on<WalletStarted>(_onStarted);
    on<WalletRefreshRequested>(_onRefreshRequested);
  }

  final GetBalances _getBalances;

  Future<void> _onStarted(WalletStarted event, Emitter<WalletState> emit) async {
    await _loadBalances(emit);
  }

  Future<void> _onRefreshRequested(
    WalletRefreshRequested event,
    Emitter<WalletState> emit,
  ) async {
    await _loadBalances(emit);
  }

  Future<void> _loadBalances(Emitter<WalletState> emit) async {
    emit(state.copyWith(status: WalletStatus.loading));
    final result = await _getBalances();
    result.fold(
      (failure) => emit(state.copyWith(
        status: WalletStatus.failure,
        errorMessage: failure.message,
      )),
      (balances) => emit(state.copyWith(
        status: WalletStatus.loaded,
        balances: balances,
      )),
    );
  }
}
