import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    required GetTransactions getTransactions,
    required AddTransaction addTransaction,
  })  : _getTransactions = getTransactions,
        _addTransaction = addTransaction,
        super(const HistoryState()) {
    on<HistoryStarted>(_onStarted);
    on<HistoryRefreshRequested>(_onRefreshRequested);
    on<HistoryTransactionAdded>(_onTransactionAdded);
  }

  final GetTransactions _getTransactions;
  final AddTransaction _addTransaction;

  Future<void> _onStarted(HistoryStarted event, Emitter<HistoryState> emit) async {
    await _loadTransactions(emit);
  }

  Future<void> _onRefreshRequested(
    HistoryRefreshRequested event,
    Emitter<HistoryState> emit,
  ) async {
    await _loadTransactions(emit);
  }

  Future<void> _onTransactionAdded(
    HistoryTransactionAdded event,
    Emitter<HistoryState> emit,
  ) async {
    await _addTransaction(event.transaction);
    await _loadTransactions(emit);
  }

  Future<void> _loadTransactions(Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: HistoryStatus.loading));
    final result = await _getTransactions();
    result.fold(
      (failure) => emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: failure.message,
      )),
      (transactions) => emit(state.copyWith(
        status: HistoryStatus.loaded,
        transactions: transactions,
      )),
    );
  }
}
