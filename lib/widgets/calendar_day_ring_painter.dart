import 'dart:math' as math;

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/calendar_day_ring_style.dart';
import 'package:flutter/material.dart';

class CalendarDayRingPainter extends CustomPainter {
  const CalendarDayRingPainter({
    required this.ringStyle,
    required this.strokeWidth,
    required this.useSegmentedRing,
  });

  final CalendarDayRingStyle ringStyle;
  final double strokeWidth;
  final bool useSegmentedRing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final radius = (size.shortestSide - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngleOffset = -math.pi / 2;

    if (!useSegmentedRing) {
      paint
        ..strokeCap = StrokeCap.round
        ..color = AppColors.borderStrong;
      canvas.drawCircle(center, radius, paint);

      final progress = (ringStyle.roundedPercent / 100).clamp(0.0, 1.0);
      if (progress <= 0) {
        return;
      }

      paint.color = ringStyle.roundedPercent > 100 ? AppColors.error : AppColors.primarySoft;
      canvas.drawArc(rect, startAngleOffset, 2 * math.pi * progress, false, paint);
      return;
    }

    paint.strokeCap = StrokeCap.round;
    final segmentSweep = (2 * math.pi) / ringStyle.totalSegments;
    final gapSweep = segmentSweep * 0.28;
    final drawSweep = segmentSweep - gapSweep;

    for (int i = 0; i < ringStyle.totalSegments; i++) {
      if (i < ringStyle.overflowSegments) {
        paint.color = AppColors.error;
      } else if (i < ringStyle.filledSegments) {
        paint.color = AppColors.primarySoft;
      } else {
        paint.color = AppColors.borderStrong;
      }

      final start = startAngleOffset + i * segmentSweep + (gapSweep / 2);
      canvas.drawArc(rect, start, drawSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CalendarDayRingPainter oldDelegate) {
    return oldDelegate.ringStyle != ringStyle || oldDelegate.strokeWidth != strokeWidth || oldDelegate.useSegmentedRing != useSegmentedRing;
  }
}
