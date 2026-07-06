import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/calendar_day_ring_style.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/calendar_day_ring_painter.dart';

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
          ProfileTopBar(title: tr(LocaleKeys.ring_colors_title), onBack: () => Navigator.of(context).pop()),
          const SizedBox(height: AppSpacing.m),
          ProfileCard(
            color: AppColors.surface,
            radius: AppRadii.xl,
            padding: const EdgeInsets.all(AppSpacing.l),
            child: const _WeekStrip(),
          ),
          const SizedBox(height: AppSpacing.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: AppSpacing.m),
                _LegendItem(
                  title: tr(LocaleKeys.ring_colors_dark_segment),
                  description: tr(LocaleKeys.ring_colors_dark_desc),
                  ringStyle: CalendarDayRingStyle(filledSegments: 8, roundedPercent: 80),
                ),
                const SizedBox(height: AppSpacing.m),
                _LegendItem(
                  title: tr(LocaleKeys.ring_colors_red_segment),
                  description: tr(LocaleKeys.ring_colors_red_desc),
                  ringStyle: CalendarDayRingStyle(filledSegments: 10, overflowSegments: 3, roundedPercent: 100, overflowFraction: 0.3),
                ),
                const SizedBox(height: AppSpacing.m),
                _LegendItem(
                  title: tr(LocaleKeys.ring_colors_gray_segment),
                  description: tr(LocaleKeys.ring_colors_gray_desc),
                  ringStyle: CalendarDayRingStyle(filledSegments: 3, roundedPercent: 30),
                ),
                const SizedBox(height: AppSpacing.m),
                _LegendItem(
                  title: tr(LocaleKeys.ring_colors_empty_segment),
                  description: tr(LocaleKeys.ring_colors_empty_desc),
                  ringStyle: CalendarDayRingStyle(filledSegments: 0, roundedPercent: 0),
                ),
                const SizedBox(height: AppSpacing.m),
              ],
            ),
          ),
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
      _DayData('Mon', '10', roundedPercent: 0),
      _DayData('Tue', '11', roundedPercent: 80),
      _DayData('Wed', '12', roundedPercent: 100),
      _DayData('Thu', '13', roundedPercent: 60),
      _DayData('Fri', '14', roundedPercent: 110, overflowFraction: 0.1),
      _DayData('Sat', '15', roundedPercent: 30),
      _DayData('Sun', '16', roundedPercent: 140, overflowFraction: 0.4, selected: true),
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
    required this.roundedPercent,
    this.overflowFraction = 0.0,
    this.selected = false,
  });

  final String label;
  final String value;
  final int roundedPercent;
  final double overflowFraction;
  final bool selected;

  CalendarDayRingStyle toRingStyle() {
    final filledSegments = (roundedPercent / 10).round().clamp(0, 10);
    final overflowSegments = overflowFraction > 0 ? ((roundedPercent - 100) / 10).round().clamp(1, 10) : 0;
    return CalendarDayRingStyle(
      filledSegments: filledSegments,
      overflowSegments: overflowSegments,
      roundedPercent: roundedPercent,
      overflowFraction: overflowFraction,
    );
  }
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({required this.day});

  final _DayData day;

  @override
  Widget build(BuildContext context) {
    final textColor = day.selected ? AppColors.textPrimary : AppColors.borderStrong;
    final ringStrokeWidth = AppSizes.progressRingStroke * 0.8;

    return Column(
      children: [
        Text(day.label, style: AppTextStyles.label11.copyWith(color: textColor)),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: AppSizes.dateCircleSize,
          height: AppSizes.dateCircleSize,
          child: CustomPaint(
            painter: CalendarDayRingPainter(
              ringStyle: day.toRingStyle(),
              strokeWidth: ringStrokeWidth,
              useSegmentedRing: false,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.progressRingStroke),
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
    required this.ringStyle,
  });

  final String title;
  final String description;
  final CalendarDayRingStyle ringStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: CustomPaint(
            painter: CalendarDayRingPainter(
              ringStyle: ringStyle,
              strokeWidth: AppSizes.progressRingStroke,
              useSegmentedRing: false,
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
