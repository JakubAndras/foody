import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

class OnboardingDietScreen extends StatefulWidget {
  const OnboardingDietScreen({
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
  State<OnboardingDietScreen> createState() => _OnboardingDietScreenState();
}

class _OnboardingDietScreenState extends State<OnboardingDietScreen> {
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
          Text(
            'Do you follow a\nspecific diet?',
            style: textTheme.headlineLarge?.copyWith(height: 1.25),
          ),
          const SizedBox(height: AppSpacing.xl),
          OnboardingOptionCard(
            title: 'Classic',
            selected: _selected == 'classic',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.restaurant),
            onTap: () => setState(() => _selected = 'classic'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OnboardingOptionCard(
            title: 'Vegetarian',
            selected: _selected == 'vegetarian',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.eco_outlined),
            onTap: () => setState(() => _selected = 'vegetarian'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OnboardingOptionCard(
            title: 'Vegan',
            selected: _selected == 'vegan',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.energy_savings_leaf_outlined),
            onTap: () => setState(() => _selected = 'vegan'),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text('Or', style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: AppSpacing.md),
          OnboardingOptionCard(
            title: 'Custom',
            selected: _selected == 'custom',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.add),
            onTap: () => setState(() => _selected = 'custom'),
          ),
        ],
      ),
    );
  }
}

class _DietIcon extends StatelessWidget {
  const _DietIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.iconXl,
      height: AppSizes.iconXl,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: AppSizes.iconMd, color: AppColors.onPrimary),
    );
  }
}
