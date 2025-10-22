import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/ticker.dart';
import '../repositories/markets_repository.dart';

class GetMarkets {
  GetMarkets(this._repository);

  final MarketsRepository _repository;

  Future<Either<Failure, List<Ticker>>> call(GetMarketsParams params) {
    return _repository.getMarkets(
      query: params.query,
      sort: params.sort,
    );
  }
}

class GetMarketsParams {
  const GetMarketsParams({
    this.query,
    this.sort = MarketSortOption.marketCap,
  });

  final String? query;
  final MarketSortOption sort;
}
