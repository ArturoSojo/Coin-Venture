import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/formatters.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<WalletBloc>()..add(WalletStarted()),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state.status == WalletStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == WalletStatus.failure) {
          return Center(child: Text(state.errorMessage ?? 'Error cargando balances'));
        }
        if (state.balances.isEmpty) {
          return const Center(child: Text('Sin balances disponibles.'));
        }
        return ListView(
          children: [
            ListTile(
              title: const Text('Valor total del portafolio'),
              subtitle: Text('Activo principal y diversificación'),
              trailing: Text(Formatters.formatCurrency(state.totalAssets)),
            ),
            for (final balance in state.balances)
              ListTile(
                title: Text(balance.symbol),
                trailing: Text(balance.amount.toStringAsFixed(2)),
              ),
          ],
        );
      },
    );
  }
}
