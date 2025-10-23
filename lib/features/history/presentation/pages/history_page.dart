import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_spacing.dart';
import '../../../../shared/styles/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../trade/domain/entities/quote.dart';
import '../../domain/entities/transaction.dart';
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
        switch (state.status) {
          case HistoryStatus.initial:
          case HistoryStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case HistoryStatus.failure:
            return Center(
              child: AppCard(
                child: Text(
                  state.errorMessage ?? 'No se pudo cargar el historial',
                  style: AppTypography.bodySm.copyWith(color: AppColors.danger),
                ),
              ),
            );
          case HistoryStatus.loaded:
            return _HistoryContent(state: state);
        }
      },
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) {
    final totalOperations = state.transactions.length;
    final buys = state.transactions.where((t) => t.side == TradeSide.buy).length;
    final sells = totalOperations - buys;

    return AppPage(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Historial de operaciones', style: AppTypography.titleMd),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Registro completo de tus transacciones',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _HistoryStat(
                    icon: Icons.check_circle_outline,
                    label: 'Operaciones',
                    value: totalOperations.toString(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _HistoryStat(
                    icon: Icons.call_made_outlined,
                    label: 'Compras',
                    value: buys.toString(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _HistoryStat(
                    icon: Icons.call_received_outlined,
                    label: 'Ventas',
                    value: sells.toString(),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (state.transactions.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_toggle_off, color: AppColors.textSecondary, size: 56),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Sin transacciones aun',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Comienza a operar para ver tu historial aqui',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final transaction in state.transactions) ...[
                  _HistoryRow(transaction: transaction),
                  if (transaction != state.transactions.last)
                    Divider(color: AppColors.divider.withValues(alpha: 0.4)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _HistoryStat extends StatelessWidget {
  const _HistoryStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.bgInput.withValues(alpha: 0.6),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isBuy = transaction.side == TradeSide.buy;
    final color = isBuy ? AppColors.success : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  isBuy ? 'Compra' : 'Venta',
                  style: AppTypography.bodySm.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${transaction.amountBase.toStringAsFixed(4)} ${transaction.pair.base}',
                style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                Formatters.formatCurrency(transaction.amountQuote),
                style: AppTypography.bodyMd.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  'De ${transaction.pair.quote} a ${transaction.pair.base}',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                ),
              ),
              Text(
                transaction.timestamp.toLocal().toIso8601String(),
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                'Precio: ${Formatters.formatCurrency(transaction.price)}',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgInput.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.status.name.toUpperCase(),
                  style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
