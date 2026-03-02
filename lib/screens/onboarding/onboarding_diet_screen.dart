import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OnboardingDietScreen extends StatefulWidget {
  const OnboardingDietScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.step,
    required this.totalSteps,
    this.onCanProceedChanged,
    this.onDietChanged,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final int step;
  final int totalSteps;
  final ValueChanged<bool>? onCanProceedChanged;
  final ValueChanged<String>? onDietChanged;

  @override
  State<OnboardingDietScreen> createState() => _OnboardingDietScreenState();
}

class _OnboardingDietScreenState extends State<OnboardingDietScreen> with AutomaticKeepAliveClientMixin {
  String? _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanProceedChanged?.call(_selected != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: tr(LocaleKeys.common_continue_btn),
        isEnabled: _selected != null,
        onPressed: _selected != null ? widget.onNext : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(LocaleKeys.onboarding_diet_title),
            style: textTheme.headlineLarge?.copyWith(height: 1.25),
          ),
          const SizedBox(height: AppSpacing.xl),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_classic),
            selected: _selected == 'classic',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.restaurant),
            onTap: () {
              setState(() => _selected = 'classic');
              widget.onDietChanged?.call('classic');
              widget.onCanProceedChanged?.call(true);
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
              widget.onCanProceedChanged?.call(true);
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
              widget.onCanProceedChanged?.call(true);
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
              widget.onCanProceedChanged?.call(true);
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
