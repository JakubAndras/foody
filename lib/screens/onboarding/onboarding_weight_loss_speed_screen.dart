import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

class OnboardingWeightLossSpeedScreen extends StatefulWidget {
  const OnboardingWeightLossSpeedScreen({
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
  State<OnboardingWeightLossSpeedScreen> createState() => _OnboardingWeightLossSpeedScreenState();
}

class _OnboardingWeightLossSpeedScreenState extends State<OnboardingWeightLossSpeedScreen> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(label: 'Continue', onPressed: widget.onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How fast do you want to reach your goal?',
            style: textTheme.headlineLarge?.copyWith(height: 1.25),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Text(
                  'Weight loss speed per week',
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('0.8 kg', style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              const Icon(Icons.pets, color: AppColors.textMuted, size: AppSizes.iconLg),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: OnboardingSliderTicks(count: 5),
                    ),
                    OnboardingSlider(
                      value: _value,
                      onChanged: (value) => setState(() => _value = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.speed, color: AppColors.textMuted, size: AppSizes.iconLg),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.1 kg', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              Text('0.8 kg', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              Text('1.5 kg', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Text(
                'Recommended',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
