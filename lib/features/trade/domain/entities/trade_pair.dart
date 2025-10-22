import 'package:equatable/equatable.dart';

class TradePair extends Equatable {
  const TradePair({
    required this.base,
    required this.quote,
  });

  final String base;
  final String quote;

  @override
  List<Object?> get props => [base, quote];

  String get symbol => '${base.toUpperCase()}${quote.toUpperCase()}';
}
