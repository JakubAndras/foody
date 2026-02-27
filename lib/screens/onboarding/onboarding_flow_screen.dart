import 'dart:async';

import 'package:diplomka/model/user_profile.dart';
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
import 'package:diplomka/screens/onboarding/onboarding_desired_weight_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_weight_loss_speed_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_welcome_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_workouts_screen.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _showCustomDiet = false;
  bool _canSwipeForward = true;
  final Map<int, bool> _pageCanProceed = {};
  bool _isReverting = false;
  Offset? _dragStart;
  int? _dragPointer;

  void _next() {
    if (_index >= _screens.length - 1) {
      if (SessionManager.to.dietType.value == null) {
        unawaited(SessionManager.to.setDietType(ProfileDietType.classic));
      }
      unawaited(SessionManager.to.setOnboardingComplete(true));
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skipOnboarding() async {
    if (SessionManager.to.dietType.value == null) {
      await SessionManager.to.setDietType(ProfileDietType.classic);
    }
    await SessionManager.to.setOnboardingComplete(true);
  }

  void _previous() {
    if (_index <= 0) return;

    final List<Widget> screens = _screens;
    final bool shouldSkipLoadingScreen = _index > 0 && screens[_index] is OnboardingPlanReadyScreen && screens[_index - 1] is OnboardingLoadingPlanScreen;
    final int targetIndex = shouldSkipLoadingScreen ? _index - 2 : _index - 1;

    _controller.animateToPage(
      targetIndex.clamp(0, screens.length - 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  bool _isGateRequired(int index) {
    return index == 1 || index == 2 || index == 5 || index == 8;
  }

  bool _defaultCanProceed(int index) {
    return !_isGateRequired(index);
  }

  void _setCanProceed(int index, bool canProceed) {
    _pageCanProceed[index] = canProceed;
    if (_index == index && _canSwipeForward != canProceed) {
      setState(() => _canSwipeForward = canProceed);
    }
  }

  void _handleDietChanged(String diet) {
    final ProfileDietType? selectedDietType = profileDietTypeFromCode(diet);
    if (selectedDietType != null) {
      unawaited(SessionManager.to.setDietType(selectedDietType));
      if (selectedDietType != ProfileDietType.custom) {
        unawaited(SessionManager.to.setCustomDietPreferences(null));
      }
    }

    final bool shouldShowCustomDiet = diet == 'custom';
    if (_showCustomDiet == shouldShowCustomDiet) return;
    setState(() => _showCustomDiet = shouldShowCustomDiet);
  }

  List<Widget> get _screens {
    final int totalSteps = _showCustomDiet ? 14 : 13;
    final int customStep = 9;
    final int calorieBurnStep = _showCustomDiet ? 10 : 9;
    final int rolloverStep = _showCustomDiet ? 11 : 10;
    final int loadingStep = _showCustomDiet ? 12 : 11;
    final int planReadyStep = _showCustomDiet ? 13 : 12;
    final int saveProgressStep = _showCustomDiet ? 14 : 13;

    return [
      OnboardingWelcomeScreen(onNext: _next, onSkip: _skipOnboarding),
      OnboardingGenderScreen(onNext: _next, onBack: _previous, step: 1, totalSteps: totalSteps, onCanProceedChanged: (canProceed) => _setCanProceed(1, canProceed)),
      OnboardingWorkoutsScreen(onNext: _next, onBack: _previous, step: 2, totalSteps: totalSteps, onCanProceedChanged: (canProceed) => _setCanProceed(2, canProceed)),
      OnboardingHeightWeightScreen(onNext: _next, onBack: _previous, step: 3, totalSteps: totalSteps),
      OnboardingDobScreen(onNext: _next, onBack: _previous, step: 4, totalSteps: totalSteps),
      OnboardingGoalScreen(onNext: _next, onBack: _previous, step: 5, totalSteps: totalSteps, onCanProceedChanged: (canProceed) => _setCanProceed(5, canProceed)),
      OnboardingDesiredWeightScreen(onNext: _next, onBack: _previous, step: 6, totalSteps: totalSteps),
      OnboardingWeightLossSpeedScreen(onNext: _next, onBack: _previous, step: 7, totalSteps: totalSteps),
      OnboardingDietScreen(
        onNext: _next,
        onBack: _previous,
        step: 8,
        totalSteps: totalSteps,
        onCanProceedChanged: (canProceed) => _setCanProceed(8, canProceed),
        onDietChanged: _handleDietChanged,
      ),
      if (_showCustomDiet)
        OnboardingCustomDietScreen(
          onNext: _next,
          onBack: _previous,
          step: customStep,
          totalSteps: totalSteps,
          initialPreferences: SessionManager.to.customDietPreferences.value,
          onPreferencesSaved: (value) => unawaited(SessionManager.to.setCustomDietPreferences(value)),
        ),
      OnboardingCalorieBurnScreen(onNext: _next, onBack: _previous, step: calorieBurnStep, totalSteps: totalSteps),
      OnboardingRolloverScreen(onNext: _next, onBack: _previous, step: rolloverStep, totalSteps: totalSteps),
      OnboardingLoadingPlanScreen(onNext: _next, step: loadingStep, totalSteps: totalSteps),
      OnboardingPlanReadyScreen(onNext: _next, onBack: _previous, step: planReadyStep, totalSteps: totalSteps),
      OnboardingSaveProgressScreen(onNext: _next, onBack: _previous, step: saveProgressStep, totalSteps: totalSteps),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (!_canSwipeForward) {
          _dragStart = event.position;
          _dragPointer = event.pointer;
        }
      },
      onPointerMove: (event) {
        if (_canSwipeForward || _dragPointer != event.pointer || _dragStart == null) {
          return;
        }

        final Offset delta = event.position - _dragStart!;
        if (delta.distance < kTouchSlop) {
          return;
        }

        if (delta.dx.abs() <= delta.dy.abs()) {
          return;
        }

        final bool forwardDrag = textDirection == TextDirection.rtl ? delta.dx > 0 : delta.dx < 0;
        if (forwardDrag) {
          GestureBinding.instance.cancelPointer(event.pointer);
          _dragPointer = null;
          _dragStart = null;
        } else {
          _dragPointer = null;
          _dragStart = null;
        }
      },
      onPointerCancel: (_) {
        _dragPointer = null;
        _dragStart = null;
      },
      onPointerUp: (_) {
        _dragPointer = null;
        _dragStart = null;
      },
      child: PageView(
        controller: _controller,
        physics: _OnboardingPagePhysics(
          allowForward: _canSwipeForward,
          parent: const BouncingScrollPhysics(),
        ),
        onPageChanged: (index) {
          if (_isReverting) {
            _isReverting = false;
            setState(() {
              _index = index;
              _canSwipeForward = _pageCanProceed[index] ?? _defaultCanProceed(index);
            });
            return;
          }

          if (!_canSwipeForward && index > _index) {
            _isReverting = true;
            _controller.animateToPage(
              _index,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
            );
            return;
          }

          setState(() {
            _index = index;
            _canSwipeForward = _pageCanProceed[index] ?? _defaultCanProceed(index);
          });
        },
        children: _screens,
      ),
    );
  }
}

class _OnboardingPagePhysics extends PageScrollPhysics {
  const _OnboardingPagePhysics({
    required this.allowForward,
    super.parent,
  });

  final bool allowForward;

  @override
  _OnboardingPagePhysics applyTo(ScrollPhysics? ancestor) {
    return _OnboardingPagePhysics(
      allowForward: allowForward,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (!allowForward && _isForward(position, value)) {
      return value - position.pixels;
    }
    return super.applyBoundaryConditions(position, value);
  }

  bool _isForward(ScrollMetrics position, double value) {
    switch (position.axisDirection) {
      case AxisDirection.right:
      case AxisDirection.down:
        return value > position.pixels;
      case AxisDirection.left:
      case AxisDirection.up:
        return value < position.pixels;
    }
  }
}
