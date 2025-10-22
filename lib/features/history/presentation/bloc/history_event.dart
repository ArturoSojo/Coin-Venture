import '../../domain/entities/transaction.dart';

abstract class HistoryEvent {}

class HistoryStarted extends HistoryEvent {}

class HistoryRefreshRequested extends HistoryEvent {}

class HistoryTransactionAdded extends HistoryEvent {
  HistoryTransactionAdded(this.transaction);

  final Transaction transaction;
}
