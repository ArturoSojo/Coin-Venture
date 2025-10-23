import 'package:flutter/material.dart';

class AppColors {
  static const Color bgPrimary = Color(0xFF0B1220);
  static const Color bgSecondary = Color(0xFF101C36);
  static const Color bgElevated = Color(0xFF152544);
  static const Color bgCard = Color(0xFF16294F);
  static const Color bgInput = Color(0xFF1B315C);

  static const Color primary = Color(0xFF27B3FF);
  static const Color primaryDark = Color(0xFF0052FF);
  static const Color primaryLight = Color(0xFF5FD3FF);

  static const Color success = Color(0xFF2ECC71);
  static const Color danger = Color(0xFFFF5B6A);
  static const Color warning = Color(0xFFFFC857);

  static const Color textPrimary = Color(0xFFE6ECFF);
  static const Color textSecondary = Color(0xFF9BA6C6);
  static const Color textDisabled = Color(0xFF5B6A94);

  static const Color divider = Color(0x1FFFFFFF);

  static const LinearGradient appBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B1220),
      Color(0xFF0E1F3C),
      Color(0xFF091225),
    ],
  );

  static const LinearGradient primaryButton = LinearGradient(
    colors: [
      Color(0xFF1BD3FF),
      Color(0xFF005CFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
