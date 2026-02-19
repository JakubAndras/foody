import 'package:diplomka/app_theme.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OnboardingPlanReadyScreen extends StatelessWidget {
  const OnboardingPlanReadyScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.step,
    required this.totalSteps,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final int step;
  final int totalSteps;

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
      return 'Set your goal to see estimate';
    }

    final double deltaKg = (currentWeightKg - desiredWeightKg).abs();
    if (deltaKg < 0.1) {
      return 'Maintain current weight';
    }

    final bool isLosingWeight = desiredWeightKg < currentWeightKg;
    final double weeksToGoal = deltaKg / speedKgPerWeek;
    final int daysToGoal = (weeksToGoal * 7).ceil();
    final DateTime targetDate = DateTime.now().add(Duration(days: daysToGoal));
    final String formattedDate = DateFormat('MMMM d, y').format(targetDate);
    final String action = isLosingWeight ? 'Lose' : 'Gain';

    return '$action ${_formatKg(deltaKg)} kg by $formattedDate';
  }

  String _buildGoalHeading() {
    final double? currentWeightKg = SessionManager.to.weightKg.value;
    final double? desiredWeightKg = SessionManager.to.goalWeightKg.value;
    if (currentWeightKg == null || desiredWeightKg == null) {
      return 'Your goal:';
    }
    if ((currentWeightKg - desiredWeightKg).abs() < 0.1) {
      return 'You should maintain:';
    }
    return desiredWeightKg < currentWeightKg ? 'You should lose:' : 'You should gain:';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String goalSummaryLabel = _buildGoalSummaryLabel();
    final String goalHeading = _buildGoalHeading();

    return OnboardingPage(
      progress: step / totalSteps,
      onBack: onBack,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      bottom: OnboardingPrimaryButton(label: "Let's get started!", onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Congratulations\nyour custom plan is ready!',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(goalHeading, style: textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          OnboardingPillChipBig(
            label: goalSummaryLabel,
            backgroundColor: AppColors.surfacePill,
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Daily recommendation', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'You can edit your plan anytime in profile settings',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.xs,
            crossAxisSpacing: AppSpacing.xs,
            childAspectRatio: 0.9,
            children: const [
              _MacroTile(
                icon: Icons.local_fire_department,
                label: 'Calories',
                value: '2086',
                unit: '',
                color: AppColors.primaryDark,
              ),
              _MacroTile(
                icon: Icons.grain,
                label: 'Carbs',
                value: '203',
                unit: 'g',
                color: AppColors.macroCarbs,
              ),
              _MacroTile(
                icon: Icons.bolt,
                label: 'Protein',
                value: '188',
                unit: 'g',
                color: AppColors.macroProtein,
              ),
              _MacroTile(
                icon: Icons.opacity,
                label: 'Fats',
                value: '57',
                unit: 'g',
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
  const _MacroTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

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
        OnboardingRingChart(
          value: 0.75,
          color: color,
          label: value,
          unit: unit,
          size: AppSizes.widgetRingSize,
        ),
      ],
    );
  }
}
