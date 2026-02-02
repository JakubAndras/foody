import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

class OnboardingRolloverScreen extends StatelessWidget {
  const OnboardingRolloverScreen({
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
      bottom: Row(
        children: [
          Expanded(
            child: OnboardingPrimaryButton(label: 'No', onPressed: onNext),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: OnboardingPrimaryButton(label: 'Yes', onPressed: onNext),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rollover calorie balance\nto the next day?',
            style: textTheme.headlineLarge?.copyWith(height: 1.25),
          ),
          const SizedBox(height: AppSpacing.sm),
          const OnboardingPillChip(
            label: 'Rollover up to 500 cals',
            textColor: AppColors.textPrimary,
            backgroundColor: AppColors.surfaceChip,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'If you eat under your goal, the unused calories will be added to tomorrow’s budget.\n\nIf you eat over, the extra calories will be subtracted from tomorrow’s budget.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: AppSizes.rolloverCardHeight + AppSpacing.lg,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: _RolloverCard(
                    title: 'Yesterday',
                    headerColor: AppColors.errorContainer,
                    titleColor: AppColors.error,
                    badgeText: 'Cals left\n150',
                    extra: null,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: AppSpacing.lg,
                  child: _RolloverCard(
                    title: 'Today',
                    headerColor: AppColors.surfaceChip,
                    titleColor: AppColors.primaryDark,
                    badgeText: 'Cals left\n150 + 150',
                    extra: const OnboardingPillChip(
                      label: '+ 150',
                      textColor: AppColors.accent,
                      backgroundColor: AppColors.surfaceChip,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RolloverCard extends StatelessWidget {
  const _RolloverCard({
    required this.title,
    required this.headerColor,
    required this.titleColor,
    required this.badgeText,
    this.extra,
  });

  final String title;
  final Color headerColor;
  final Color titleColor;
  final String badgeText;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: AppSizes.rolloverCardWidth,
      height: AppSizes.rolloverCardHeight,
      child: OnboardingSurfaceCard(
        padding: EdgeInsets.zero,
        radius: AppRadii.lg,
        child: Stack(
          children: [
            Container(
              height: AppSizes.rolloverHeaderHeight,
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadii.lg),
                  topRight: Radius.circular(AppRadii.lg),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(title, style: textTheme.bodyLarge?.copyWith(color: titleColor)),
                ],
              ),
            ),
            Positioned(
              top: AppSpacing.xl,
              left: AppSpacing.md,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '1850',
                      style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: '/2000',
                      style: textTheme.titleSmall?.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
            if (extra != null)
              Positioned(
                top: AppSizes.rolloverHeaderHeight + AppSpacing.sm,
                right: AppSpacing.sm,
                child: extra!,
              ),
            Positioned(
              left: AppSpacing.md,
              bottom: AppSpacing.xl,
              child: OnboardingRingChart(
                value: 0.7,
                color: AppColors.primaryDark,
                label: '',
                unit: '',
                size: AppSizes.ringSizeSmall,
                strokeWidth: AppSizes.ringStroke,
              ),
            ),
            Positioned(
              left: AppSpacing.sm,
              bottom: AppSpacing.lg,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Text(
                  badgeText,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
