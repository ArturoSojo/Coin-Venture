import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.showMarkets = true,
    this.showPortfolio = true,
    this.showHistory = true,
    this.autoRefresh = true,
    this.language = 'es',
    this.currency = 'USD',
    this.twoFactorEnabled = false,
    this.biometricEnabled = false,
  });

  final bool showMarkets;
  final bool showPortfolio;
  final bool showHistory;
  final bool autoRefresh;
  final String language;
  final String currency;
  final bool twoFactorEnabled;
  final bool biometricEnabled;

  AppSettings copyWith({
    bool? showMarkets,
    bool? showPortfolio,
    bool? showHistory,
    bool? autoRefresh,
    String? language,
    String? currency,
    bool? twoFactorEnabled,
    bool? biometricEnabled,
  }) {
    return AppSettings(
      showMarkets: showMarkets ?? this.showMarkets,
      showPortfolio: showPortfolio ?? this.showPortfolio,
      showHistory: showHistory ?? this.showHistory,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  @override
  List<Object?> get props => [
        showMarkets,
        showPortfolio,
        showHistory,
        autoRefresh,
        language,
        currency,
        twoFactorEnabled,
        biometricEnabled,
      ];
}
