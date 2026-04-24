import 'dart:async';

import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/screens/profile/subscreens/personal_details_custom_diet_screen.dart';
import 'package:diplomka/screens/profile/subscreens/personal_details_diet_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_dob_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_gender_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_goal_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_height_weight_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_loading_plan_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_plan_ready_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_desired_weight_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_welcome_screen.dart';
import 'package:diplomka/screens/onboarding/onboarding_workouts_screen.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../main_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _showCustomDiet = false;
  bool _isGoalMaintain = false;
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
      Get.offAll(() => const MainScreen());
      return;
    }
    setState(() => _canSwipeForward = true);
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _skipOnboarding()  {
    print('[SKIP] _skipOnboarding called');
    try {
      if (SessionManager.to.dietType.value == null) {
        unawaited(SessionManager.to.setDietType(ProfileDietType.classic));
      }
      unawaited(SessionManager.to.setOnboardingComplete(true));
      Get.to(() => const MainScreen());
    } catch (e, st) {
      print('[SKIP] ERROR: $e\n$st');
    }
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

  Set<int> get _gateRequiredIndices {
    // Gender is always index 1, Workouts always index 2, Goal always index 5
    final Set<int> gates = {1, 2, 5};
    // Diet index shifts based on whether desired weight screen is shown
    final int dietIndex = _isGoalMaintain ? 6 : 7;
    gates.add(dietIndex);
    return gates;
  }

  bool _isGateRequired(int index) {
    return _gateRequiredIndices.contains(index);
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

  void _handleGoalChanged(ProfileGoal? goal) {
    final bool maintain = goal == ProfileGoal.maintain;
    if (_isGoalMaintain == maintain) return;
    _pageCanProceed.clear();
    setState(() => _isGoalMaintain = maintain);
  }

  void _handleDietChanged(String diet) {
    final ProfileDietType? selectedDietType = profileDietTypeFromCode(diet);
    if (selectedDietType != null) {
      unawaited(SessionManager.to.setDietType(selectedDietType));
    }

    final bool shouldShowCustomDiet = diet == 'custom';
    if (_showCustomDiet == shouldShowCustomDiet) return;
    setState(() => _showCustomDiet = shouldShowCustomDiet);
  }

  List<Widget> get _screens {
    final List<Widget> screens = [];

    final bool showDesiredWeight = !_isGoalMaintain;
    final bool showCustomDiet = _showCustomDiet;

    // Total screens in list:
    //   1 (welcome) + 1 (gender) + 1 (workouts) + 1 (height/weight) + 1 (dob)
    //   + 1 (goal) + (1 if desired weight) + 1 (diet) + (1 if custom diet)
    //   + 1 (loading) + 1 (plan ready)
    // = 10 + (1 if desired weight) + (1 if custom diet)
    final int totalScreens = 10 + (showDesiredWeight ? 1 : 0) + (showCustomDiet ? 1 : 0);

    // Progress screens = totalScreens - 2 (minus welcome and loading)
    final int progressScreenCount = totalScreens - 2;

    int progressIndex = 0;

    double nextProgress() {
      final double p = progressIndex / (progressScreenCount - 1);
      progressIndex++;
      return p.clamp(0.0, 1.0);
    }

    // Index 0: Welcome (no progress bar)
    screens.add(OnboardingWelcomeScreen(onNext: _next, onSkip: _skipOnboarding));

    // Index 1: Gender
    screens.add(OnboardingGenderScreen(
      onNext: _next,
      onBack: _previous,
      progress: nextProgress(),
      onCanProceedChanged: (canProceed) => _setCanProceed(1, canProceed),
    ));

    // Index 2: Workouts
    screens.add(OnboardingWorkoutsScreen(
      onNext: _next,
      onBack: _previous,
      progress: nextProgress(),
      onCanProceedChanged: (canProceed) => _setCanProceed(2, canProceed),
    ));

    // Index 3: Height & Weight
    screens.add(OnboardingHeightWeightScreen(onNext: _next, onBack: _previous, progress: nextProgress()));

    // Index 4: Date of Birth
    screens.add(OnboardingDobScreen(onNext: _next, onBack: _previous, progress: nextProgress()));

    // Index 5: Goal
    screens.add(OnboardingGoalScreen(
      onNext: _next,
      onBack: _previous,
      progress: nextProgress(),
      onCanProceedChanged: (canProceed) => _setCanProceed(5, canProceed),
      onGoalChanged: _handleGoalChanged,
    ));

    // Conditional: Desired Weight
    if (showDesiredWeight) {
      screens.add(OnboardingDesiredWeightScreen(
        onNext: () async {
          await SessionManager.to.applyRecommendedWeightChangeRate();
          _next();
        },
        onBack: _previous,
        progress: nextProgress(),
      ));
    }

    // Diet
    final int dietIndex = screens.length;
    screens.add(PersonalDetailsDietScreen(
      onNext: _next,
      onBack: _previous,
      keepAlive: true,
      progress: nextProgress(),
      onCanProceedChanged: (canProceed) => _setCanProceed(dietIndex, canProceed),
      onDietChanged: _handleDietChanged,
    ));

    // Custom Diet (conditional, no progress bar)
    if (showCustomDiet) {
      screens.add(PersonalDetailsCustomDietScreen(
        onNext: _next,
        onBack: _previous,
        keepAlive: true,
        initialPreferences: SessionManager.to.customDietPreferences.value,
        onPreferencesSaved: (value) => unawaited(SessionManager.to.setCustomDietPreferences(value)),
      ));
    }

    // Loading (no progress bar)
    screens.add(OnboardingLoadingPlanScreen(onNext: _next));

    // Plan Ready
    screens.add(OnboardingPlanReadyScreen(onNext: _next, onBack: _previous, progress: nextProgress()));

    return screens;
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
