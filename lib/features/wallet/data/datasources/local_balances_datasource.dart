import '../../domain/entities/balance.dart';

abstract class LocalBalancesDataSource {
  Future<List<Balance>> fetchBalances();
}

class MockBalancesDataSource implements LocalBalancesDataSource {
  @override
  Future<List<Balance>> fetchBalances() async {
    return const [
      Balance(symbol: 'BTC', amount: 0.35),
      Balance(symbol: 'ETH', amount: 5.0),
      Balance(symbol: 'USDT', amount: 1000),
      Balance(symbol: 'USD', amount: 4500),
    ];
  }
}
