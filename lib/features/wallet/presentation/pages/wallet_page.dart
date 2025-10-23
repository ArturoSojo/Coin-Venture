import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_spacing.dart';
import '../../../../shared/styles/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../domain/entities/balance.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<WalletBloc>()..add(const WalletStarted()),
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
        switch (state.status) {
          case WalletStatus.loading:
          case WalletStatus.initial:
            return const Center(child: CircularProgressIndicator());
          case WalletStatus.failure:
            return Center(
              child: AppCard(
                child: Text(
                  state.errorMessage ?? 'No fue posible cargar tus balances',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.danger),
                ),
              ),
            );
          case WalletStatus.loaded:
            return _WalletContent(balances: state.balances);
        }
      },
    );
  }
}

class _WalletContent extends StatelessWidget {
  const _WalletContent({required this.balances});

  final List<Balance> balances;

  @override
  Widget build(BuildContext context) {
    final total = balances.fold<double>(0, (acc, b) => acc + b.amount);
    final assets = balances.length;
    final topAsset = balances.isEmpty
        ? null
        : balances.reduce((a, b) => a.amount >= b.amount ? a : b);
    final diversification = assets >= 4 ? 'Diversificado' : assets >= 2 ? 'Balanceado' : 'Concentrado';

    return AppPage(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.18),
              AppColors.bgCard.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mi Portafolio', style: AppTypography.titleMd.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Resumen de tus activos y balance',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                Formatters.formatCurrency(total),
                style: AppTypography.displayMd.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _SummaryPill(
                    icon: Icons.savings_outlined,
                    label: 'Activos',
                    value: assets.toString(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _SummaryPill(
                    icon: Icons.bar_chart_rounded,
                    label: 'Activo mayor',
                    value: topAsset?.symbol ?? '--',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _SummaryPill(
                    icon: Icons.donut_large_outlined,
                    label: 'Diversificacion',
                    value: diversification,
                  ),
                ],
              ),
            ],
          ),
        ),
        _BalancesSection(balances: balances, total: total),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
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
          color: AppColors.bgInput.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
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

class _BalancesSection extends StatelessWidget {
  const _BalancesSection({
    required this.balances,
    required this.total,
  });

  final List<Balance> balances;
  final double total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tus activos', style: AppTypography.titleMd),
          const SizedBox(height: AppSpacing.md),
          for (final balance in balances) ...[
            _BalanceRow(
              balance: balance,
              percentage: total == 0 ? 0 : balance.amount / total,
            ),
            if (balance != balances.last) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.balance,
    required this.percentage,
  });

  final Balance balance;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final percent = (percentage * 100).clamp(0, 100).toStringAsFixed(1);
    final barColor = AppColors.primary.withValues(alpha: 0.5 + (percentage * 0.5).clamp(0, 0.5));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: AppColors.primaryButton,
              ),
              alignment: Alignment.center,
              child: Text(
                balance.symbol.characters.take(2).toString(),
                style: AppTypography.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    balance.symbol,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${balance.amount.toStringAsFixed(4)} ${balance.symbol}',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '$percent %',
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage.clamp(0, 1),
            minHeight: 8,
            backgroundColor: AppColors.bgInput.withValues(alpha: 0.6),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
