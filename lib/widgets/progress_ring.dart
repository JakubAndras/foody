import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final double value;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? child;
  final double overflowValue;
  final Color? overflowColor;

  const ProgressRing({
    super.key,
    required this.size,
    required this.strokeWidth,
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
    this.child,
    this.overflowValue = 0,
    this.overflowColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              value: value,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              overflowValue: overflowValue,
              overflowColor: overflowColor,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;
  final double overflowValue;
  final Color? overflowColor;

  _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.foregroundColor,
    this.overflowValue = 0,
    this.overflowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round;
    final foregroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = foregroundColor
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    final safeValue = value.isNaN || value.isInfinite ? 0.0 : value.clamp(0.0, 1.0);
    final sweep = safeValue * 2 * math.pi;
    canvas.drawArc(rect, startAngle, sweep, false, foregroundPaint);

    // Draw red overflow arc on top of full ring
    if (overflowValue > 0 && overflowColor != null) {
      final overflowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = overflowColor!
        ..strokeCap = StrokeCap.round;
      final safeOverflow = overflowValue.isNaN || overflowValue.isInfinite ? 0.0 : overflowValue.clamp(0.0, 1.0);
      final overflowSweep = safeOverflow * 2 * math.pi;
      canvas.drawArc(rect, startAngle, overflowSweep, false, overflowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.overflowValue != overflowValue ||
        oldDelegate.overflowColor != overflowColor;
  }
}
