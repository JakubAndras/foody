import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

class OnboardingSaveProgressScreen extends StatelessWidget {
  const OnboardingSaveProgressScreen({
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
      bottom: OnboardingPrimaryButton(label: 'Skip', onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Save your progress',
            textAlign: TextAlign.center,
            style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sign in with Apple or Google to save your data to the cloud and access it from any device.\n\nOr skip this step to save your data locally on your phone only.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          OnboardingSolidButton(
            label: 'Sign in with Apple',
            //leading: const Icon(CupertinoIcons.apple_logo, color: AppColors.onPrimary, size: AppSizes.iconMd),
            onPressed: onNext,
          ),
          const SizedBox(height: AppSpacing.sm),
          OnboardingOutlinedButton(
            label: 'Sign in with Google',
            leading: const OnboardingGoogleMark(),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
