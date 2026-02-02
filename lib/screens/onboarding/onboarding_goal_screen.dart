import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

class OnboardingGoalScreen extends StatefulWidget {
  const OnboardingGoalScreen({
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
  State<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends State<OnboardingGoalScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: 'Continue',
        isEnabled: _selected != null,
        onPressed: _selected != null ? widget.onNext : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is your goal?', style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This helps us generate a plan for your calorie intake.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          OnboardingOptionCard(
            title: 'Lose weight',
            selected: _selected == 'lose',
            onTap: () => setState(() => _selected = 'lose'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OnboardingOptionCard(
            title: 'Maintain',
            selected: _selected == 'maintain',
            onTap: () => setState(() => _selected = 'maintain'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OnboardingOptionCard(
            title: 'Gain weight',
            selected: _selected == 'gain',
            onTap: () => setState(() => _selected = 'gain'),
          ),
        ],
      ),
    );
  }
}
