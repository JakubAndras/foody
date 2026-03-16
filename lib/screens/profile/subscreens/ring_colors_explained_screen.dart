import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class RingColorsExplainedScreen extends StatelessWidget {
  const RingColorsExplainedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: tr(LocaleKeys.ring_colors_title), onBack: () => Get.back()),
          const SizedBox(height: AppSpacing.l),
          ProfileCard(
            color: AppColors.surfaceCard,
            radius: AppRadii.xl,
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr(LocaleKeys.ring_colors_header), style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700)),
                    _FirePill(),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                const _WeekStrip(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            tr(LocaleKeys.ring_colors_segment_info),
            style: AppTextStyles.body14Relaxed,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tr(LocaleKeys.ring_colors_segment_calc),
            style: AppTextStyles.body14Relaxed,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tr(LocaleKeys.ring_colors_segment_example),
            style: AppTextStyles.body14Relaxed,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tr(LocaleKeys.ring_colors_red_info),
            style: AppTextStyles.body14Relaxed,
          ),
          const SizedBox(height: AppSpacing.l),
          _LegendItem(
            title: tr(LocaleKeys.ring_colors_dark_segment),
            description: tr(LocaleKeys.ring_colors_dark_desc),
            filledSegments: 8,
            overflowSegments: 0,
          ),
          const SizedBox(height: AppSpacing.m),
          _LegendItem(
            title: tr(LocaleKeys.ring_colors_red_segment),
            description: tr(LocaleKeys.ring_colors_red_desc),
            filledSegments: 10,
            overflowSegments: 3,
          ),
          const SizedBox(height: AppSpacing.m),
          _LegendItem(
            title: tr(LocaleKeys.ring_colors_gray_segment),
            description: tr(LocaleKeys.ring_colors_gray_desc),
            filledSegments: 3,
            overflowSegments: 0,
          ),
        ],
      ),
    );
  }
}

class _FirePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.buttonHeightXs,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.control,
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('6', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  @override
  Widget build(BuildContext context) {
    final days = [
      _DayData('Mon', '10', filledSegments: 0, overflowSegments: 0),
      _DayData('Tue', '11', filledSegments: 8, overflowSegments: 0),
      _DayData('Wed', '12', filledSegments: 10, overflowSegments: 0),
      _DayData('Thu', '13', filledSegments: 6, overflowSegments: 0),
      _DayData('Fri', '14', filledSegments: 10, overflowSegments: 1),
      _DayData('Sat', '15', filledSegments: 3, overflowSegments: 0),
      _DayData('Sun', '16', filledSegments: 10, overflowSegments: 4, selected: true),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => _WeekDay(day: day)).toList(),
    );
  }
}

class _DayData {
  const _DayData(
    this.label,
    this.value, {
    required this.filledSegments,
    required this.overflowSegments,
    this.selected = false,
  });

  final String label;
  final String value;
  final int filledSegments;
  final int overflowSegments;
  final bool selected;
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({required this.day});

  final _DayData day;

  @override
  Widget build(BuildContext context) {
    final textColor = day.selected ? AppColors.textPrimary : AppColors.borderStrong;

    return Column(
      children: [
        Text(day.label, style: AppTextStyles.label11.copyWith(color: textColor)),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: AppSizes.dateCircleSize,
          height: AppSizes.dateCircleSize,
          child: CustomPaint(
            painter: _SegmentRingPainter(
              filledSegments: day.filledSegments,
              overflowSegments: day.overflowSegments,
              strokeWidth: AppSizes.dateCircleBorder,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.dateCircleBorder),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
                alignment: Alignment.center,
                child: Text(
                  day.value,
                  style: AppTextStyles.body14.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.title,
    required this.description,
    required this.filledSegments,
    required this.overflowSegments,
  });

  final String title;
  final String description;
  final int filledSegments;
  final int overflowSegments;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: CustomPaint(
            painter: _SegmentRingPainter(
              filledSegments: filledSegments,
              overflowSegments: overflowSegments,
              strokeWidth: AppSizes.dateCircleBorder,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xxs),
              Text(description, style: AppTextStyles.body14Relaxed),
            ],
          ),
        ),
      ],
    );
  }
}

class _SegmentRingPainter extends CustomPainter {
  const _SegmentRingPainter({
    required this.filledSegments,
    required this.overflowSegments,
    required this.strokeWidth,
  });

  final int filledSegments;
  final int overflowSegments;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final radius = (size.shortestSide - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    const int totalSegments = 10;
    final segmentSweep = (2 * math.pi) / totalSegments;
    final gapSweep = segmentSweep * 0.28;
    final drawSweep = segmentSweep - gapSweep;
    const startAngleOffset = -math.pi / 2;

    for (int i = 0; i < totalSegments; i++) {
      if (i < overflowSegments) {
        paint.color = AppColors.error;
      } else if (i < filledSegments) {
        paint.color = AppColors.primarySoft;
      } else {
        paint.color = AppColors.borderStrong;
      }

      final start = startAngleOffset + i * segmentSweep + (gapSweep / 2);
      canvas.drawArc(rect, start, drawSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentRingPainter oldDelegate) {
    return oldDelegate.filledSegments != filledSegments || oldDelegate.overflowSegments != overflowSegments || oldDelegate.strokeWidth != strokeWidth;
  }
}
