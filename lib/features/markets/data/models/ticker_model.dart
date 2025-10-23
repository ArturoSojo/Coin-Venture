import '../../domain/entities/ticker.dart';

class TickerModel extends Ticker {
  const TickerModel({
    required super.symbol,
    required super.price,
    required super.change24h,
    required super.volume24h,
    required super.marketCap,
    required this.quoteVolume,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    super.sparkline,
  });

  final double quoteVolume;
  final double openPrice;
  final double highPrice;
  final double lowPrice;

  TickerModel copyWith({List<double>? sparkline}) {
    return TickerModel(
      symbol: symbol,
      price: price,
      change24h: change24h,
      volume24h: volume24h,
      marketCap: marketCap,
      quoteVolume: quoteVolume,
      openPrice: openPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      sparkline: sparkline ?? this.sparkline,
    );
  }

  factory TickerModel.fromMap(Map<String, dynamic> map) {
    final symbol = map['symbol'] as String;
    final price = double.tryParse(map['lastPrice'] as String? ?? map['price']?.toString() ?? '0') ?? 0;
    final changePercent = double.tryParse(map['priceChangePercent'] as String? ?? '0') ?? 0;
    final quoteVolume = double.tryParse(map['quoteVolume'] as String? ?? '0') ?? 0;
    final open = double.tryParse(map['openPrice'] as String? ?? '0') ?? 0;
    final high = double.tryParse(map['highPrice'] as String? ?? '0') ?? 0;
    final low = double.tryParse(map['lowPrice'] as String? ?? '0') ?? 0;

    return TickerModel(
      symbol: symbol,
      price: price,
      change24h: changePercent,
      volume24h: quoteVolume,
      marketCap: quoteVolume,
      quoteVolume: quoteVolume,
      openPrice: open,
      highPrice: high,
      lowPrice: low,
      sparkline: null,
    );
  }
}
