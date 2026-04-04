import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class OnboardingWorkoutsScreen extends StatefulWidget {
  const OnboardingWorkoutsScreen({super.key, required this.onNext, required this.onBack, required this.step, required this.totalSteps, this.onCanProceedChanged});

  final VoidCallback onNext;
  final VoidCallback onBack;
  final int step;
  final int totalSteps;
  final ValueChanged<bool>? onCanProceedChanged;

  @override
  State<OnboardingWorkoutsScreen> createState() => _OnboardingWorkoutsScreenState();
}

class _OnboardingWorkoutsScreenState extends State<OnboardingWorkoutsScreen> with AutomaticKeepAliveClientMixin {
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
        onPressed: _selected != null
            ? () async {
                await SessionManager.to.setWorkoutsPerWeek(_selected);
                widget.onNext();
              }
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.onboarding_workouts_title), style: textTheme.headlineLarge?.copyWith(height: 1.25)),
          const SizedBox(height: AppSpacing.s),
          Text(tr(LocaleKeys.onboarding_gender_subtitle), style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_workouts_0_1),
            subtitle: tr(LocaleKeys.onboarding_workouts_0_1_desc),
            selected: _selected == '0-1',
            height: AppSizes.workoutCardHeight,
            leading: _WorkoutIcon(selected: _selected == '0-1', icon: CupertinoIcons.moon_zzz),
            onTap: () {
              setState(() => _selected = '0-1');
              widget.onCanProceedChanged?.call(true);
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_workouts_2_3),
            subtitle: tr(LocaleKeys.onboarding_workouts_2_3_desc),
            selected: _selected == '2-3',
            height: AppSizes.workoutCardHeight,
            leading: _WorkoutIcon(selected: _selected == '2-3', icon: CupertinoIcons.person),
            onTap: () {
              setState(() => _selected = '2-3');
              widget.onCanProceedChanged?.call(true);
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_workouts_4_5),
            subtitle: tr(LocaleKeys.onboarding_workouts_4_5_desc),
            selected: _selected == '4-5',
            height: AppSizes.workoutCardHeight,
            leading: _WorkoutIcon(selected: _selected == '4-5', icon: CupertinoIcons.bolt),
            onTap: () {
              setState(() => _selected = '4-5');
              widget.onCanProceedChanged?.call(true);
            },
          ),
          const SizedBox(height: AppSpacing.s),
          OnboardingOptionCard(
            title: tr(LocaleKeys.onboarding_workouts_6_plus),
            subtitle: tr(LocaleKeys.onboarding_workouts_6_plus_desc),
            selected: _selected == '6+',
            height: AppSizes.workoutCardHeight,
            leading: _WorkoutIcon(selected: _selected == '6+', icon: CupertinoIcons.flame),
            onTap: () {
              setState(() => _selected = '6+');
              widget.onCanProceedChanged?.call(true);
            },
          ),
        ],
      ),
    );
  }
}

class _WorkoutIcon extends StatelessWidget {
  const _WorkoutIcon({required this.selected, required this.icon});

  final bool selected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.iconXl,
      height: AppSizes.iconXl,
      decoration: BoxDecoration(color: selected ? AppColors.onPrimary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: selected ? AppColors.onPrimary : AppColors.textPrimary, size: AppSizes.iconLg),
    );
  }
}
