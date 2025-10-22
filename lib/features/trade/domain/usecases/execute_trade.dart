import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/exchange_result.dart';
import '../entities/quote.dart';
import '../entities/trade_pair.dart';
import '../repositories/trade_repository.dart';

class ExecuteTrade {
  ExecuteTrade(this._repository);

  final TradeRepository _repository;

  Future<Either<Failure, ExchangeResult>> call(ExecuteTradeParams params) {
    return _repository.executeOrder(
      pair: params.pair,
      side: params.side,
      amount: params.amount,
    );
  }
}

class ExecuteTradeParams {
  const ExecuteTradeParams({
    required this.pair,
    required this.side,
    required this.amount,
  });

  final TradePair pair;
  final TradeSide side;
  final double amount;
}
