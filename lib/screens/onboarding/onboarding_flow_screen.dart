import 'package:diplomka/screens/onboarding/onboarding_calorie_burn_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_custom_diet_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_diet_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_dob_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_gender_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_goal_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_height_weight_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_loading_plan_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_plan_ready_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_rollover_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_save_progress_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_signin_modal_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_desired_weight_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_weight_loss_speed_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_welcome_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_workouts_screen.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:flutter/material.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index >= _screens.length - 1) {
      SessionManager.to.setOnboardingComplete(true);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _previous() {
    if (_index <= 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  List<Widget> get _screens => [
        OnboardingWelcomeScreen(onNext: _next),
        OnboardingSignInModalScreen(onNext: _next),
        OnboardingGenderScreen(onNext: _next, onBack: _previous, step: 1, totalSteps: 14),
        OnboardingWorkoutsScreen(onNext: _next, onBack: _previous, step: 2, totalSteps: 14),
        OnboardingHeightWeightScreen(onNext: _next, onBack: _previous, step: 3, totalSteps: 14),
        OnboardingDobScreen(onNext: _next, onBack: _previous, step: 4, totalSteps: 14),
        OnboardingGoalScreen(onNext: _next, onBack: _previous, step: 5, totalSteps: 14),
        OnboardingDesiredWeightScreen(onNext: _next, onBack: _previous, step: 6, totalSteps: 14),
        OnboardingWeightLossSpeedScreen(onNext: _next, onBack: _previous, step: 7, totalSteps: 14),
        OnboardingDietScreen(onNext: _next, onBack: _previous, step: 8, totalSteps: 14),
        OnboardingCustomDietScreen(onNext: _next, onBack: _previous, step: 9, totalSteps: 14),
        OnboardingCalorieBurnScreen(onNext: _next, onBack: _previous, step: 10, totalSteps: 14),
        OnboardingRolloverScreen(onNext: _next, onBack: _previous, step: 11, totalSteps: 14),
        OnboardingLoadingPlanScreen(onNext: _next, step: 12, totalSteps: 14),
        OnboardingPlanReadyScreen(onNext: _next, onBack: _previous, step: 13, totalSteps: 14),
        OnboardingSaveProgressScreen(onNext: _next, onBack: _previous, step: 14, totalSteps: 14),
      ];

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (index) => setState(() => _index = index),
      children: _screens,
    );
  }
}
