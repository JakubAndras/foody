import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class RingColorsExplainedScreen extends StatelessWidget {
  const RingColorsExplainedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileBackButton(onPressed: () => Get.back()),
          const SizedBox(height: AppSpacing.md),
          Text('Ring Colors Explained', style: AppTextStyles.h1Tight.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.lg),
          ProfileCard(
            color: AppColors.surfaceCard,
            radius: AppRadii.xl,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Calories AI app', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700)),
                    _FirePill(),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _WeekStrip(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'On the homepage calendar, the colored rings around each date show how close you were to your daily calorie goal:',
            style: AppTextStyles.body14Relaxed,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _LegendItem(color: AppColors.successStrong, title: 'Green', description: 'Up to 50 calories over your deficit target'),
          const SizedBox(height: AppSpacing.md),
          const _LegendItem(color: AppColors.warning, title: 'Yellow', description: '50–300 calories over your goal'),
          const SizedBox(height: AppSpacing.md),
          const _LegendItem(color: AppColors.error, title: 'Red', description: 'More than 300 calories over your goal'),
          const SizedBox(height: AppSpacing.md),
          const _LegendItem(color: AppColors.borderStrong, title: 'Dotted', description: 'No meals logged that day', isDotted: true),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.control,
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('15', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w700)),
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
      _DayData('Sun', '10', ring: AppColors.error),
      _DayData('Mon', '11', ring: AppColors.outline),
      _DayData('Tue', '12', ring: AppColors.successStrong),
      _DayData('Wed', '13', ring: AppColors.primarySoft, filled: true),
      _DayData('Thu', '14', ring: AppColors.outline),
      _DayData('Fri', '15', ring: AppColors.outline),
      _DayData('Sat', '16', ring: AppColors.outline),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => _WeekDay(day: day)).toList(),
    );
  }
}

class _DayData {
  const _DayData(this.label, this.value, {required this.ring, this.filled = false});

  final String label;
  final String value;
  final Color ring;
  final bool filled;
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({required this.day});

  final _DayData day;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day.label, style: AppTextStyles.label11.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: AppSizes.dateCircleSize,
          height: AppSizes.dateCircleSize,
          decoration: BoxDecoration(
            color: day.filled ? AppColors.primarySoft : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: day.ring, width: AppSizes.dateCircleBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            day.value,
            style: AppTextStyles.body14.copyWith(
              fontWeight: FontWeight.w600,
              color: day.filled ? AppColors.onPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.title,
    required this.description,
    this.isDotted = false,
  });

  final Color color;
  final String title;
  final String description;
  final bool isDotted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: AppSizes.dateCircleBorder,
              style: isDotted ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
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
