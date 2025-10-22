import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/history_repository.dart';

class GetTransactions {
  GetTransactions(this._repository);

  final HistoryRepository _repository;

  Future<Either<Failure, List<Transaction>>> call() {
    return _repository.getTransactions();
  }
}
