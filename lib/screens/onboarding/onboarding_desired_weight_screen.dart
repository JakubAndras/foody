import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/material.dart';

class OnboardingDesiredWeightScreen extends StatefulWidget {
  const OnboardingDesiredWeightScreen({
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
  State<OnboardingDesiredWeightScreen> createState() => _OnboardingDesiredWeightScreenState();
}

class _OnboardingDesiredWeightScreenState extends State<OnboardingDesiredWeightScreen> {
  static const double _minKg = 40;
  static const double _maxKg = 120;
  static const double _goalDeltaKg = 5;

  double _valueKg = 82.5;
  bool _metric = true;

  double _kgToPounds(double kg) => kg * 2.20462262185;

  double _poundsToKg(double pounds) => pounds / 2.20462262185;

  double get _minDisplayValue => _metric ? _minKg : _kgToPounds(_minKg).roundToDouble();

  double get _maxDisplayValue => _metric ? _maxKg : _kgToPounds(_maxKg).roundToDouble();

  double get _displayValue {
    final converted = _metric ? _valueKg : _kgToPounds(_valueKg);
    return converted.clamp(_minDisplayValue, _maxDisplayValue);
  }

  String get _displayWeightText {
    final int roundedValue = _displayValue.round();
    final String unit = _metric ? 'kg' : 'lb';
    return '$roundedValue $unit';
  }

  @override
  void initState() {
    super.initState();
    _metric = SessionManager.to.prefersMetric.value;

    final double? existingGoalWeight = SessionManager.to.goalWeightKg.value;
    if (existingGoalWeight != null) {
      _valueKg = existingGoalWeight;
    } else {
      final double? currentWeightKg = SessionManager.to.weightKg.value;
      final ProfileGoal? goal = SessionManager.to.goal.value;
      if (currentWeightKg != null) {
        switch (goal) {
          case ProfileGoal.lose:
            _valueKg = currentWeightKg - _goalDeltaKg;
            break;
          case ProfileGoal.gain:
            _valueKg = currentWeightKg + _goalDeltaKg;
            break;
          case ProfileGoal.maintain:
          case null:
            _valueKg = currentWeightKg;
            break;
        }
      }
    }

    _valueKg = _valueKg.clamp(_minKg, _maxKg);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double sliderHostHeight = (MediaQuery.of(context).size.height * 0.4).clamp(180.0, 320.0).toDouble();

    return OnboardingPage(
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: 'Continue',
        onPressed: () async {
          await SessionManager.to.setGoalWeightKg(_valueKg);
          widget.onNext();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is your desired weight?', style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            height: sliderHostHeight,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _displayWeightText,
                      style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    OnboardingSlider(
                      value: _displayValue,
                      min: _minDisplayValue,
                      max: _maxDisplayValue,
                      onChanged: (value) => setState(() {
                        if (_metric) {
                          _valueKg = value;
                        } else {
                          _valueKg = _poundsToKg(value);
                        }
                        _valueKg = _valueKg.clamp(_minKg, _maxKg);
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
