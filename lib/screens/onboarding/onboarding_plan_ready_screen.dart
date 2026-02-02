import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: step / totalSteps,
      onBack: onBack,
      bottom: OnboardingPrimaryButton(label: "Let's get started!", onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Congratulations\nyour custom plan is ready!',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('You should lose:', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          const OnboardingPillChip(
            label: 'Lose 9 kg by March 4, 2026',
            backgroundColor: AppColors.surfacePill,
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Daily recommendation', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'You can edit your plan anytime in profile settings',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
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
                icon: Icons.grid_view_rounded,
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
                icon: Icons.water_drop_rounded,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSizes.iconSm, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: textTheme.titleSmall?.copyWith(color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        OnboardingRingChart(
          value: 0.75,
          color: color,
          label: value,
          unit: unit,
        ),
      ],
    );
  }
}
