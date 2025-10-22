import '../entities/ticker.dart';
import '../repositories/markets_repository.dart';

class GetTickerStream {
  GetTickerStream(this._repository);

  final MarketsRepository _repository;

  Stream<Ticker> call(String symbol) {
    return _repository.watchTicker(symbol);
  }
}
