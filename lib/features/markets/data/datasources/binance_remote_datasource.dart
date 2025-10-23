import 'package:dio/dio.dart';

import '../models/ohlc_model.dart';
import '../models/ticker_model.dart';

abstract class BinanceRemoteDataSource {
  Future<List<TickerModel>> getTickers();
  Future<List<OhlcModel>> getKlines({
    required String symbol,
    required String interval,
    required int limit,
  });
}

class BinanceRemoteDataSourceImpl implements BinanceRemoteDataSource {
  BinanceRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TickerModel>> getTickers() async {
    final response = await _dio.get<List<dynamic>>('/api/v3/ticker/24hr');
    final data = response.data ?? [];
    return data
        .map((dynamic item) => TickerModel.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<OhlcModel>> getKlines({
    required String symbol,
    required String interval,
    required int limit,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v3/klines',
      queryParameters: <String, dynamic>{
        'symbol': symbol,
        'interval': interval,
        'limit': limit,
      },
    );
    final data = response.data ?? [];
    return data
        .map((dynamic item) => OhlcModel.fromList(item as List<dynamic>))
        .toList(growable: false);
  }
}
