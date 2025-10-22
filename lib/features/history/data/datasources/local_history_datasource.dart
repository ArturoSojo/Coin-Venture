import '../../domain/entities/transaction.dart';

abstract class LocalHistoryDataSource {
  Future<List<Transaction>> fetchTransactions();
  Future<void> addTransaction(Transaction transaction);
}

class MemoryHistoryDataSource implements LocalHistoryDataSource {
  final List<Transaction> _transactions = [];

  @override
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<List<Transaction>> fetchTransactions() async {
    return List<Transaction>.unmodifiable(_transactions);
  }
}
