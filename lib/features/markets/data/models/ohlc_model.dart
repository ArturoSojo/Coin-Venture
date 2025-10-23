import '../../domain/entities/ohlc.dart';

class OhlcModel extends OHLC {
  const OhlcModel({
    required super.time,
    required super.open,
    required super.high,
    required super.low,
    required super.close,
    super.volume,
  });

  factory OhlcModel.fromList(List<dynamic> data) {
    return OhlcModel(
      time: DateTime.fromMillisecondsSinceEpoch((data[0] as num).toInt()),
      open: double.parse((data[1] as Object).toString()),
      high: double.parse((data[2] as Object).toString()),
      low: double.parse((data[3] as Object).toString()),
      close: double.parse((data[4] as Object).toString()),
      volume: double.tryParse((data[5] as Object).toString()),
    );
  }
}
