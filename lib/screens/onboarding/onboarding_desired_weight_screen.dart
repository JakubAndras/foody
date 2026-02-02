import 'package:diplomka/app_theme.dart';
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
  double _value = 82.5;

  @override
  void initState() {
    super.initState();
    final existing = SessionManager.to.goalWeightKg.value ?? SessionManager.to.weightKg.value;
    if (existing != null) {
      _value = existing.clamp(40, 180);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: 'Continue',
        onPressed: () async {
          await SessionManager.to.setGoalWeightKg(_value);
          widget.onNext();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is your desired weight?', style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Text(
              '${_value.toStringAsFixed(1)} kg',
              style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const OnboardingRuler(),
          const SizedBox(height: AppSpacing.lg),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 40,
              max: 180,
              divisions: 140,
              value: _value,
              onChanged: (value) => setState(() => _value = value),
            ),
          ),
        ],
      ),
    );
  }
}
