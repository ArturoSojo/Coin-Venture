import '../../domain/entities/crypto_asset.dart';

class ProductModel extends CryptoAsset {
  const ProductModel({
    required super.id,
    required super.symbol,
    required super.name,
    super.iconUrl,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      symbol: map['symbol'] as String,
      name: map['name'] as String,
      iconUrl: map['iconUrl'] as String?,
    );
  }
}
