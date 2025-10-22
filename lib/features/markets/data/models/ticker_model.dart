import '../../domain/entities/ticker.dart';

class TickerModel extends Ticker {
  const TickerModel({
    required super.symbol,
    required super.price,
    required super.change24h,
    required super.volume24h,
    required super.marketCap,
    super.sparkline,
  });

  factory TickerModel.fromMap(Map<String, dynamic> map) {
    return TickerModel(
      symbol: map['symbol'] as String,
      price: (map['price'] as num).toDouble(),
      change24h: (map['change24h'] as num).toDouble(),
      volume24h: (map['volume24h'] as num).toDouble(),
      marketCap: (map['marketCap'] as num).toDouble(),
      sparkline: (map['sparkline'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
    );
  }
}
