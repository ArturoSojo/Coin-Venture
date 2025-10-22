import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/ohlc.dart';
import '../repositories/markets_repository.dart';

class GetOhlc {
  GetOhlc(this._repository);

  final MarketsRepository _repository;

  Future<Either<Failure, List<OHLC>>> call(GetOhlcParams params) {
    return _repository.getOhlc(params.symbol, interval: params.interval);
  }
}

class GetOhlcParams {
  const GetOhlcParams({
    required this.symbol,
    this.interval = '1h',
  });

  final String symbol;
  final String interval;
}
