import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/widgets/progress_ring.dart';

class CaloriesCard extends StatelessWidget {
  const CaloriesCard({super.key, required this.dayRecord, this.caloriesPlanEnabled = true});

  final DayRecord dayRecord;
  final bool caloriesPlanEnabled;

  @override
  Widget build(BuildContext context) {
    final double goal = dayRecord.calorieGoal <= 0 ? 1 : dayRecord.calorieGoal;
    final double food = dayRecord.totalCalories;
    final double exercise = dayRecord.totalExerciseCalories;
    final double net = dayRecord.netCalories;
    final double remaining = dayRecord.caloriesLeft;
    final double progress = (net / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.cardSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(LocaleKeys.common_calories),
                  style: AppTextStyles.body16.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.m),
                SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: ProgressRing(
                      size: AppSizes.summaryRingSize,
                      strokeWidth: AppSizes.ringStroke,
                      value: progress,
                      backgroundColor: AppColors.outline.withValues(alpha: 0.6),
                      foregroundColor: AppColors.primarySoft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (caloriesPlanEnabled ? remaining : net).toStringAsFixed(0),
                            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
                          ),
                          Text(
                            caloriesPlanEnabled ? tr(LocaleKeys.dashboard_remaining) : tr(LocaleKeys.common_calories),
                            style: AppTextStyles.caption12.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatItem(
                icon: Icons.flag_outlined,
                label: tr(LocaleKeys.dashboard_base_goal),
                value: goal.toStringAsFixed(0),
                color: AppColors.textMuted,
              ),
              const SizedBox(height: AppSpacing.s),
              _StatItem(
                icon: Icons.restaurant_rounded,
                label: tr(LocaleKeys.dashboard_food),
                value: food.toStringAsFixed(0),
                color: AppColors.info,
              ),
              const SizedBox(height: AppSpacing.s),
              _StatItem(
                icon: Icons.directions_run_rounded,
                label: tr(LocaleKeys.common_exercise),
                value: exercise.toStringAsFixed(0),
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.s),
              _StatItem(
                icon: Icons.history_rounded,
                label: tr(LocaleKeys.dashboard_rollover),
                value: '0',
                color: AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconMd, color: color),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption12.copyWith(color: AppColors.textMuted)),
            Text(value, style: AppTextStyles.caption12.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
