import 'package:flutter/material.dart';

import '../../shared/styles/app_colors.dart';
import '../../shared/styles/app_typography.dart';

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.primaryLight,
    onSecondary: Colors.white,
    tertiary: AppColors.success,
    onTertiary: Colors.white,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.bgSecondary,
    surfaceTint: Colors.transparent,
    surfaceContainerHigh: AppColors.bgCard,
    surfaceContainerHighest: AppColors.bgCard,
    surfaceContainerLow: AppColors.bgElevated,
    surfaceBright: AppColors.bgSecondary,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.divider,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.bgPrimary,
    fontFamily: AppTypography.fontFamily,
    textTheme: AppTypography.textTheme,
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
  );

  return base.copyWith(
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.textDisabled.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.textDisabled.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textDisabled),
      labelStyle: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      space: 16,
      thickness: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: AppTypography.bodyMd.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.bgInput,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      secondarySelectedColor: AppColors.primary,
      labelStyle: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
      side: BorderSide(color: AppColors.textDisabled.withValues(alpha: 0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: AppTypography.titleMd,
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.bgSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
  );
}
