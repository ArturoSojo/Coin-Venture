import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction.dart';

enum HistoryStatus { initial, loading, loaded, failure }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<Transaction> transactions;
  final String? errorMessage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<Transaction>? transactions,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}
