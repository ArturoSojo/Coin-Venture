import 'package:flutter/material.dart';

import '../styles/app_colors.dart';

class MiniSparkline extends StatelessWidget {
  const MiniSparkline({
    required this.values,
    this.color = AppColors.primary,
    this.strokeWidth = 2,
    this.fill = true,
    super.key,
  });

  final List<double>? values;
  final Color color;
  final double strokeWidth;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    if (values == null || values!.length < 2) {
      return const SizedBox.shrink();
    }
    return CustomPaint(
      painter: _SparklinePainter(
        values: values!,
        lineColor: color,
        strokeWidth: strokeWidth,
        fill: fill,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.strokeWidth,
    required this.fill,
  });

  final List<double> values;
  final Color lineColor;
  final double strokeWidth;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs() < 1e-6 ? 1 : max - min;
    final dx = size.width / (values.length - 1);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = dx * i;
      final y = size.height - ((values[i] - min) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.35),
            lineColor.withValues(alpha: 0.05),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(fillPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}
