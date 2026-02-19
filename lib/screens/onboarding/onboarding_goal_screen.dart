import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
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
        label: 'Continue',
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
          Text('What is your goal?', style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.s),
          Text(
            'This helps us generate a plan for your calorie intake.',
            style:
                textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          OnboardingOptionCard(
            title: 'Lose weight',
            selected: _selected == ProfileGoal.lose,
            onTap: () {
              setState(() => _selected = ProfileGoal.lose);
              widget.onCanProceedChanged?.call(true);
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: 'Maintain',
            selected: _selected == ProfileGoal.maintain,
            onTap: () {
              setState(() => _selected = ProfileGoal.maintain);
              widget.onCanProceedChanged?.call(true);
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: 'Gain weight',
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
