class AppEnv {
  const AppEnv({
    required this.binanceBaseUrl,
    required this.firebaseOptions,
  });

  final String binanceBaseUrl;
  final Map<String, Object?> firebaseOptions;

  static AppEnv dev() => const AppEnv(
        binanceBaseUrl: 'https://api.binance.com',
        firebaseOptions: <String, Object?>{},
      );
}
