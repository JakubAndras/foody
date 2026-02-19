import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class EditNutritionGoalsScreen extends StatelessWidget {
  const EditNutritionGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileBackButton(onPressed: () => Get.back()),
          const SizedBox(height: AppSpacing.m),
          Text('Edit nutrition goals', style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.l),
          const _GoalRow(
            label: 'Calorie goal',
            value: '2086',
            color: AppColors.primarySoft,
            icon: Icons.local_fire_department_outlined,
          ),
          const SizedBox(height: AppSpacing.m),
          const _GoalRow(
            label: 'Protein goal',
            value: '188',
            color: AppColors.error,
            icon: Icons.fitness_center_outlined,
          ),
          const SizedBox(height: AppSpacing.m),
          const _GoalRow(
            label: 'Carb goal',
            value: '203',
            color: AppColors.macroCarbs,
            icon: Icons.grain,
          ),
          const SizedBox(height: AppSpacing.m),
          const _GoalRow(
            label: 'Fat goal',
            value: '57',
            color: AppColors.info,
            icon: Icons.water_drop_outlined,
          ),
          const Spacer(),
          ProfilePrimaryButton(
            label: 'Auto Generate Goals',
            leading: const Icon(Icons.auto_awesome, color: AppColors.onPrimary, size: AppSizes.iconMd),
            height: AppSizes.buttonHeightCompact,
            shadow: AppShadows.control,
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.goalRowHeight,
      child: Row(
        children: [
          _MacroIcon(color: color, icon: icon),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Container(
              height: AppSizes.goalRowHeight,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md2),
                border: Border.all(color: AppColors.outline),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    value,
                    style: AppTextStyles.body16.copyWith(fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroIcon extends StatelessWidget {
  const _MacroIcon({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.macroIconSize,
      height: AppSizes.macroIconSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
          ),
          Icon(icon, size: AppSizes.iconMd, color: color),
        ],
      ),
    );
  }
}
