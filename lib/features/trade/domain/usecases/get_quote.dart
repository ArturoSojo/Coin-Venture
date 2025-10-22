import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/quote.dart';
import '../entities/trade_pair.dart';
import '../repositories/trade_repository.dart';

class GetQuote {
  GetQuote(this._repository);

  final TradeRepository _repository;

  Future<Either<Failure, Quote>> call(GetQuoteParams params) {
    return _repository.getQuote(
      pair: params.pair,
      side: params.side,
      amount: params.amount,
    );
  }
}

class GetQuoteParams {
  const GetQuoteParams({
    required this.pair,
    required this.side,
    required this.amount,
  });

  final TradePair pair;
  final TradeSide side;
  final double amount;
}
