import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/local_history_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._localDataSource);

  final LocalHistoryDataSource _localDataSource;

  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    try {
      await _localDataSource.addTransaction(transaction);
      return const Right(null);
    } on CacheException catch (error) {
      return Left(CacheFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final transactions = await _localDataSource.fetchTransactions();
      return Right(transactions);
    } on CacheException catch (error) {
      return Left(CacheFailure(message: error.message));
    }
  }
}
