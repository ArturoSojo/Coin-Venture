import 'package:equatable/equatable.dart';

import '../../domain/entities/ohlc.dart';
import '../../domain/entities/ticker.dart';

enum AssetDetailStatus { initial, loading, loaded, failure }

class AssetDetailState extends Equatable {
  const AssetDetailState({
    this.status = AssetDetailStatus.initial,
    this.symbol = '',
    this.assetName,
    this.ticker,
    this.ohlc = const [],
    this.errorMessage,
  });

  final AssetDetailStatus status;
  final String symbol;
  final String? assetName;
  final Ticker? ticker;
  final List<OHLC> ohlc;
  final String? errorMessage;

  AssetDetailState copyWith({
    AssetDetailStatus? status,
    String? symbol,
    String? assetName,
    Ticker? ticker,
    List<OHLC>? ohlc,
    String? errorMessage,
  }) {
    return AssetDetailState(
      status: status ?? this.status,
      symbol: symbol ?? this.symbol,
      assetName: assetName ?? this.assetName,
      ticker: ticker ?? this.ticker,
      ohlc: ohlc ?? this.ohlc,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, symbol, assetName, ticker, ohlc, errorMessage];
}
