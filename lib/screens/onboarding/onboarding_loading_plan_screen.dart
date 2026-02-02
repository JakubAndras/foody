import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

class OnboardingLoadingPlanScreen extends StatelessWidget {
  const OnboardingLoadingPlanScreen({
    super.key,
    required this.onNext,
    required this.step,
    required this.totalSteps,
  });

  final VoidCallback onNext;
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onNext,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: Text('71%', style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(
                    "We're setting everything\nup for you",
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: Container(
                    height: AppSizes.progressBarHeight,
                    color: AppColors.border,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.71,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppGradients.loading,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    'Estimating your metabolic age...',
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Daily recommendation for', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                _Bullet(text: 'Calories'),
                _Bullet(text: 'Carbs'),
                _Bullet(text: 'Protein'),
                _Bullet(text: 'Fats'),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text('•', style: style),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: style),
        ],
      ),
    );
  }
}
