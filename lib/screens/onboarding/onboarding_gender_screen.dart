import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

class OnboardingGenderScreen extends StatefulWidget {
  const OnboardingGenderScreen({
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
  State<OnboardingGenderScreen> createState() => _OnboardingGenderScreenState();
}

class _OnboardingGenderScreenState extends State<OnboardingGenderScreen> {
  ProfileSex? _selected;

  @override
  void initState() {
    super.initState();
    _selected = SessionManager.to.sex.value;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: 'Continue',
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
          Text('Choose your Gender', style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This will be used to calibrate your custom plan.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          OnboardingOptionCard(
            title: 'Male',
            selected: _selected == ProfileSex.male,
            onTap: () => setState(() => _selected = ProfileSex.male),
          ),
          const SizedBox(height: AppSpacing.sm),
          OnboardingOptionCard(
            title: 'Female',
            selected: _selected == ProfileSex.female,
            onTap: () => setState(() => _selected = ProfileSex.female),
          ),
          const SizedBox(height: AppSpacing.sm),
          OnboardingOptionCard(
            title: 'Other',
            selected: _selected == ProfileSex.other,
            onTap: () => setState(() => _selected = ProfileSex.other),
          ),
        ],
      ),
    );
  }
}
