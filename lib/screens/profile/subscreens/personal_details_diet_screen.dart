import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
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
          ProfileTopBar(title: tr(LocaleKeys.personal_details_diet), onBack: widget.onBack),
          const SizedBox(height: AppSpacing.l),
          Text(
            tr(LocaleKeys.personal_details_diet_title),
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.l),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_classic),
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
            title: tr(LocaleKeys.onboarding_vegetarian),
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
            title: tr(LocaleKeys.onboarding_vegan),
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
            child: Text(tr(LocaleKeys.common_or), style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: AppSpacing.m),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_custom),
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
