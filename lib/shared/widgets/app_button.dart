import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';
import '../styles/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton.primary({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  })  : variant = AppButtonVariant.primary,
        expanded = true;

  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    super.key,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.ghost({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
    super.key,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    super.key,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final background = _backgroundColor(disabled);
    final textColor = _textColor(disabled);

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: _buildDecoration(background),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: textColor,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    final button = GestureDetector(
      onTap: disabled ? null : () => onPressed?.call(),
      child: Opacity(
        opacity: disabled ? 0.6 : 1,
        child: expanded ? SizedBox(width: double.infinity, child: child) : child,
      ),
    );

    if (variant == AppButtonVariant.primary) {
      return DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.primaryButton, borderRadius: BorderRadius.all(Radius.circular(18))),
        child: button,
      );
    }
    return button;
  }

  Color _textColor(bool disabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
        return disabled ? AppColors.textDisabled : Colors.white;
      case AppButtonVariant.ghost:
        return disabled ? AppColors.textDisabled : AppColors.textSecondary;
      case AppButtonVariant.danger:
        return Colors.white;
    }
  }

  Color _backgroundColor(bool disabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.transparent;
      case AppButtonVariant.secondary:
        return disabled ? AppColors.bgInput.withValues(alpha: 0.4) : AppColors.bgInput.withValues(alpha: 0.8);
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return disabled ? AppColors.danger.withValues(alpha: 0.4) : AppColors.danger;
    }
  }

  Decoration _buildDecoration(Color background) {
    switch (variant) {
      case AppButtonVariant.primary:
        return const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(18)),
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        );
      case AppButtonVariant.danger:
        return BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33FF4D67),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        );
    }
  }
}
