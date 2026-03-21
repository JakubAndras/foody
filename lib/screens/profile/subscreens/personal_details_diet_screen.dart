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
    this.onCanProceedChanged,
    this.keepAlive = false,
    this.customPreferences,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final ValueChanged<String>? onDietChanged;
  final String? initialDiet;
  final ValueChanged<bool>? onCanProceedChanged;
  final bool keepAlive;
  final String? customPreferences;

  @override
  State<PersonalDetailsDietScreen> createState() => _PersonalDetailsDietScreenState();
}

class _PersonalDetailsDietScreenState extends State<PersonalDetailsDietScreen> with AutomaticKeepAliveClientMixin {
  String? _selected;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDiet;
    if (widget.onCanProceedChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCanProceedChanged?.call(_selected != null);
      });
    }
  }

  void _selectDiet(String diet) {
    setState(() => _selected = diet);
    widget.onDietChanged?.call(diet);
    if (widget.onCanProceedChanged != null) {
      widget.onCanProceedChanged!(true);
    } else {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ProfileGradientScaffold(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: tr(LocaleKeys.personal_details_diet), onBack: widget.onBack),
          const SizedBox(height: AppSpacing.l),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_classic),
            selected: _selected == 'classic',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.restaurant),
            onTap: () => _selectDiet('classic'),
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_vegetarian),
            selected: _selected == 'vegetarian',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.eco_outlined),
            onTap: () => _selectDiet('vegetarian'),
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_vegan),
            selected: _selected == 'vegan',
            height: AppSizes.optionCardHeightLarge,
            leading: const _DietIcon(icon: Icons.energy_savings_leaf_outlined),
            onTap: () => _selectDiet('vegan'),
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
            onTap: () => _selectDiet('custom'),
          ),
          if (_selected == 'custom' && (widget.customPreferences?.trim().isNotEmpty ?? false)) ...[
            const SizedBox(height: AppSpacing.m),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
              child: Text(
                widget.customPreferences!.trim(),
                style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w400),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
