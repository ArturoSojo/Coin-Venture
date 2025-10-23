import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.gradient,
    this.onTap,
    this.borderRadius = 24,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppColors.bgCard.withValues(alpha: 0.85) : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
