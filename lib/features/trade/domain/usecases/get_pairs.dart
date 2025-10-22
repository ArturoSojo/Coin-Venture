import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/trade_pair.dart';
import '../repositories/trade_repository.dart';

class GetPairs {
  GetPairs(this._repository);

  final TradeRepository _repository;

  Future<Either<Failure, List<TradePair>>> call() {
    return _repository.getPairs();
  }
}
