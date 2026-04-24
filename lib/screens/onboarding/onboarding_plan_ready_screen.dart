import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/nutrition_goals.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class OnboardingPlanReadyScreen extends StatelessWidget {
  const OnboardingPlanReadyScreen({super.key, required this.onNext, required this.onBack, this.progress});

  final VoidCallback onNext;
  final VoidCallback onBack;
  final double? progress;

  String _formatKg(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  String _buildGoalSummaryLabel() {
    final double? currentWeightKg = SessionManager.to.weightKg.value;
    final double? desiredWeightKg = SessionManager.to.goalWeightKg.value;
    final double speedKgPerWeek = (SessionManager.to.weightChangeRateKgPerWeek.value ?? 0.8).clamp(0.1, 1.5);

    if (currentWeightKg == null || desiredWeightKg == null) {
      return tr(LocaleKeys.onboarding_set_goal_hint);
    }

    final double deltaKg = (currentWeightKg - desiredWeightKg).abs();
    if (deltaKg < 0.1) {
      return tr(LocaleKeys.onboarding_maintain_current);
    }

    final bool isLosingWeight = desiredWeightKg < currentWeightKg;
    final double weeksToGoal = deltaKg / speedKgPerWeek;
    final int daysToGoal = (weeksToGoal * 7).ceil();
    final DateTime targetDate = DateTime.now().add(Duration(days: daysToGoal));
    final String formattedDate = DateFormat('MMMM d, y').format(targetDate);
    final String action = isLosingWeight ? tr(LocaleKeys.onboarding_action_lose) : tr(LocaleKeys.onboarding_action_gain);

    return '$action ${_formatKg(deltaKg)} kg by $formattedDate';
  }

  String _buildGoalHeading() {
    final double? currentWeightKg = SessionManager.to.weightKg.value;
    final double? desiredWeightKg = SessionManager.to.goalWeightKg.value;
    if (currentWeightKg == null || desiredWeightKg == null) {
      return tr(LocaleKeys.onboarding_your_goal);
    }
    if ((currentWeightKg - desiredWeightKg).abs() < 0.1) {
      return tr(LocaleKeys.onboarding_you_should_maintain);
    }
    return desiredWeightKg < currentWeightKg ? tr(LocaleKeys.onboarding_you_should_lose) : tr(LocaleKeys.onboarding_you_should_gain);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String goalSummaryLabel = _buildGoalSummaryLabel();
    final String goalHeading = _buildGoalHeading();
    final NutritionGoals goals = NutritionGoalsService.to.goalsForDate(DateTime.now());

    return OnboardingPage(
      progress: progress,
      onBack: onBack,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      bottom: OnboardingPrimaryButton(label: tr(LocaleKeys.onboarding_lets_get_started), onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            tr(LocaleKeys.onboarding_plan_ready_title),
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(goalHeading, style: textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          OnboardingPillChipBig(label: goalSummaryLabel, backgroundColor: AppColors.surfacePill),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(tr(LocaleKeys.onboarding_daily_recommendation), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(tr(LocaleKeys.onboarding_edit_plan_hint), style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.xs,
            crossAxisSpacing: AppSpacing.xs,
            childAspectRatio: 0.9,
            children: [
              _MacroTile(icon: CupertinoIcons.flame, label: tr(LocaleKeys.common_calories), value: goals.calorieGoal.round().toString(), unit: '', color: AppColors.primaryDark),
              _MacroTile(
                icon: AppIcons.carbs,
                label: tr(LocaleKeys.common_carbs),
                value: goals.carbsGoal.round().toString(),
                unit: tr(LocaleKeys.common_g),
                color: AppColors.macroCarbs,
              ),
              _MacroTile(
                icon: AppIcons.protein,
                label: tr(LocaleKeys.common_protein),
                value: goals.proteinGoal.round().toString(),
                unit: tr(LocaleKeys.common_g),
                color: AppColors.macroProtein,
              ),
              _MacroTile(
                icon: AppIcons.fats,
                label: tr(LocaleKeys.common_fats),
                value: goals.fatGoal.round().toString(),
                unit: tr(LocaleKeys.common_g),
                color: AppColors.macroFats,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({required this.icon, required this.label, required this.value, required this.unit, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          width: AppSizes.widgetRingSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(icon, size: AppSizes.iconSm, color: AppColors.textPrimary),
              ),
              Text(label, style: textTheme.titleSmall?.copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        OnboardingRingChart(value: 1.0, color: color, label: value, unit: unit, size: AppSizes.widgetRingSize, strokeWidth: 10),
      ],
    );
  }
}
