import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../domain/entities/exchange_result.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/trade_pair.dart';
import '../../domain/repositories/trade_repository.dart';
import '../datasources/markets_datasource.dart';

class TradeRepositoryImpl implements TradeRepository {
  TradeRepositoryImpl({
    required MarketsPriceDataSource marketsDataSource,
    required LocalTradeDataSource localTradeDataSource,
    required WalletRepository walletRepository,
  })  : _marketsDataSource = marketsDataSource,
        _localTradeDataSource = localTradeDataSource,
        _walletRepository = walletRepository;

  final MarketsPriceDataSource _marketsDataSource;
  final LocalTradeDataSource _localTradeDataSource;
  final WalletRepository _walletRepository;

  @override
  Future<Either<Failure, ExchangeResult>> executeOrder({
    required TradePair pair,
    required TradeSide side,
    required double amount,
  }) async {
    try {
      final price = await _marketsDataSource.fetchPrice(pair);
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pair: pair,
        side: side,
        amountBase: amount,
        price: price,
        createdAt: DateTime.now(),
      );
      await _localTradeDataSource.persistOrder(
        pair: pair,
        side: side,
        amount: amount,
      );
      return Right(ExchangeResult(
        order: order.copyWith(status: OrderStatus.filled),
        message: 'Orden ejecutada de manera simulada',
      ));
    } on ServerException catch (error) {
      return Left(NetworkFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, Quote>> getQuote({
    required TradePair pair,
    required TradeSide side,
    required double amount,
  }) async {
    try {
      final price = await _marketsDataSource.fetchPrice(pair);
      final quote = Quote(
        pair: pair,
        side: side,
        price: price,
        expiresAt: DateTime.now().add(const Duration(seconds: 30)),
      );
      return Right(quote);
    } on ServerException catch (error) {
      return Left(NetworkFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<TradePair>>> getPairs() async {
    try {
      final balancesResult = await _walletRepository.getBalances();
      return balancesResult.fold(
        (failure) => Left(failure),
        (balances) {
          final pairs = balances
              .map((balance) => TradePair(base: balance.symbol, quote: 'USDT'))
              .toList();
          return Right(pairs);
        },
      );
    } on CacheException catch (error) {
      return Left(CacheFailure(message: error.message));
    }
  }
}
