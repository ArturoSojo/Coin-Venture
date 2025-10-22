import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions();
  Future<Either<Failure, void>> addTransaction(Transaction transaction);
}
