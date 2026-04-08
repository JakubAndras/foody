import 'package:diplomka/widgets/macros_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';

import '../model/day_record.dart';

class MacrosRow extends StatelessWidget {
  const MacrosRow({super.key, required this.dayRecord, this.caloriesPlanEnabled = true});

  final DayRecord dayRecord;
  final bool caloriesPlanEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MacrosCard(
          label: tr(LocaleKeys.common_protein),
          current: caloriesPlanEnabled ? dayRecord.totalProteins : dayRecord.totalProteins,
          goal: dayRecord.proteinGoal,
          icon: AppIcons.protein,
          color: AppColors.macroProtein,
        ),
        const SizedBox(width: AppSpacing.s),
        MacrosCard(
          label: tr(LocaleKeys.common_carbs),
          current: caloriesPlanEnabled ? dayRecord.totalCarbs : dayRecord.totalCarbs,
          goal: dayRecord.carbsGoal,
          icon: AppIcons.carbs,
          color: AppColors.macroCarbs,
        ),
        const SizedBox(width: AppSpacing.s),
        MacrosCard(
          label: tr(LocaleKeys.common_fats),
          current: caloriesPlanEnabled ? dayRecord.totalFats : dayRecord.totalFats,
          goal: dayRecord.fatGoal,
          icon: AppIcons.fats,
          color: AppColors.macroFats,
        ),
      ],
    );
  }
}
