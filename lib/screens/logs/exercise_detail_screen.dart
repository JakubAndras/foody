import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/screens/logs/exercise_detail_options_sheet.dart';
import 'package:diplomka/screens/logs/exercise_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  final Exercise exercise;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late Exercise _exercise;

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise;
  }

  Future<void> _toggleFavorite() async {
    final next = !_exercise.isFavorite;
    setState(() => _exercise = _exercise.copyWith(isFavorite: next));

    if (_exercise.id == null || _exercise.dayRecordId == null) return;
    await DayRecordController.to.setExerciseFavorite(exercise: _exercise, isFavorite: next);
  }

  @override
  Widget build(BuildContext context) {
    final rate = (_exercise.caloriesBurned / (_exercise.durationMinutes ?? 1)).round();

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.chevron_left,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Text(tr(LocaleKeys.exercise_detail_title), style: AppTextStyles.title18Tight),
                  Row(
                    children: [
                      _CircleButton(icon: _exercise.isFavorite ? Icons.bookmark : Icons.bookmark_border, onTap: _toggleFavorite),
                      const SizedBox(width: AppSpacing.s),
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
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 118,
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      boxShadow: AppShadows.button,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(LocaleKeys.exercise_activity), style: AppTextStyles.body14.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.6))),
                        const SizedBox(height: AppSpacing.xs),
                        Text(_exercise.name, style: AppTextStyles.h2.copyWith(color: AppColors.onPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Expanded(
                        child: ExerciseStatCard(
                          gradient: AppGradients.exerciseCalories,
                          icon: Icons.local_fire_department,
                          label: tr(LocaleKeys.exercise_total_calories),
                          value: '${_exercise.caloriesBurned.round()}',
                          unit: tr(LocaleKeys.common_kcal),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: ExerciseStatCard(
                          gradient: AppGradients.exerciseDuration,
                          icon: Icons.schedule,
                          label: tr(LocaleKeys.common_duration),
                          value: '${_exercise.durationMinutes ?? 0}',
                          unit: tr(LocaleKeys.common_min),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  ExerciseInfoCard(
                    gradient: AppGradients.exerciseCaloriesAlt,
                    icon: Icons.trending_up,
                    label: tr(LocaleKeys.exercise_calories_per_minute),
                    value: '$rate',
                    unit: tr(LocaleKeys.exercise_kcal_min),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  ExerciseCalculationCard(
                    rate: '$rate ${tr(LocaleKeys.exercise_kcal_min)}',
                    duration: '${_exercise.durationMinutes ?? 0} ${tr(LocaleKeys.common_min)}',
                    total: '${_exercise.caloriesBurned.round()} ${tr(LocaleKeys.common_kcal)}',
                  ),
                ],
              ),
            ),
          ),
          ExerciseBottomBar(
            primaryLabel: tr(LocaleKeys.exercise_log_btn),
            secondaryLabel: tr(LocaleKeys.exercise_save_log),
            onPrimary: () => _showSnack(context, tr(LocaleKeys.exercise_log_btn)),
            onSecondary: () => _showSnack(context, tr(LocaleKeys.exercise_save_log)),
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
        padding: const EdgeInsets.all(AppSpacing.l),
        child: ExerciseDetailOptionsSheet(
          onReport: () {
            Navigator.of(context).pop();
            _showSnack(context, tr(LocaleKeys.common_report));
          },
          onDelete: () {
            Navigator.of(context).pop();
            _showSnack(context, tr(LocaleKeys.common_delete));
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
