import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/logs/weight_log_sheet.dart';
import 'package:diplomka/screens/profile/subscreens/weight_history_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String _formatWeight(double value) {
  final isInt = value % 1 == 0;
  return value.toStringAsFixed(isInt ? 0 : 1);
}

class CurrentWeightCard extends StatelessWidget {
  const CurrentWeightCard({
    super.key,
    required this.currentWeight,
    required this.startWeight,
    required this.goalWeight,
    required this.goalProgress,
    required this.nextWeighInLabel,
    required this.isLogToday,
    required this.weightEntries,
  });

  final double? currentWeight;
  final double? startWeight;
  final double? goalWeight;
  final double? goalProgress;
  final String nextWeighInLabel;
  final bool isLogToday;
  final List<WeightEntry> weightEntries;

  String? _computeGoalEta() {
    if (goalWeight == null || weightEntries.length < 2) return null;
    final latest = weightEntries.first;
    final earliest = weightEntries.last;
    final daysBetween = latest.date.difference(earliest.date).inDays;
    if (daysBetween <= 0) return null;
    final weightChange = latest.weight - earliest.weight;
    if (weightChange == 0) return null;
    final ratePerDay = weightChange / daysBetween;
    final remaining = goalWeight! - latest.weight;
    if (remaining == 0) return null;
    if ((remaining > 0 && ratePerDay <= 0) || (remaining < 0 && ratePerDay >= 0)) return null;
    final daysToGoal = (remaining / ratePerDay).ceil();
    if (daysToGoal <= 0 || daysToGoal > 3650) return null;
    final etaDate = DateTime.now().add(Duration(days: daysToGoal));
    return DateFormat.yMMMd().format(etaDate);
  }

  @override
  Widget build(BuildContext context) {
    final hasData = currentWeight != null;
    final etaLabel = _computeGoalEta();

    return GestureDetector(
      onTap: () => Get.to(() => const WeightHistoryScreen()),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                Text(tr(LocaleKeys.progress_current_weight), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
                GestureDetector(
                  onTap: isLogToday ? () => showWeightLogSheet(context) : null,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: AppSizes.badgeHeight,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                    decoration: BoxDecoration(
                      gradient: isLogToday ? AppGradients.primary : null,
                      color: isLogToday ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: isLogToday ? null : Border.all(color: AppColors.surfaceMuted),
                    ),
                    child: Center(
                      child: Text(
                        nextWeighInLabel,
                        style: AppTextStyles.caption12.copyWith(color: isLogToday ? AppColors.onPrimary : AppColors.textEmphasis, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //const SizedBox(height: AppSpacing.xs),
            if (hasData)
              Text('${_formatWeight(currentWeight!)} kg', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800))
            else
              Text('— kg', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800, color: AppColors.textTertiary)),
            const SizedBox(height: AppSpacing.s),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: SizedBox(
                height: AppSizes.progressBarHeight,
                child: Stack(
                  children: [
                    Container(color: AppColors.surfaceMuted),
                    if (goalProgress != null)
                      FractionallySizedBox(
                        widthFactor: goalProgress!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (startWeight != null && goalWeight != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: '${tr(LocaleKeys.progress_start_label)} ', style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
                      TextSpan(text: '${_formatWeight(startWeight!)} kg', style: AppTextStyles.caption12.copyWith(fontWeight: FontWeight.w700)),
                    ])),
                  ),
                  Flexible(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '${tr(LocaleKeys.progress_goal_label)} ', style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
                        TextSpan(text: '${_formatWeight(goalWeight!)} kg', style: AppTextStyles.caption12.copyWith(fontWeight: FontWeight.w700)),
                      ]),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
            // if (etaLabel != null) ...[
            //   const SizedBox(height: AppSpacing.s),
            //   Builder(builder: (context) {
            //     final fullText = tr(LocaleKeys.progress_goal_eta, namedArgs: {'date': etaLabel});
            //     final dateIndex = fullText.indexOf(etaLabel);
            //     if (dateIndex < 0) {
            //       return Text(fullText, style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary));
            //     }
            //     return Text.rich(
            //       TextSpan(children: [
            //         TextSpan(text: fullText.substring(0, dateIndex)),
            //         TextSpan(text: etaLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
            //         TextSpan(text: fullText.substring(dateIndex + etaLabel.length)),
            //       ]),
            //       style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary),
            //     );
            //   }),
            // ],
          ],
        ),
      ),
    );
  }
}
