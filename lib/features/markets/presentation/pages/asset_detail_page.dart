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
import '../../../../shared/widgets/mini_sparkline.dart';
import '../../../trade/domain/entities/quote.dart';
import '../../../trade/domain/usecases/execute_trade.dart';
import '../../../wallet/domain/usecases/get_balances.dart';
import '../../domain/entities/ohlc.dart';
import '../../domain/repositories/markets_repository.dart';
import '../bloc/asset_detail_cubit.dart';
import '../bloc/asset_detail_state.dart';
import '../bloc/asset_trade_cubit.dart';
import '../bloc/asset_trade_state.dart';

class AssetDetailPage extends StatelessWidget {
  const AssetDetailPage({required this.symbol, super.key});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final pair = _resolvePair(symbol);
    final getIt = GetIt.I;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AssetDetailCubit(getIt<MarketsRepository>())..load(symbol),
        ),
        BlocProvider(
          create: (_) => AssetTradeCubit(
            executeTrade: getIt<ExecuteTrade>(),
            getBalances: getIt<GetBalances>(),
            baseSymbol: pair.base,
            quoteSymbol: pair.quote,
          )..initialize(),
        ),
      ],
      child: _AssetDetailView(symbol: symbol, pair: pair),
    );
  }
}

class _AssetDetailView extends StatefulWidget {
  const _AssetDetailView({required this.symbol, required this.pair});

  final String symbol;
  final _PairSymbols pair;

  @override
  State<_AssetDetailView> createState() => _AssetDetailViewState();
}

class _AssetDetailViewState extends State<_AssetDetailView> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetDetailCubit, AssetDetailState>(
      listenWhen: (previous, current) => previous.ticker?.price != current.ticker?.price,
      listener: (context, state) {
        final price = state.ticker?.price;
        if (price != null) {
          context.read<AssetTradeCubit>().setPrice(price);
        }
      },
      child: BlocListener<AssetTradeCubit, AssetTradeState>(
        listenWhen: (previous, current) => previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.successMessage != null && state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
            _amountController.clear();
          }
        },
        child: BlocBuilder<AssetDetailCubit, AssetDetailState>(
          builder: (context, detailState) {
            return BlocBuilder<AssetTradeCubit, AssetTradeState>(
              builder: (context, tradeState) {
                return AppPage(
                  children: [
                    _buildHeader(detailState),
                    _buildPriceCard(detailState),
                    _buildChart(detailState),
                    _buildStats(detailState),
                    _buildTradingCard(context, tradeState),
                    if (detailState.errorMessage != null)
                      Text(
                        detailState.errorMessage!,
                        style: AppTypography.bodySm.copyWith(color: AppColors.danger),
                      ),
                    if (tradeState.errorMessage != null)
                      Text(
                        tradeState.errorMessage!,
                        style: AppTypography.bodySm.copyWith(color: AppColors.danger),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AssetDetailState state) {
    final title = state.assetName ?? widget.symbol;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: AppColors.primaryButton,
            ),
            alignment: Alignment.center,
            child: Text(
              widget.pair.base.characters.take(3).toString(),
              style: AppTypography.titleMd.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLg),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Datos en vivo y trading para /',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(AssetDetailState state) {
    final price = state.ticker?.price;
    final change = state.ticker?.change24h;
    final changeColor = (change ?? 0) >= 0 ? AppColors.success : AppColors.danger;
    final range = _rangeText(state.ohlc);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Precio actual', style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            price != null ? Formatters.formatCurrency(price) : '--',
            style: AppTypography.titleLg.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  change != null ? '${change.toStringAsFixed(2)}% 24h' : '0.00% 24h',
                  style: AppTypography.bodySm.copyWith(color: changeColor, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Rango 24h: $range',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(AssetDetailState state) {
    final values = state.ohlc.map((item) => item.close).toList();
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Grafico de precio (1h)', style: AppTypography.titleSm),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppColors.bgInput.withValues(alpha: 0.6),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: values.isEmpty
                ? Center(
                    child: Text(
                      'Sin datos recientes',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                : MiniSparkline(
                    values: values,
                    color: values.isNotEmpty && values.first <= values.last ? AppColors.success : AppColors.danger,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(AssetDetailState state) {
    final ticker = state.ticker;
    final marketCap = ticker?.marketCap;
    final volume = ticker?.volume24h;
    final dominance = ticker != null && (ticker.marketCap + ticker.volume24h) > 0
        ? (ticker.marketCap / (ticker.marketCap + ticker.volume24h)) * 100
        : null;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estadisticas del activo', style: AppTypography.titleSm),
          const SizedBox(height: AppSpacing.md),
          _StatRow(label: 'Cap. Mercado', value: marketCap != null ? Formatters.formatCompactCurrency(marketCap) : '--'),
          _StatRow(label: 'Volumen 24h', value: volume != null ? Formatters.formatCompactCurrency(volume) : '--'),
          _StatRow(
            label: 'Precio Apertura',
            value: state.ohlc.isNotEmpty ? Formatters.formatCurrency(state.ohlc.first.open) : '--',
          ),
          _StatRow(label: 'Dominio estimado', value: dominance != null ? '%' : '--'),
        ],
      ),
    );
  }

  Widget _buildTradingCard(BuildContext context, AssetTradeState state) {
    final isBuy = state.side == TradeSide.buy;
    final available = isBuy ? state.availableQuote : state.availableBase;
    final availableLabel = isBuy ? state.quoteSymbol : state.baseSymbol;
    final totalQuote = state.totalQuote;
    final isSubmitting = state.submitting;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trading', style: AppTypography.titleSm),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _TradeSidePill(
                label: 'Comprar',
                selected: isBuy,
                color: AppColors.success,
                onTap: () => context.read<AssetTradeCubit>().setSide(TradeSide.buy),
              ),
              const SizedBox(width: AppSpacing.sm),
              _TradeSidePill(
                label: 'Vender',
                selected: !isBuy,
                color: AppColors.danger,
                onTap: () => context.read<AssetTradeCubit>().setSide(TradeSide.sell),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Cantidad ',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final normalized = value.replaceAll(',', '.');
              final parsed = double.tryParse(normalized) ?? 0;
              context.read<AssetTradeCubit>().setAmount(parsed);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _TradeInfoRow(
            label: 'Precio',
            value: state.price > 0 ? Formatters.formatCurrency(state.price) : '--',
          ),
          const SizedBox(height: AppSpacing.xs),
          _TradeInfoRow(
            label: 'Total',
            value: totalQuote > 0 ? Formatters.formatCurrency(totalQuote) : '--',
          ),
          const SizedBox(height: AppSpacing.xs),
          _TradeInfoRow(
            label: 'Disponible',
            value: '${available.toStringAsFixed(available > 100 ? 2 : 4)} $availableLabel',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            label: isBuy ? 'Comprar ' : 'Vender ',
            icon: isBuy ? Icons.shopping_cart : Icons.sell,
            onPressed: isSubmitting ? null : () => context.read<AssetTradeCubit>().submit(),
          ),
          if (state.loadingBalances)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: LinearProgressIndicator(minHeight: 3),
            ),
        ],
      ),
    );
  }

  String _rangeText(List<OHLC> data) {
    if (data.isEmpty) return '--';
    final min = data.map((e) => e.low).reduce((a, b) => a < b ? a : b);
    final max = data.map((e) => e.high).reduce((a, b) => a > b ? a : b);
    return '${Formatters.formatCurrency(min)} - ${Formatters.formatCurrency(max)}';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
          ),
          Text(value, style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _TradeInfoRow extends StatelessWidget {
  const _TradeInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
        ),
        Text(value, style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TradeSidePill extends StatelessWidget {
  const _TradeSidePill({
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
                ? LinearGradient(colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0.65)])
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

class _PairSymbols {
  const _PairSymbols(this.base, this.quote);

  final String base;
  final String quote;
}

_PairSymbols _resolvePair(String symbol) {
  final upper = symbol.toUpperCase();
  const quotes = ['USDT', 'BUSD', 'USDC', 'FDUSD', 'TRY', 'USD'];
  for (final quote in quotes) {
    if (upper.endsWith(quote)) {
      final base = upper.substring(0, upper.length - quote.length);
      return _PairSymbols(base, quote);
    }
  }
  if (upper.length <= 3) {
    return _PairSymbols(upper, 'USDT');
  }
  final pivot = upper.length - 3;
  final base = upper.substring(0, pivot);
  final quote = upper.substring(pivot);
  return _PairSymbols(base.isEmpty ? upper : base, quote);
}
