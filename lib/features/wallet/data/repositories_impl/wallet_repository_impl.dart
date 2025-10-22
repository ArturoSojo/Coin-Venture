import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/balance.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/local_balances_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._localDataSource);

  final LocalBalancesDataSource _localDataSource;

  @override
  Future<Either<Failure, List<Balance>>> getBalances() async {
    try {
      final balances = await _localDataSource.fetchBalances();
      return Right(balances);
    } on CacheException catch (error) {
      return Left(CacheFailure(message: error.message));
    }
  }
}
