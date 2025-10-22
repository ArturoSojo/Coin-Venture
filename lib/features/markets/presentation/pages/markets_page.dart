import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/repositories/markets_repository.dart';
import '../bloc/markets_bloc.dart';
import '../bloc/markets_event.dart';
import '../bloc/markets_state.dart';

class MarketsPage extends StatelessWidget {
  const MarketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<MarketsBloc>()..add(MarketsStarted()),
      child: const _MarketsView(),
    );
  }
}

class _MarketsView extends StatelessWidget {
  const _MarketsView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MarketsBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar activos',
                ),
                onChanged: (value) => bloc.add(MarketsSearchChanged(value)),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<MarketSortOption>(
              value: context.select((MarketsBloc bloc) => bloc.state.sort),
              onChanged: (value) {
                if (value != null) {
                  bloc.add(MarketsSortChanged(value));
                }
              },
              items: MarketSortOption.values
                  .map(
                    (option) => DropdownMenuItem(
                      value: option,
                      child: Text(option.name),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: BlocBuilder<MarketsBloc, MarketsState>(
            builder: (context, state) {
              if (state.status == MarketsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == MarketsStatus.failure) {
                return Center(child: Text(state.errorMessage ?? 'Error de carga'));
              }
              if (state.tickers.isEmpty) {
                return const Center(child: Text('Sin resultados por ahora'));
              }
              return ListView.separated(
                itemCount: state.tickers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final ticker = state.tickers[index];
                  return ListTile(
                    title: Text(ticker.symbol),
                    subtitle: Text('Cambio 24h: ${Formatters.formatPercent(ticker.change24h / 100)}'),
                    trailing: Text(Formatters.formatCurrency(ticker.price)),
                    onTap: () => context.go('/home/markets/${ticker.symbol}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
