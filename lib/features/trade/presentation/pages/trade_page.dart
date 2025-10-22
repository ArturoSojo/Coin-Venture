import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/trade_pair.dart';
import '../bloc/trade_bloc.dart';
import '../bloc/trade_event.dart';
import '../bloc/trade_state.dart';

class TradePage extends StatelessWidget {
  const TradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<TradeBloc>()..add(TradeStarted()),
      child: const _TradeView(),
    );
  }
}

class _TradeView extends StatelessWidget {
  const _TradeView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TradeBloc, TradeState>(
      listener: (context, state) {
        if (state.status == TradeStatus.success && state.result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.result!.message)),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<TradeBloc>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<TradePair>(
              value: state.selectedPair,
              hint: const Text('Selecciona un par'),
              onChanged: (pair) {
                if (pair != null) {
                  bloc.add(TradePairSelected(pair));
                }
              },
              items: state.pairs
                  .map(
                    (pair) => DropdownMenuItem(
                      value: pair,
                      child: Text(pair.symbol),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            ToggleButtons(
              isSelected: [state.side == TradeTab.buy, state.side == TradeTab.sell],
              onPressed: (index) {
                bloc.add(TradeSideChanged(index == 0 ? TradeSide.buy : TradeSide.sell));
              },
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Comprar')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Vender')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              onChanged: (value) => bloc.add(TradeAmountChanged(double.tryParse(value) ?? 0)),
            ),
            const SizedBox(height: 12),
            if (state.quote != null)
              Text('Precio estimado: ${Formatters.formatCurrency(state.quote!.price)}'),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => bloc.add(TradeQuoteRequested()),
                  child: const Text('Cotizar'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: state.quote == null ? null : () => bloc.add(TradeSubmitted()),
                  child: const Text('Ejecutar'),
                ),
              ],
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(state.errorMessage!, style: const TextStyle(color: Colors.redAccent)),
              ),
          ],
        );
      },
    );
  }
}
