import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'core/config/theme.dart';
import 'core/routing/app_router.dart';
import 'shared/styles/app_colors.dart';
import 'shared/styles/app_spacing.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

class CoinVentureApp extends StatelessWidget {
  const CoinVentureApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GetIt.I<AppRouter>().router;
    return BlocProvider(
      create: (_) => GetIt.I<AuthBloc>()..add(AuthStarted()),
      child: MaterialApp.router(
        title: 'Coin Venture',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: router,
        builder: (context, child) {
          final theme = Theme.of(context);
          return DecoratedBox(
            decoration: const BoxDecoration(gradient: AppColors.appBackground),
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium,
              child: SafeArea(
                child: Padding(
                  padding: AppSpacing.screenInsets,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
