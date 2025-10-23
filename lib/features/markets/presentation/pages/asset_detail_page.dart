import 'package:flutter/material.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_spacing.dart';
import '../../../../shared/styles/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/mini_sparkline.dart';

class AssetDetailPage extends StatelessWidget {
  const AssetDetailPage({required this.symbol, super.key});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        AppCard(
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
                  symbol.characters.take(2).toString(),
                  style: AppTypography.titleMd.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol, style: AppTypography.titleLg),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Resumen del activo y estadisticas principales',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Precio actual', style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              Text('\$108,658.00', style: AppTypography.titleLg.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '-1.89% 24h',
                      style: AppTypography.bodySm.copyWith(color: AppColors.danger, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('Rango 24h: \$107,557 - \$113,804', style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppColors.bgInput.withValues(alpha: 0.6),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const MiniSparkline(
                  values: [108000, 110000, 107500, 109800, 108200, 109300],
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estadisticas del activo', style: AppTypography.titleSm),
              const SizedBox(height: AppSpacing.md),
              const _StatRow(label: 'Cap. Mercado', value: '\$2.18T'),
              const _StatRow(label: 'Volumen 24h', value: '\$104.26B'),
              _StatRow(label: 'Suministro circulante', value: '19.94M $symbol'),
              const _StatRow(label: 'Dominio 24h', value: '52.15%'),
            ],
          ),
        ),
      ],
    );
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
