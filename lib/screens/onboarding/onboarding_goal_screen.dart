import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OnboardingGoalScreen extends StatefulWidget {
  const OnboardingGoalScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.step,
    required this.totalSteps,
    this.onCanProceedChanged,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final int step;
  final int totalSteps;
  final ValueChanged<bool>? onCanProceedChanged;

  @override
  State<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends State<OnboardingGoalScreen>
    with AutomaticKeepAliveClientMixin {
  ProfileGoal? _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selected = SessionManager.to.goal.value;
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
        onPressed: _selected != null
            ? () async {
                await SessionManager.to.setGoal(_selected);
                widget.onNext();
              }
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.onboarding_goal_title), style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.s),
          Text(
            tr(LocaleKeys.onboarding_goal_subtitle),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_lose_weight),
            selected: _selected == ProfileGoal.lose,
            onTap: () {
              setState(() => _selected = ProfileGoal.lose);
              widget.onCanProceedChanged?.call(true);
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_maintain),
            selected: _selected == ProfileGoal.maintain,
            onTap: () {
              setState(() => _selected = ProfileGoal.maintain);
              widget.onCanProceedChanged?.call(true);
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_gain_weight),
            selected: _selected == ProfileGoal.gain,
            onTap: () {
              setState(() => _selected = ProfileGoal.gain);
              widget.onCanProceedChanged?.call(true);
            },
          ),
        ],
      ),
    );
  }
}
