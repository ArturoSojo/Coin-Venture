import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/history_repository.dart';

class AddTransaction {
  AddTransaction(this._repository);

  final HistoryRepository _repository;

  Future<Either<Failure, void>> call(Transaction transaction) {
    return _repository.addTransaction(transaction);
  }
}
