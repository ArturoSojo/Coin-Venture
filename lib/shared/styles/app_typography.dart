import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'Poppins';

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 36,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSm = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 18,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  static TextTheme textTheme = const TextTheme(
    displayLarge: displayLg,
    displayMedium: displayMd,
    titleLarge: titleLg,
    titleMedium: titleMd,
    titleSmall: titleSm,
    bodyLarge: bodyLg,
    bodyMedium: bodyMd,
    bodySmall: bodySm,
    labelSmall: caption,
  );
}
