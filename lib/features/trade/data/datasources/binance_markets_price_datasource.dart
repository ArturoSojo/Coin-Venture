import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/trade_pair.dart';
import 'markets_datasource.dart';

class BinanceMarketsPriceDataSource implements MarketsPriceDataSource {
  BinanceMarketsPriceDataSource(this._dio);

  final Dio _dio;

  @override
  Future<double> fetchPrice(TradePair pair) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v3/ticker/price',
        queryParameters: <String, dynamic>{'symbol': pair.symbol},
      );
      final data = response.data;
      final priceRaw = data?['price'];
      if (priceRaw == null) {
        throw const ServerException(message: 'Precio no disponible');
      }
      final price = double.tryParse(priceRaw.toString());
      if (price == null) {
        throw const ServerException(message: 'Precio invalido');
      }
      return price;
    } on DioException catch (error) {
      throw ServerException(message: error.message);
    }
  }
}
