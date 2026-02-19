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
    final double rolloverCardHeight = 260;

    return OnboardingPage(
      progress: step / totalSteps,
      onBack: onBack,
      bottom: Row(
        children: [
          Expanded(
            child: OnboardingPrimaryButton(label: 'No', onPressed: onNext),
          ),
          const SizedBox(width: AppSpacing.s),
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
          const SizedBox(height: AppSpacing.s),
          const OnboardingPillChipSmall(
            label: 'Rollover up to 500 cals',
            textColor: AppColors.textPrimary,
            backgroundColor: AppColors.surfaceChip,
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            'If you eat under your goal, the unused calories will be added to tomorrow’s budget.\n\nIf you eat over, the extra calories will be subtracted from tomorrow’s budget.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: rolloverCardHeight + AppSpacing.l,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: _RolloverCard(
                    title: 'Yesterday',
                    headerColor: AppColors.errorContainer,
                    titleColor: AppColors.error,
                    totalCaloriesText: '/2000',
                    badge: const _CalsLeftBadge(baseValueText: '150'),
                    extra: null,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: AppSpacing.l,
                  child: _RolloverCard(
                    title: 'Today',
                    headerColor: AppColors.surfaceChip,
                    titleColor: AppColors.primaryDark,
                    totalCaloriesText: '/2150',
                    badge: const _CalsLeftBadge(baseValueText: '150', bonusText: ' + 150'),
                    extra: OnboardingPillChipSmall(
                      label: '+ 150',
                      textColor: AppColors.accent,
                      backgroundColor: AppColors.surfaceChip,
                      leading: Image.asset(
                        "assets/images/rollover.png",
                        width: AppSizes.iconSm,
                      ),
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
    required this.totalCaloriesText,
    required this.badge,
    this.extra,
  });

  final String title;
  final Color headerColor;
  final Color titleColor;
  final String totalCaloriesText;
  final Widget badge;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double rolloverCardWidth = MediaQuery.of(context).size.width * 0.44;
    final double rolloverCardHeight = 260;

    return SizedBox(
      width: rolloverCardWidth,
      height: rolloverCardHeight,
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: AppSizes.iconMd,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                      ],
                    ),
                  ),
                  Text(title, style: textTheme.bodyLarge?.copyWith(color: titleColor)),
                ],
              ),
            ),
            Positioned(
              top: AppSpacing.huge + 4,
              left: 0,
              right: 0,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '1850',
                        style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: totalCaloriesText,
                        style: textTheme.titleSmall?.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (extra != null)
              Positioned(
                top: AppSizes.rolloverHeaderHeight + AppSpacing.xxxl + 4,
                right: AppSpacing.xs,
                child: extra!,
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.xl,
              child: Center(
                child: OnboardingRingChart(
                  value: 0.7,
                  color: AppColors.primaryDark,
                  label: '',
                  unit: '',
                  size: AppSizes.ringSizeSmall,
                  strokeWidth: AppSizes.ringStroke,
                  centerChild: const Icon(
                    Icons.local_fire_department,
                    size: AppSizes.iconLg,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.xxs,
              bottom: 88,
              child: badge,
            ),
          ],
        ),
      ),
    );
  }
}

class _CalsLeftBadge extends StatelessWidget {
  const _CalsLeftBadge({
    required this.baseValueText,
    this.bonusText,
  });

  final String baseValueText;
  final String? bonusText;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    const double badgeWidth = 76;
    const double badgeHeight = 48;

    return Container(
      width: badgeWidth,
      height: badgeHeight,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Cals left',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary),
            ),
            if (bonusText == null)
              Text(
                baseValueText,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
              )
            else
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: baseValueText,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: bonusText,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
