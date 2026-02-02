import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/logs/exercise_detail_options_sheet.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:flutter/material.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.title,
    required this.kcal,
    required this.minutes,
  });

  final String title;
  final int kcal;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final rate = (kcal / minutes).round();

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.chevron_left,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Text('Exercise Detail', style: AppTextStyles.title18Tight),
                  Row(
                    children: [
                      _CircleButton(icon: Icons.bookmark_border, onTap: () {}),
                      const SizedBox(width: AppSpacing.sm),
                      _CircleButton(
                        icon: Icons.more_horiz,
                        onTap: () => _showOptions(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 118,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      boxShadow: AppShadows.button,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Activity', style: AppTextStyles.body14.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.6))),
                        const SizedBox(height: AppSpacing.xs),
                        Text(title, style: AppTextStyles.h2.copyWith(color: AppColors.onPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: ExerciseStatCard(
                          gradient: AppGradients.exerciseCalories,
                          icon: Icons.local_fire_department,
                          label: 'Total Calories',
                          value: '$kcal',
                          unit: 'kcal',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ExerciseStatCard(
                          gradient: AppGradients.exerciseDuration,
                          icon: Icons.schedule,
                          label: 'Duration',
                          value: '$minutes',
                          unit: 'min',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ExerciseInfoCard(
                    gradient: AppGradients.exerciseCaloriesAlt,
                    icon: Icons.trending_up,
                    label: 'Calories Per Minute',
                    value: '$rate',
                    unit: 'kcal/min',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ExerciseCalculationCard(
                    rate: '$rate kcal/min',
                    duration: '$minutes min',
                    total: '$kcal cal',
                  ),
                ],
              ),
            ),
          ),
          ExerciseBottomBar(
            primaryLabel: 'Log',
            secondaryLabel: 'Save & Log',
            onPrimary: () => _showSnack(context, 'Logged'),
            onSecondary: () => _showSnack(context, 'Saved & Logged'),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ExerciseDetailOptionsSheet(
          onReport: () {
            Navigator.of(context).pop();
            _showSnack(context, 'Report submitted');
          },
          onDelete: () {
            Navigator.of(context).pop();
            _showSnack(context, 'Exercise deleted');
          },
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.backButtonSize,
        height: AppSizes.backButtonSize,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.outline, width: 1),
          boxShadow: AppShadows.control,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: AppSizes.iconMd),
      ),
    );
  }
}
