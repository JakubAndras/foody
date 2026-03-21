import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ExerciseSearchBar extends StatelessWidget {
  const ExerciseSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.exerciseSearchHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.outline, width: 1),
        // boxShadow: AppShadows.control,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textTertiary, size: AppSizes.iconMd),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: tr(LocaleKeys.exercise_search_hint),
                hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
              ),
              style: AppTextStyles.body16,
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseFilterChip extends StatelessWidget {
  const ExerciseFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.outline, width: selected ? 0 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSizes.iconXs, color: selected ? AppColors.onPrimary : AppColors.textPrimary),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTextStyles.body14.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseListCard extends StatelessWidget {
  const ExerciseListCard({
    super.key,
    required this.title,
    required this.kcal,
    required this.minutes,
    required this.onAdd,
    required this.onTap,
  });

  final String title;
  final int kcal;
  final int minutes;
  final VoidCallback onAdd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.exerciseCardHeight,
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.outline, width: 1),
          // boxShadow: AppShadows.control,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: AppTextStyles.title18, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      _MetricPill(
                        gradient: AppGradients.exerciseCalories,
                        icon: Icons.local_fire_department,
                        value: '$kcal',
                        unit: 'kcal',
                      ),
                      const SizedBox(width: AppSpacing.s),
                      _MetricPill(
                        gradient: AppGradients.exerciseDuration,
                        icon: Icons.schedule,
                        value: '$minutes',
                        unit: 'min',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  // boxShadow: AppShadows.control,
                ),
                child: const Icon(Icons.add, color: AppColors.onPrimary, size: AppSizes.iconMd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseStatCard extends StatelessWidget {
  const ExerciseStatCard({
    super.key,
    required this.gradient,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final Gradient gradient;
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.exerciseStatCardHeight,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.outline, width: 1),
        // boxShadow: AppShadows.control,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, color: AppColors.onPrimary, size: AppSizes.iconMd),
          ),
          const Spacer(),
          Text(label, style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(value, style: AppTextStyles.h3.copyWith(height: 1.5)),
              const SizedBox(width: 4),
              Text(unit, style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}

class ExerciseInfoCard extends StatelessWidget {
  const ExerciseInfoCard({
    super.key,
    required this.gradient,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final Gradient gradient;
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.outline, width: 1),
        // boxShadow: AppShadows.control,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, color: AppColors.onPrimary, size: AppSizes.iconMd),
          ),
          const SizedBox(width: AppSpacing.m),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(value, style: AppTextStyles.h3.copyWith(height: 1.5)),
                  const SizedBox(width: 4),
                  Text(unit, style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExerciseCalculationCard extends StatelessWidget {
  const ExerciseCalculationCard({
    super.key,
    required this.rate,
    required this.duration,
    required this.total,
  });

  final String rate;
  final String duration;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.exercise_calculation), style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.s),
          _CalcRow(label: tr(LocaleKeys.exercise_rate), value: rate),
          _CalcRow(label: tr(LocaleKeys.common_duration), value: duration),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: Divider(color: AppColors.outline, height: 1),
          ),
          _CalcRow(label: tr(LocaleKeys.exercise_total_calories), value: total, emphasize: true),
        ],
      ),
    );
  }
}

class ExerciseBottomBar extends StatelessWidget {
  const ExerciseBottomBar({
    super.key,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.l),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onPrimary,
              child: Container(
                height: AppSizes.buttonHeight,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  // boxShadow: AppShadows.control,
                ),
                child: Center(
                  child: Text(
                    primaryLabel,
                    style: AppTextStyles.title18.copyWith(height: 1.25, color: AppColors.onPrimary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: GestureDetector(
              onTap: onSecondary,
              child: Container(
                height: AppSizes.buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: AppColors.primary, width: 1),
                  // boxShadow: AppShadows.control,
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
                    child: Text(
                      secondaryLabel,
                      style: AppTextStyles.title18.copyWith(height: 1.25, color: AppColors.onPrimary),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseTrackingOptionCard extends StatelessWidget {
  const ExerciseTrackingOptionCard({
    super.key,
    required this.selected,
    required this.gradient,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final Gradient gradient;
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.exerciseOptionCardHeight,
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceSelected : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
            width: selected ? 1 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: selected ? gradient : null,
                color: selected ? null : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(icon, color: selected ? AppColors.onPrimary : AppColors.textTertiary, size: AppSizes.iconMd),
            ),
            const Spacer(),
            Text(label, style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.label12.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class ExerciseInputCard extends StatelessWidget {
  const ExerciseInputCard({
    super.key,
    required this.gradient,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final Gradient gradient;
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.scanInputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.outline, width: 1),
        // boxShadow: AppShadows.control,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, color: AppColors.onPrimary, size: AppSizes.iconSm),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.h3.copyWith(height: 1.5, color: AppColors.textDisabled),
            ),
          ),
          Text(unit, style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class ExerciseTotalSummaryCard extends StatelessWidget {
  const ExerciseTotalSummaryCard({
    super.key,
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.scanInputHeight,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        // boxShadow: AppShadows.control,
      ),
      child: Center(
        child: Text(
          value,
          style: AppTextStyles.h1.copyWith(fontSize: 36, height: 1.11, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.gradient,
    required this.icon,
    required this.value,
    required this.unit,
  });

  final Gradient gradient;
  final IconData icon;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(icon, color: AppColors.onPrimary, size: AppSizes.iconSm),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(value, style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 2),
        Text(unit, style: AppTextStyles.label12.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}

class _CalcRow extends StatelessWidget {
  const _CalcRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: emphasize ? AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600) : AppTextStyles.body14,
        ),
        Text(
          value,
          style: emphasize ? AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600) : AppTextStyles.body14,
        ),
      ],
    );
  }
}
