import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/formatters.dart';
import '../../../trade/domain/entities/quote.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<HistoryBloc>()..add(HistoryStarted()),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state.status == HistoryStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == HistoryStatus.failure) {
          return Center(child: Text(state.errorMessage ?? 'Error al cargar historial'));
        }
        if (state.transactions.isEmpty) {
          return const Center(child: Text('Sin transacciones aún.')); 
        }
        return ListView.builder(
          itemCount: state.transactions.length,
          itemBuilder: (context, index) {
            final transaction = state.transactions[index];
            return ListTile(
              leading: Chip(label: Text(transaction.side == TradeSide.buy ? 'Compra' : 'Venta')),
              title: Text(transaction.pair.symbol),
              subtitle: Text('${transaction.amountBase} @ ${Formatters.formatCurrency(transaction.price)}'),
              trailing: Text(transaction.timestamp.toLocal().toIso8601String()),
            );
          },
        );
      },
    );
  }
}
