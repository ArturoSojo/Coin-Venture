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

  factory AppSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const AppSettings();
    }
    return AppSettings(
      showMarkets: (map['showMarkets'] as bool?) ?? true,
      showPortfolio: (map['showPortfolio'] as bool?) ?? true,
      showHistory: (map['showHistory'] as bool?) ?? true,
      autoRefresh: (map['autoRefresh'] as bool?) ?? true,
      language: (map['language'] as String?) ?? 'es',
      currency: (map['currency'] as String?) ?? 'USD',
      twoFactorEnabled: (map['twoFactorEnabled'] as bool?) ?? false,
      biometricEnabled: (map['biometricEnabled'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showMarkets': showMarkets,
      'showPortfolio': showPortfolio,
      'showHistory': showHistory,
      'autoRefresh': autoRefresh,
      'language': language,
      'currency': currency,
      'twoFactorEnabled': twoFactorEnabled,
      'biometricEnabled': biometricEnabled,
    };
  }

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
