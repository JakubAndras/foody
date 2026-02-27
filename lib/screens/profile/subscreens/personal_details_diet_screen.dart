import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

class PersonalDetailsDietScreen extends StatefulWidget {
  const PersonalDetailsDietScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    this.onDietChanged,
    this.initialDiet,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final ValueChanged<String>? onDietChanged;
  final String? initialDiet;

  @override
  State<PersonalDetailsDietScreen> createState() => _PersonalDetailsDietScreenState();
}

class _PersonalDetailsDietScreenState extends State<PersonalDetailsDietScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDiet;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ProfileGradientScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileTopBar(title: 'Diet', onBack: widget.onBack),
          const SizedBox(height: AppSpacing.l),
          Text(
            'Do you follow a specific diet?',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.l),
          OnboardingOptionCard(
            title: 'Classic',
            selected: _selected == 'classic',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.restaurant),
            onTap: () {
              setState(() => _selected = 'classic');
              widget.onDietChanged?.call('classic');
              widget.onNext();
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: 'Vegetarian',
            selected: _selected == 'vegetarian',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.eco_outlined),
            onTap: () {
              setState(() => _selected = 'vegetarian');
              widget.onDietChanged?.call('vegetarian');
              widget.onNext();
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: 'Vegan',
            selected: _selected == 'vegan',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.energy_savings_leaf_outlined),
            onTap: () {
              setState(() => _selected = 'vegan');
              widget.onDietChanged?.call('vegan');
              widget.onNext();
            },
          ),
          const SizedBox(height: AppSpacing.m),
          Center(
            child: Text('Or', style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: AppSpacing.m),
          OnboardingOptionCard(
            title: 'Custom',
            selected: _selected == 'custom',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.add),
            onTap: () {
              setState(() => _selected = 'custom');
              widget.onDietChanged?.call('custom');
              widget.onNext();
            },
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
