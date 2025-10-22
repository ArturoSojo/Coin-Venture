import 'package:equatable/equatable.dart';

import '../../domain/entities/balance.dart';

enum WalletStatus { initial, loading, loaded, failure }

class WalletState extends Equatable {
  const WalletState({
    this.status = WalletStatus.initial,
    this.balances = const [],
    this.errorMessage,
  });

  final WalletStatus status;
  final List<Balance> balances;
  final String? errorMessage;

  WalletState copyWith({
    WalletStatus? status,
    List<Balance>? balances,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      balances: balances ?? this.balances,
      errorMessage: errorMessage,
    );
  }

  double get totalAssets => balances.fold(0, (prev, balance) => prev + balance.amount);

  @override
  List<Object?> get props => [status, balances, errorMessage];
}
