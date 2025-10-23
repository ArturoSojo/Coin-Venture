import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ohlc.dart';
import '../../domain/entities/ticker.dart';
import '../../domain/repositories/markets_repository.dart';
import 'asset_detail_state.dart';

class AssetDetailCubit extends Cubit<AssetDetailState> {
  AssetDetailCubit(this._repository) : super(const AssetDetailState());

  final MarketsRepository _repository;
  StreamSubscription<Ticker>? _tickerSubscription;

  Future<void> load(String symbol) async {
    emit(state.copyWith(status: AssetDetailStatus.loading, symbol: symbol, errorMessage: null));
    final assetResult = await _repository.getAsset(symbol);
    final ohlcResult = await _repository.getOhlc(symbol);

    String? assetName;
    assetResult.fold(
      (_) {},
      (asset) => assetName = asset.name,
    );

    List<OHLC> ohlcData = const [];
    String? loadError;
    ohlcResult.fold(
      (failure) => loadError = failure.message,
      (data) => ohlcData = data,
    );

    emit(
      state.copyWith(
        assetName: assetName ?? _formatSymbol(symbol),
        ohlc: ohlcData,
        errorMessage: loadError,
      ),
    );

    await _tickerSubscription?.cancel();
    _tickerSubscription = _repository.watchTicker(symbol).listen(
      (ticker) {
        emit(
          state.copyWith(
            status: AssetDetailStatus.loaded,
            ticker: ticker,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: AssetDetailStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _tickerSubscription?.cancel();
    return super.close();
  }

  String _formatSymbol(String symbol) {
    if (symbol.length <= 3) return symbol.toUpperCase();
    return symbol.toUpperCase().replaceAllMapped(RegExp(r'([A-Z]{3,4})$'), (match) {
      final quote = match.group(0);
      if (quote == null) return symbol.toUpperCase();
      final base = symbol.substring(0, symbol.length - quote.length).toUpperCase();
      return '$base/$quote';
    });
  }
}
