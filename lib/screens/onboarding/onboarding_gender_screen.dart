import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OnboardingGenderScreen extends StatefulWidget {
  const OnboardingGenderScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    this.progress,
    this.onCanProceedChanged,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final double? progress;
  final ValueChanged<bool>? onCanProceedChanged;

  @override
  State<OnboardingGenderScreen> createState() => _OnboardingGenderScreenState();
}

class _OnboardingGenderScreenState extends State<OnboardingGenderScreen> with AutomaticKeepAliveClientMixin {
  ProfileSex? _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selected = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanProceedChanged?.call(_selected != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.progress,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: tr(LocaleKeys.common_continue_btn),
        isEnabled: _selected != null,
        onPressed: _selected != null
            ? () async {
                await SessionManager.to.setSex(_selected);
                widget.onNext();
              }
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.onboarding_gender_title), style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.s),
          Text(
            tr(LocaleKeys.onboarding_gender_subtitle),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_male),
            selected: _selected == ProfileSex.male,
            onTap: () {
              setState(() => _selected = ProfileSex.male);
              widget.onCanProceedChanged?.call(true);
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_female),
            selected: _selected == ProfileSex.female,
            onTap: () {
              setState(() => _selected = ProfileSex.female);
              widget.onCanProceedChanged?.call(true);
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_other),
            selected: _selected == ProfileSex.other,
            onTap: () {
              setState(() => _selected = ProfileSex.other);
              widget.onCanProceedChanged?.call(true);
            },
          ),
        ],
      ),
    );
  }
}
