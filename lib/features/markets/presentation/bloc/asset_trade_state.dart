import 'package:equatable/equatable.dart';

import '../../../trade/domain/entities/quote.dart';

class AssetTradeState extends Equatable {
  const AssetTradeState({
    required this.baseSymbol,
    required this.quoteSymbol,
    this.side = TradeSide.buy,
    this.amount = 0,
    this.price = 0,
    this.availableBase = 0,
    this.availableQuote = 0,
    this.loadingBalances = true,
    this.submitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final String baseSymbol;
  final String quoteSymbol;
  final TradeSide side;
  final double amount;
  final double price;
  final double availableBase;
  final double availableQuote;
  final bool loadingBalances;
  final bool submitting;
  final String? errorMessage;
  final String? successMessage;

  double get totalQuote => amount * price;

  AssetTradeState copyWith({
    String? baseSymbol,
    String? quoteSymbol,
    TradeSide? side,
    double? amount,
    double? price,
    double? availableBase,
    double? availableQuote,
    bool? loadingBalances,
    bool? submitting,
    String? errorMessage,
    String? successMessage,
  }) {
    return AssetTradeState(
      baseSymbol: baseSymbol ?? this.baseSymbol,
      quoteSymbol: quoteSymbol ?? this.quoteSymbol,
      side: side ?? this.side,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      availableBase: availableBase ?? this.availableBase,
      availableQuote: availableQuote ?? this.availableQuote,
      loadingBalances: loadingBalances ?? this.loadingBalances,
      submitting: submitting ?? this.submitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        baseSymbol,
        quoteSymbol,
        side,
        amount,
        price,
        availableBase,
        availableQuote,
        loadingBalances,
        submitting,
        errorMessage,
        successMessage,
      ];
}
