import 'package:equatable/equatable.dart';

class CryptoAsset extends Equatable {
  const CryptoAsset({
    required this.id,
    required this.symbol,
    required this.name,
    this.iconUrl,
  });

  final String id;
  final String symbol;
  final String name;
  final String? iconUrl;

  @override
  List<Object?> get props => [id, symbol, name, iconUrl];
}
