import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/logs/weight_log_sheet.dart';
import 'package:diplomka/screens/profile/subscreens/weight_history_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _formatWeight(double value) {
  final isInt = value % 1 == 0;
  return value.toStringAsFixed(isInt ? 0 : 1);
}

class CurrentWeightCard extends ConsumerWidget {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasData = currentWeight != null;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WeightHistoryScreen())),
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
                      border: isLogToday ? null : AppBorders.screenCard,
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
            if (hasData)
              Text('${_formatWeight(currentWeight!)} kg', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800))
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadii.s),
                      ),
                      child: Icon(Icons.monitor_weight_outlined, color: AppColors.textTertiary, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text('— kg', style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800, color: AppColors.textTertiary)),
                  ],
                ),
              ),
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
