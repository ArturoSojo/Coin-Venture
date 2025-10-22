import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/markets/presentation/pages/asset_detail_page.dart';
import '../../features/markets/presentation/pages/markets_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/trade/presentation/pages/trade_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../shared/widgets/app_shell.dart';
import '../config/feature_flags.dart';
import 'guards.dart';

class AppRouter {
  AppRouter({required AuthGuard authGuard, required FeatureFlags featureFlags})
      : _authGuard = authGuard,
        _featureFlags = featureFlags;

  final AuthGuard _authGuard;
  final FeatureFlags _featureFlags;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _authGuard,
    redirect: _authGuard.redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home/markets',
            builder: (context, state) => const MarketsPage(),
            routes: [
              GoRoute(
                path: ':symbol',
                builder: (context, state) {
                  final symbol = state.pathParameters['symbol'] ?? 'BTCUSDT';
                  return AssetDetailPage(symbol: symbol);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/home/portfolio',
            builder: (context, state) => const WalletPage(),
          ),
          if (_featureFlags.historyEnabled)
            GoRoute(
              path: '/home/history',
              builder: (context, state) => const HistoryPage(),
            ),
          if (_featureFlags.settingsEnabled)
            GoRoute(
              path: '/home/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          GoRoute(
            path: '/home/trade',
            builder: (context, state) => const TradePage(),
          ),
        ],
      ),
    ],
  );
}
