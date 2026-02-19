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
    final double buttonsHostHeight = (MediaQuery.of(context).size.height * 0.34).clamp(180.0, 320.0);

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
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Text(
              'Sign in with Apple or Google to save your data to the cloud and access it from any device.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Text(
              'Or skip this step to save your data locally on your phone only.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
            height: buttonsHostHeight,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OnboardingSolidButton(
                      label: 'Sign in with Apple',
                      leading: const Icon(Icons.apple, color: AppColors.onPrimary, size: AppSizes.iconLg),
                      onPressed: onNext,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    OnboardingOutlinedButton(
                      label: 'Sign in with Google',
                      leading: SizedBox(
                        width: AppSizes.iconMd,
                        height: AppSizes.iconMd,
                        child: Image.asset('assets/images/google_icon.png'),
                      ),
                      onPressed: onNext,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
