import '../../domain/usecases/get_markets.dart';
import '../../domain/repositories/markets_repository.dart';

abstract class MarketsEvent {}

class MarketsStarted extends MarketsEvent {}

class MarketsRefreshRequested extends MarketsEvent {}

class MarketsSearchChanged extends MarketsEvent {
  MarketsSearchChanged(this.query);

  final String query;
}

class MarketsSortChanged extends MarketsEvent {
  MarketsSortChanged(this.sort);

  final MarketSortOption sort;
}

class MarketsIntervalChanged extends MarketsEvent {
  MarketsIntervalChanged(this.interval);

  final String interval;
}
