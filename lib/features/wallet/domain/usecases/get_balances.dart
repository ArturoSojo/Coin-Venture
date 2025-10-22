import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/balance.dart';
import '../repositories/wallet_repository.dart';

class GetBalances {
  GetBalances(this._repository);

  final WalletRepository _repository;

  Future<Either<Failure, List<Balance>>> call() {
    return _repository.getBalances();
  }
}
