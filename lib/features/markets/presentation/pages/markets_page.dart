import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_spacing.dart';
import '../../../../shared/styles/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/mini_sparkline.dart';
import '../../domain/entities/ticker.dart';
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

class _MarketsView extends StatefulWidget {
  const _MarketsView();

  @override
  State<_MarketsView> createState() => _MarketsViewState();
}

class _MarketsViewState extends State<_MarketsView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MarketsBloc>();

    return BlocBuilder<MarketsBloc, MarketsState>(
      builder: (context, state) {
        return AppPage(
          children: [
            AppSectionHeader(
              title: 'Mercados de Criptomonedas',
              subtitle: 'Actualizacion automatica cada 30 segundos',
              action: AppButton.ghost(
                label: 'Actualizar',
                icon: Icons.refresh_rounded,
                onPressed: () => bloc.add(MarketsRefreshRequested()),
              ),
            ),
            _MetricsRow(tickers: state.tickers),
            _FiltersBar(
              controller: _searchController,
              onQueryChanged: (value) => bloc.add(MarketsSearchChanged(value)),
              sort: state.sort,
              onSortSelected: (value) => bloc.add(MarketsSortChanged(value)),
            ),
            _MarketsTable(state: state),
          ],
        );
      },
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.controller,
    required this.onQueryChanged,
    required this.sort,
    required this.onSortSelected,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final MarketSortOption sort;
  final ValueChanged<MarketSortOption> onSortSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Buscar por nombre o simbolo',
            hint: 'Ej: BTC, Ethereum...',
            controller: controller,
            prefixIcon: Icons.search,
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: MarketSortOption.values
                .map(
                  (option) => _SortChip(
                    label: _sortLabel(option),
                    selected: option == sort,
                    onTap: () => onSortSelected(option),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
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
          label,
          style: AppTypography.bodySm.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.tickers});

  final List<Ticker> tickers;

  @override
  Widget build(BuildContext context) {
    final totalMarketCap = tickers.fold<double>(0, (acc, t) => acc + t.marketCap);
    final volume24h = tickers.fold<double>(0, (acc, t) => acc + t.volume24h);
    final btcDominance = tickers.isEmpty ? 0 : (tickers.first.marketCap / (totalMarketCap == 0 ? 1 : totalMarketCap)) * 100;
    final coins = tickers.length;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _MetricCard(
          icon: Icons.domain_outlined,
          title: 'Cap. Total',
          value: Formatters.formatCompactCurrency(totalMarketCap),
        ),
        _MetricCard(
          icon: Icons.trending_up_rounded,
          title: 'Vol. 24h',
          value: Formatters.formatCompactCurrency(volume24h),
        ),
        _MetricCard(
          icon: Icons.show_chart,
          title: 'BTC Dom.',
          value: '${btcDominance.isNaN ? 0 : btcDominance.toStringAsFixed(2)}%',
        ),
        _MetricCard(
          icon: Icons.ssid_chart_rounded,
          title: 'Monedas',
          value: coins.toString(),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      gradient: LinearGradient(
        colors: [
          AppColors.bgCard.withValues(alpha: 0.9),
          AppColors.bgSecondary.withValues(alpha: 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.titleMd.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarketsTable extends StatelessWidget {
  const _MarketsTable({required this.state});

  final MarketsState state;

  Color _changeColor(double change) => change >= 0 ? AppColors.success : AppColors.danger;

  @override
  Widget build(BuildContext context) {
    if (state.status == MarketsStatus.loading) {
      return const AppCard(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == MarketsStatus.failure) {
      return AppCard(
        child: Center(
          child: Text(
            state.errorMessage ?? 'Error al cargar mercados',
            style: AppTypography.bodyMd.copyWith(color: AppColors.danger),
          ),
        ),
      );
    }

    if (state.tickers.isEmpty) {
      return const AppCard(
        child: Center(
          child: Text(
            'Sin resultados por ahora',
            style: AppTypography.bodyMd,
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TableHeader(),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < state.tickers.length; i++) ...[
            _TableRow(
              index: i + 1,
              ticker: state.tickers[i],
              changeColor: _changeColor(state.tickers[i].change24h),
            ),
            if (i != state.tickers.length - 1)
              Divider(color: AppColors.divider.withValues(alpha: 0.4)),
          ],
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _HeaderCell(label: '#', flex: 1),
          _HeaderCell(label: 'Moneda', flex: 4),
          _HeaderCell(label: 'Precio', flex: 3),
          _HeaderCell(label: '24h %', flex: 2, textAlign: TextAlign.right),
          _HeaderCell(label: 'Cap. Mercado', flex: 3, textAlign: TextAlign.right),
          _HeaderCell(label: 'Volumen', flex: 3, textAlign: TextAlign.right),
          _HeaderCell(label: 'Ultimos 7 dias', flex: 3, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.flex,
    this.textAlign = TextAlign.left,
  });

  final String label;
  final int flex;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: textAlign,
        style: AppTypography.bodySm.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.index,
    required this.ticker,
    required this.changeColor,
  });

  final int index;
  final Ticker ticker;
  final Color changeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/home/markets/${ticker.symbol}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '$index',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _symbolName(ticker.symbol),
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ticker.symbol,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                Formatters.formatCurrency(ticker.price),
                style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${ticker.change24h.toStringAsFixed(2)}%',
                    style: AppTypography.bodySm.copyWith(color: changeColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                Formatters.formatCompactCurrency(ticker.marketCap),
                textAlign: TextAlign.right,
                style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                Formatters.formatCompactCurrency(ticker.volume24h),
                textAlign: TextAlign.right,
                style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: MiniSparkline(
                  values: ticker.sparkline,
                  color: changeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _sortLabel(MarketSortOption option) {
  switch (option) {
    case MarketSortOption.marketCap:
      return 'Cap. Mercado';
    case MarketSortOption.volume:
      return 'Volumen 24h';
    case MarketSortOption.change:
      return '% 24h';
  }
}

String _symbolName(String symbol) {
  if (symbol.length <= 3) return symbol.toUpperCase();
  final letters = symbol.replaceAll(RegExp(r'[^A-Za-z]'), '');
  if (letters.length <= 3) return letters.toUpperCase();
  return letters.substring(0, 3).toUpperCase();
}
