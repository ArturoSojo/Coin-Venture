import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../config/env.dart';
import '../config/feature_flags.dart';
import '../network/dio_client.dart';
import '../routing/app_router.dart';
import '../routing/guards.dart';
import '../security/token_store.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/datasources/mock_user_profile_datasource.dart';
import '../../features/auth/data/datasources/user_profile_datasource.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in_email.dart';
import '../../features/auth/domain/usecases/sign_in_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_email.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/history/data/datasources/local_history_datasource.dart';
import '../../features/history/data/repositories_impl/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/add_transaction.dart';
import '../../features/history/domain/usecases/get_transactions.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/markets/data/datasources/binance_remote_datasource.dart';
import '../../features/markets/data/repositories_impl/markets_repository_impl.dart';
import '../../features/markets/domain/repositories/markets_repository.dart';
import '../../features/markets/domain/usecases/get_markets.dart';
import '../../features/markets/presentation/bloc/markets_bloc.dart';
import '../../features/settings/data/datasources/local_settings_datasource.dart';
import '../../features/settings/data/repositories_impl/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/save_settings.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/trade/data/datasources/mock_trade_datasources.dart';
import '../../features/trade/data/datasources/markets_datasource.dart';
import '../../features/trade/data/repositories_impl/trade_repository_impl.dart';
import '../../features/trade/domain/repositories/trade_repository.dart';
import '../../features/trade/domain/usecases/execute_trade.dart';
import '../../features/trade/domain/usecases/get_pairs.dart';
import '../../features/trade/domain/usecases/get_quote.dart';
import '../../features/trade/presentation/bloc/trade_bloc.dart';
import '../../features/wallet/data/datasources/local_balances_datasource.dart';
import '../../features/wallet/data/repositories_impl/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/get_balances.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final env = AppEnv.current;
  sl
    ..registerSingleton<AppEnv>(env)
    ..registerSingleton<FeatureFlags>(FeatureFlags.defaultFlags)
    ..registerLazySingleton<TokenStore>(TokenStore.create)
    ..registerLazySingleton<Dio>(() => buildDioClient(env));

  // Auth
  sl
    ..registerLazySingleton<FirebaseAuthDataSource>(() => FirebaseAuthDataSourceImpl())
    ..registerLazySingleton<UserProfileDataSource>(MockUserProfileDataSource.new)
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: sl<FirebaseAuthDataSource>(),
        profile: sl<UserProfileDataSource>(),
        tokenStore: sl<TokenStore>(),
      ),
    )
    ..registerLazySingleton(() => SignInEmail(sl()))
    ..registerLazySingleton(() => SignUpEmail(sl()))
    ..registerLazySingleton(() => SignInGoogle(sl()))
    ..registerLazySingleton(() => SignOut(sl()))
    ..registerLazySingleton(() => GetCurrentUser(sl()))
    ..registerFactory(
      () => AuthBloc(
        repository: sl<AuthRepository>(),
        signInEmail: sl<SignInEmail>(),
        signUpEmail: sl<SignUpEmail>(),
        signInGoogle: sl<SignInGoogle>(),
        signOut: sl<SignOut>(),
        getCurrentUser: sl<GetCurrentUser>(),
      ),
    );

  // Markets
  sl
    ..registerLazySingleton<BinanceRemoteDataSource>(() => BinanceRemoteDataSourceImpl(sl()))
    ..registerLazySingleton<MarketsRepository>(() => MarketsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetMarkets(sl()))
    ..registerFactory(() => MarketsBloc(sl<GetMarkets>()));

  // Wallet
  sl
    ..registerLazySingleton<LocalBalancesDataSource>(MockBalancesDataSource.new)
    ..registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetBalances(sl()))
    ..registerFactory(() => WalletBloc(sl<GetBalances>()));

  // Trade
  sl
    ..registerLazySingleton<MarketsPriceDataSource>(MockMarketsPriceDataSource.new)
    ..registerLazySingleton<LocalTradeDataSource>(MockLocalTradeDataSource.new)
    ..registerLazySingleton<TradeRepository>(
      () => TradeRepositoryImpl(
        marketsDataSource: sl<MarketsPriceDataSource>(),
        localTradeDataSource: sl<LocalTradeDataSource>(),
        walletRepository: sl<WalletRepository>(),
      ),
    )
    ..registerLazySingleton(() => GetPairs(sl()))
    ..registerLazySingleton(() => GetQuote(sl()))
    ..registerLazySingleton(() => ExecuteTrade(sl()))
    ..registerFactory(
      () => TradeBloc(
        getPairs: sl<GetPairs>(),
        getQuote: sl<GetQuote>(),
        executeTrade: sl<ExecuteTrade>(),
      ),
    );

  // History
  sl
    ..registerLazySingleton<LocalHistoryDataSource>(MemoryHistoryDataSource.new)
    ..registerLazySingleton<HistoryRepository>(() => HistoryRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetTransactions(sl()))
    ..registerLazySingleton(() => AddTransaction(sl()))
    ..registerFactory(
      () => HistoryBloc(
        getTransactions: sl<GetTransactions>(),
        addTransaction: sl<AddTransaction>(),
      ),
    );

  // Settings
  sl
    ..registerLazySingleton<LocalSettingsDataSource>(MemorySettingsDataSource.new)
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetSettings(sl()))
    ..registerLazySingleton(() => SaveSettings(sl()))
    ..registerFactory(
      () => SettingsBloc(
        getSettings: sl<GetSettings>(),
        saveSettings: sl<SaveSettings>(),
      ),
    );

  // Guards and router
  sl
    ..registerLazySingleton<AuthGuard>(() => AuthGuard(sl<AuthRepository>()))
    ..registerLazySingleton<AppRouter>(
      () => AppRouter(
        authGuard: sl<AuthGuard>(),
        featureFlags: sl<FeatureFlags>(),
      ),
    );
}
