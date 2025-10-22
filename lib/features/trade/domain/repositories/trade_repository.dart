import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/exchange_result.dart';
import '../entities/quote.dart';
import '../entities/trade_pair.dart';

abstract class TradeRepository {
  Future<Either<Failure, List<TradePair>>> getPairs();
  Future<Either<Failure, Quote>> getQuote({
    required TradePair pair,
    required TradeSide side,
    required double amount,
  });
  Future<Either<Failure, ExchangeResult>> executeOrder({
    required TradePair pair,
    required TradeSide side,
    required double amount,
  });
}
