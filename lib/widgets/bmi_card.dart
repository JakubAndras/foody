import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/widgets/info_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class _BmiCategory {
  final String label;
  final Color color;
  const _BmiCategory({required this.label, required this.color});
}

class BmiCard extends StatelessWidget {
  const BmiCard({super.key, this.currentWeight, this.heightCm});

  final double? currentWeight;
  final double? heightCm;

  double? get _bmiValue {
    if (currentWeight == null || heightCm == null || heightCm! <= 0) return null;
    final heightM = heightCm! / 100;
    return currentWeight! / (heightM * heightM);
  }

  _BmiCategory _bmiCategory(double bmi) {
    if (bmi < 18.5) return _BmiCategory(label: tr(LocaleKeys.progress_bmi_underweight), color: AppColors.info);
    if (bmi < 25) return _BmiCategory(label: tr(LocaleKeys.progress_bmi_healthy), color: AppColors.success);
    if (bmi < 30) return _BmiCategory(label: tr(LocaleKeys.progress_bmi_overweight), color: AppColors.warning);
    return _BmiCategory(label: tr(LocaleKeys.progress_bmi_obese), color: AppColors.error);
  }

  @override
  Widget build(BuildContext context) {
    final double? bmi = _bmiValue;
    final _BmiCategory? category = bmi == null ? null : _bmiCategory(bmi);
    final bool hasWeight = currentWeight != null;
    final bool hasHeight = heightCm != null && heightCm! > 0;
    final String missingLabel = !hasHeight && !hasWeight
        ? tr(LocaleKeys.progress_missing_height_weight)
        : !hasHeight
            ? tr(LocaleKeys.progress_missing_height)
            : tr(LocaleKeys.progress_missing_weight);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
        border: AppBorders.screenCard,
        boxShadow: AppShadows.screenCard,
      ),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr(LocaleKeys.progress_your_bmi), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => showInfoDialog(context, title: tr(LocaleKeys.progress_bmi_info_title), body: tr(LocaleKeys.progress_bmi_info_body)),
                child: const Icon(CupertinoIcons.info, size: AppSizes.iconMd, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          if (bmi == null)
            Text(missingLabel, style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary))
          else
            Row(
              children: [
                Text(bmi.toStringAsFixed(1), style: AppTextStyles.h1.copyWith(fontSize: 32, fontWeight: FontWeight.w800, height: 1.5)),
                const SizedBox(width: AppSpacing.s),
                Text(tr(LocaleKeys.progress_your_weight_is), style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(color: category!.color, borderRadius: BorderRadius.circular(AppRadii.xs)),
                  child: Text(
                    category.label,
                    style: AppTextStyles.caption12.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.m),
          LayoutBuilder(
            builder: (context, constraints) {
              double indicatorX = 0;
              if (bmi != null) {
                final double clamped = bmi.clamp(16.0, 40.0);
                // Map BMI to gradient position matching the non-linear stops:
                // Underweight: BMI 16–18.5 → pos 0.0–0.20
                // Healthy:     BMI 18.5–25 → pos 0.20–0.55
                // Overweight:  BMI 25–30   → pos 0.55–0.80
                // Obese:       BMI 30–40   → pos 0.80–1.0
                double fraction;
                if (clamped < 18.5) {
                  fraction = (clamped - 16) / (18.5 - 16) * 0.20;
                } else if (clamped < 25) {
                  fraction = 0.20 + (clamped - 18.5) / (25 - 18.5) * 0.35;
                } else if (clamped < 30) {
                  fraction = 0.55 + (clamped - 25) / (30 - 25) * 0.25;
                } else {
                  fraction = 0.80 + (clamped - 30) / (40 - 30) * 0.20;
                }
                indicatorX = fraction * constraints.maxWidth;
              }
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: AppSizes.bmiBarHeight,
                    decoration: BoxDecoration(gradient: AppGradients.bmi, borderRadius: BorderRadius.circular(AppRadii.pill)),
                  ),
                  if (bmi != null)
                    Positioned(
                      left: indicatorX,
                      child: Container(
                        width: AppSizes.bmiMarkerWidth,
                        height: AppSizes.bmiMarkerHeight,
                        decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(AppRadii.pill)),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendItem(label: tr(LocaleKeys.progress_bmi_underweight), color: AppColors.info),
              _LegendItem(label: tr(LocaleKeys.progress_bmi_healthy), color: AppColors.success),
              _LegendItem(label: tr(LocaleKeys.progress_bmi_overweight), color: AppColors.warning),
              _LegendItem(label: tr(LocaleKeys.progress_bmi_obese), color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.legendDot,
          height: AppSizes.legendDot,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.label10.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}
