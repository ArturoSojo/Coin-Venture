// app_env.dart
import 'package:firebase_core/firebase_core.dart';

class AppEnv {
  const AppEnv({
    required this.binanceBaseUrl,
    required this.firebaseOptions,
  });

  final String binanceBaseUrl;
  final FirebaseOptions firebaseOptions;

  // Puedes duplicar y crear un AppEnv.prod con tus valores de prod
  static const AppEnv dev = AppEnv(
    binanceBaseUrl: 'https://api.binance.com/api/v3/ticker/24hr',
    firebaseOptions: FirebaseOptions(
      apiKey: 'AIzaSyDcMXkwN3hc9GOv3ZiW5Hcd0ySNGASMjfQ',
      authDomain: 'coin-venture-4eec3.firebaseapp.com',
      projectId: 'coin-venture-4eec3',
      storageBucket: 'coin-venture-4eec3.appspot.com',
      messagingSenderId: '414601306551',
      appId: '1:414601306551:web:6cc1cb72c484c42e108832',
      measurementId: 'G-GRTFDYJP11',
    ),
  );

  static const String _flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static AppEnv get current {
    switch (_flavor) {
      case 'dev':
      default:
        return dev;
    }
  }
}
