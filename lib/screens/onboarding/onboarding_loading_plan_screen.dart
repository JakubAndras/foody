import 'dart:async';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/nutrition_goals.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/services/nutrition_goals_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/mesh_gradient_background.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class OnboardingLoadingPlanScreen extends ConsumerStatefulWidget {
  const OnboardingLoadingPlanScreen({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<OnboardingLoadingPlanScreen> createState() => _OnboardingLoadingPlanScreenState();
}

class _OnboardingLoadingPlanScreenState extends ConsumerState<OnboardingLoadingPlanScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    unawaited(_computeAndSaveGoals());
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isComplete = true);
        }
      })
      ..forward();
  }

  Future<void> _computeAndSaveGoals() async {
    final session = ref.read(sessionProvider);
    final double? weightKg = session.weightKg;
    final double? heightCm = session.heightCm;
    final DateTime? dob = session.dateOfBirth;
    final ProfileSex? sex = session.sex;
    final ProfileGoal? goal = session.goal;

    if (weightKg == null || heightCm == null || dob == null || sex == null || goal == null) return;

    final goals = NutritionGoals.fromProfile(
      weightKg: weightKg,
      heightCm: heightCm,
      dateOfBirth: dob,
      sex: sex,
      goal: goal,
      workoutsPerWeek: session.workoutsPerWeek ?? '2-3',
      weightChangeRateKgPerWeek: session.weightChangeRateKgPerWeek,
    );

    await ref.read(nutritionGoalsProvider.notifier).saveGoalsEffectiveFromDate(effectiveDate: DateTime.now(), goals: goals);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return LiquidGlassScope(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LiquidGlassBackground(
          child: Stack(
            children: [
              const MeshGradientBackground(),
              SafeArea(
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    final double progress = _progressController.value.clamp(0, 1);
                    final int percent = (progress * 100).round();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.xxl),
                          Center(
                            child: Text('$percent%', style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Center(
                            child: Text(
                              tr(LocaleKeys.onboarding_loading_title),
                              textAlign: TextAlign.center,
                              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            child: Container(
                              height: AppSizes.progressBarHeight,
                              color: AppColors.outline,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(decoration: const BoxDecoration(gradient: AppGradients.loading)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Center(
                            child: Text(tr(LocaleKeys.onboarding_loading_subtitle), style: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted)),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(tr(LocaleKeys.onboarding_daily_recommendation_for), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: AppSpacing.s),
                          _Bullet(text: tr(LocaleKeys.common_calories)),
                          _Bullet(text: tr(LocaleKeys.common_carbs)),
                          _Bullet(text: tr(LocaleKeys.common_protein)),
                          _Bullet(text: tr(LocaleKeys.common_fats)),
                          const Spacer(),
                          if (_isComplete)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.bottom),
                              child: OnboardingPrimaryButton(label: tr(LocaleKeys.common_continue_btn), onPressed: widget.onNext),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text('•', style: style),
          const SizedBox(width: AppSpacing.s),
          Text(text, style: style),
        ],
      ),
    );
  }
}
