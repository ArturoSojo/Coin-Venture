import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_spacing.dart';
import '../../../../shared/styles/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/app_text_field.dart';
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
            SnackBar(
              content: Text(state.result!.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<TradeBloc>();
        return AppPage(
          children: [
            _TradeHeader(
              pairs: state.pairs,
              selectedPair: state.selectedPair,
              onPairSelected: (pair) => bloc.add(TradePairSelected(pair)),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 1000;
                final children = [
                  Expanded(
                    flex: 3,
                    child: _ChartPanel(pair: state.selectedPair),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: _TradeForm(
                      state: state,
                      onSideChanged: (side) => bloc.add(TradeSideChanged(side)),
                      onAmountChanged: (value) => bloc.add(TradeAmountChanged(value)),
                      onQuote: () => bloc.add(TradeQuoteRequested()),
                      onSubmit: () => bloc.add(TradeSubmitted()),
                    ),
                  ),
                ];
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ChartPanel(pair: state.selectedPair),
                    const SizedBox(height: AppSpacing.lg),
                    _TradeForm(
                      state: state,
                      onSideChanged: (side) => bloc.add(TradeSideChanged(side)),
                      onAmountChanged: (value) => bloc.add(TradeAmountChanged(value)),
                      onQuote: () => bloc.add(TradeQuoteRequested()),
                      onSubmit: () => bloc.add(TradeSubmitted()),
                    ),
                  ],
                );
              },
            ),
            if (state.errorMessage != null)
              AppCard(
                child: Text(
                  state.errorMessage!,
                  style: AppTypography.bodySm.copyWith(color: AppColors.danger),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TradeHeader extends StatelessWidget {
  const _TradeHeader({
    required this.pairs,
    required this.selectedPair,
    required this.onPairSelected,
  });

  final List<TradePair> pairs;
  final TradePair? selectedPair;
  final ValueChanged<TradePair> onPairSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trading', style: AppTypography.titleMd),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Selecciona un par de mercado para comenzar tu operacion',
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: pairs
                .map(
                  (pair) => _PairChip(
                    pair: pair,
                    selected: pair == selectedPair,
                    onTap: () => onPairSelected(pair),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PairChip extends StatelessWidget {
  const _PairChip({
    required this.pair,
    required this.selected,
    required this.onTap,
  });

  final TradePair pair;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryButton : null,
          color: selected ? null : AppColors.bgInput.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          pair.symbol,
          style: AppTypography.bodySm.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({required this.pair});

  final TradePair? pair;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pair?.symbol ?? 'Selecciona un par',
            style: AppTypography.titleMd,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Grafico de precio (simulado)',
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  AppColors.bgInput.withValues(alpha: 0.6),
                  AppColors.bgSecondary.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.show_chart, color: AppColors.textSecondary, size: 48),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Los datos graficos se muestran con fines ilustrativos.',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _TradeForm extends StatefulWidget {
  const _TradeForm({
    required this.state,
    required this.onSideChanged,
    required this.onAmountChanged,
    required this.onQuote,
    required this.onSubmit,
  });

  final TradeState state;
  final ValueChanged<TradeSide> onSideChanged;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onQuote;
  final VoidCallback onSubmit;

  @override
  State<_TradeForm> createState() => _TradeFormState();
}

class _TradeFormState extends State<_TradeForm> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount(String value) {
    final parsed = double.tryParse(value) ?? 0;
    widget.onAmountChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final quote = state.quote;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Panel de operacion', style: AppTypography.titleMd),
          const SizedBox(height: AppSpacing.md),
          _SideSelector(
            current: state.side,
            onChanged: widget.onSideChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Cantidad ${state.selectedPair?.base ?? ''}',
            hint: '0.00',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.token_rounded,
            onChanged: _updateAmount,
          ),
          const SizedBox(height: AppSpacing.md),
          _QuoteInfo(quote: quote),
          const SizedBox(height: AppSpacing.lg),
          AppButton.secondary(
            label: 'Obtener cotizacion',
            icon: Icons.price_change_outlined,
            onPressed: widget.onQuote,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton.primary(
            label: state.side == TradeTab.buy ? 'Comprar' : 'Vender',
            icon: state.side == TradeTab.buy ? Icons.shopping_cart : Icons.sell,
            onPressed: quote == null ? null : widget.onSubmit,
          ),
        ],
      ),
    );
  }
}

class _SideSelector extends StatelessWidget {
  const _SideSelector({
    required this.current,
    required this.onChanged,
  });

  final TradeTab current;
  final ValueChanged<TradeSide> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SidePill(
          label: 'Comprar',
          selected: current == TradeTab.buy,
          color: AppColors.success,
          onTap: () => onChanged(TradeSide.buy),
        ),
        const SizedBox(width: AppSpacing.sm),
        _SidePill(
          label: 'Vender',
          selected: current == TradeTab.sell,
          color: AppColors.danger,
          onTap: () => onChanged(TradeSide.sell),
        ),
      ],
    );
  }
}

class _SidePill extends StatelessWidget {
  const _SidePill({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.8),
                      color.withValues(alpha: 0.6),
                    ],
                  )
                : null,
            color: selected ? null : AppColors.bgInput.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? color : AppColors.divider),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuoteInfo extends StatelessWidget {
  const _QuoteInfo({required this.quote});

  final Quote? quote;

  @override
  Widget build(BuildContext context) {
    if (quote == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgInput.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          'Solicita una cotizacion para ver el precio estimado.',
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgInput.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cotizacion estimada', style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.formatCurrency(quote!.price),
            style: AppTypography.titleMd.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Vence en 30 segundos',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
