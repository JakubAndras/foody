import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

class PersonalDetailsCustomDietScreen extends StatefulWidget {
  const PersonalDetailsCustomDietScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    this.initialPreferences,
    this.onPreferencesSaved,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final String? initialPreferences;
  final ValueChanged<String>? onPreferencesSaved;

  @override
  State<PersonalDetailsCustomDietScreen> createState() => _PersonalDetailsCustomDietScreenState();
}

class _PersonalDetailsCustomDietScreenState extends State<PersonalDetailsCustomDietScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialPreferences ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ProfileGradientScaffold(
      scroll: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        top: false,
        minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        child: OnboardingPrimaryButton(
          label: 'Continue',
          onPressed: () {
            widget.onPreferencesSaved?.call(_controller.text.trim());
            widget.onNext();
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: 'Custom Diet', onBack: widget.onBack),
          const SizedBox(height: AppSpacing.xl),
          Text(
            "Tell us about any food you don't eat, allergies, or dietary restrictions.",
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.l),
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
          const SizedBox(height: AppSizes.buttonHeight + AppSpacing.xl),
        ],
      ),
    );
  }
}
