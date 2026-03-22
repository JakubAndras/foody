import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PersonalDetailsCustomDietScreen extends StatefulWidget {
  const PersonalDetailsCustomDietScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    this.initialPreferences,
    this.onPreferencesSaved,
    this.keepAlive = false,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final String? initialPreferences;
  final ValueChanged<String>? onPreferencesSaved;
  final bool keepAlive;

  @override
  State<PersonalDetailsCustomDietScreen> createState() => _PersonalDetailsCustomDietScreenState();
}

class _PersonalDetailsCustomDietScreenState extends State<PersonalDetailsCustomDietScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _controller = TextEditingController();

  @override
  bool get wantKeepAlive => widget.keepAlive;

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
    super.build(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        top: false,
        minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            return OnboardingPrimaryButton(
              label: tr(LocaleKeys.common_save),
              isEnabled: hasText,
              onPressed: () {
                widget.onPreferencesSaved?.call(_controller.text.trim());
                widget.onNext();
              },
            );
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: tr(LocaleKeys.personal_details_custom_diet_title), onBack: widget.onBack),
          const SizedBox(height: AppSpacing.l),
          Text(
            tr(LocaleKeys.personal_details_custom_diet_subtitle),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            height: AppSizes.customDietFieldHeight,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.m),
            ),
            child: TextField(
              controller: _controller,
              maxLines: null,
              style: textTheme.titleMedium,
              decoration: InputDecoration.collapsed(
                hintText: tr(LocaleKeys.onboarding_custom_diet_hint),
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
