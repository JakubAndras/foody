import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/progress_ring.dart';

class CaloriesCard extends StatelessWidget {
  const CaloriesCard({super.key, required this.dayRecord, this.caloriesPlanEnabled = true, this.rolloverAmount = 0});

  final DayRecord dayRecord;
  final bool caloriesPlanEnabled;
  final double rolloverAmount;

  @override
  Widget build(BuildContext context) {
    final bool burnedEnabled = SessionManager.to.burnedCaloriesEnabled.value;
    final bool rolloverEnabled = SessionManager.to.rolloverCaloriesEnabled.value;
    final double baseGoal = dayRecord.calorieGoal <= 0 ? 1 : dayRecord.calorieGoal;
    final double effectiveGoal = baseGoal + (rolloverEnabled ? rolloverAmount : 0);
    final double food = dayRecord.totalCalories;
    final double exercise = dayRecord.totalExerciseCalories;
    final double remaining = burnedEnabled ? effectiveGoal - dayRecord.netCalories : effectiveGoal - dayRecord.totalCalories;
    final double consumed = burnedEnabled ? dayRecord.netCalories : dayRecord.totalCalories;
    final double progress = (consumed / effectiveGoal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
        border: Border.all(color: AppColors.outline),
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
                      foregroundColor: AppColors.textPrimary,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (caloriesPlanEnabled ? remaining : consumed).toStringAsFixed(0),
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
                value: baseGoal.toStringAsFixed(0),
                color: AppColors.textMuted,
              ),
              const SizedBox(height: AppSpacing.s),
              _StatItem(
                icon: Icons.restaurant_rounded,
                label: tr(LocaleKeys.dashboard_food),
                value: food.toStringAsFixed(0),
                color: AppColors.info,
              ),
              if (burnedEnabled) ...[
                const SizedBox(height: AppSpacing.s),
                _StatItem(
                  icon: Icons.directions_run_rounded,
                  label: tr(LocaleKeys.common_exercise),
                  value: exercise.toStringAsFixed(0),
                  color: AppColors.warning,
                ),
              ],
              if (rolloverEnabled) ...[
                const SizedBox(height: AppSpacing.s),
                _StatItem(
                  icon: Icons.history_rounded,
                  label: tr(LocaleKeys.dashboard_rollover),
                  value: '${rolloverAmount >= 0 ? '+' : ''}${rolloverAmount.toStringAsFixed(0)}',
                  color: rolloverAmount >= 0 ? AppColors.success : AppColors.error,
                ),
              ],
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
