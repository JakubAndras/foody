import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

class OnboardingCustomDietScreen extends StatefulWidget {
  const OnboardingCustomDietScreen({
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
  State<OnboardingCustomDietScreen> createState() => _OnboardingCustomDietScreenState();
}

class _OnboardingCustomDietScreenState extends State<OnboardingCustomDietScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _controller = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(label: 'Continue', onPressed: widget.onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Custom diet\npreferences', style: textTheme.headlineLarge?.copyWith(height: 1.25)),
          const SizedBox(height: AppSpacing.s),
          Text(
            "Tell us about any food you don't eat, allergies, or dietary restrictions.",
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            height: AppSizes.customDietFieldHeight,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: TextField(
              controller: _controller,
              maxLines: null,
              style: textTheme.titleMedium,
              decoration: InputDecoration.collapsed(
                hintText: "E.g., I'm allergic to peanuts, don't eat dairy, avoid gluten...",
                hintStyle: textTheme.titleMedium?.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
