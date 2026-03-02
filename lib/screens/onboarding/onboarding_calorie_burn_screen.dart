import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OnboardingCalorieBurnScreen extends StatelessWidget {
  const OnboardingCalorieBurnScreen({
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
            child: OnboardingPrimaryButton(label: tr(LocaleKeys.common_no), onPressed: onNext),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: OnboardingPrimaryButton(label: tr(LocaleKeys.common_yes), onPressed: onNext),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(LocaleKeys.onboarding_calorie_burn_title),
            style: textTheme.headlineLarge?.copyWith(height: 1.25),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: AppSizes.calorieBurnImageSize,
            child: Stack(
              children: [
                OnboardingPlaceholderImage(height: AppSizes.calorieBurnImageSize),
                Positioned(
                  left: AppSpacing.s,
                  bottom: AppSpacing.s,
                  child: SizedBox(
                    width: AppSizes.infoCardWidth,
                    child: OnboardingSurfaceCard(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr(LocaleKeys.onboarding_todays_goal),
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: AppColors.textPrimary, size: AppSizes.iconLg),
                              const SizedBox(width: AppSpacing.s),
                              Text(
                                '500 Cals',
                                style: textTheme.headlineLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Row(
                            children: [
                              Container(
                                width: AppSizes.iconXl,
                                height: AppSizes.iconXl,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryDark,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.directions_run, color: AppColors.onPrimary, size: AppSizes.iconMd),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tr(LocaleKeys.onboarding_running), style: textTheme.titleSmall?.copyWith(color: AppColors.textPrimary)),
                                  Text(tr(LocaleKeys.onboarding_plus_100_cals), style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                ],
                              ),
                            ],
                          ),
                        ],
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
