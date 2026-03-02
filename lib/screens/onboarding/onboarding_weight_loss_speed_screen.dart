import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingWeightLossSpeedScreen extends StatefulWidget {
  const OnboardingWeightLossSpeedScreen({
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
  State<OnboardingWeightLossSpeedScreen> createState() => _OnboardingWeightLossSpeedScreenState();
}

class _OnboardingWeightLossSpeedScreenState extends State<OnboardingWeightLossSpeedScreen> {
  static const double _minSpeedKgPerWeek = 0.1;
  static const double _maxSpeedKgPerWeek = 1.5;

  double _value = 0.8;

  double _recommendedSpeedFromWeightKg(double? weightKg) {
    if (weightKg == null) return 0.8;
    // 0.75% of body weight per week.
    final double raw = weightKg * 0.0075;
    final double roundedToTenth = (raw * 10).round() / 10;
    return roundedToTenth.clamp(_minSpeedKgPerWeek, _maxSpeedKgPerWeek);
  }

  @override
  void initState() {
    super.initState();
    final double? storedSpeed = SessionManager.to.weightChangeRateKgPerWeek.value;
    if (storedSpeed != null) {
      _value = storedSpeed.clamp(_minSpeedKgPerWeek, _maxSpeedKgPerWeek);
      return;
    }
    _value = _recommendedSpeedFromWeightKg(SessionManager.to.weightKg.value);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: tr(LocaleKeys.common_continue_btn),
        onPressed: () async {
          await SessionManager.to.setWeightChangeRateKgPerWeek(_value);
          widget.onNext();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How fast do you want to reach your goal?',
            style: textTheme.headlineLarge?.copyWith(height: 1.25),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Text(
                  'Weight loss speed per week',
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s),
                Text('${_value.toStringAsFixed(1)} kg', style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              const SizedBox(width: AppSpacing.xs),
              const Icon(CupertinoIcons.tortoise, size: AppSizes.iconLg),
              //const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned(
                      left: AppSpacing.l,
                      right: AppSpacing.l,
                      child: OnboardingSliderTicks(count: 5),
                    ),
                    OnboardingSlider(
                      value: _value,
                      min: _minSpeedKgPerWeek,
                      max: _maxSpeedKgPerWeek,
                      onChanged: (value) => setState(() => _value = value),
                    ),
                  ],
                ),
              ),
              //const SizedBox(width: AppSpacing.xs),
              const Icon(CupertinoIcons.hare, size: AppSizes.iconLg),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: AppSpacing.xs),
              Text('0.1 kg', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(width: AppSpacing.xs),
              const SizedBox(width: AppSpacing.xs),
              const SizedBox(width: AppSpacing.xs),
              const SizedBox(width: AppSpacing.xs),
              Text('1.5 kg', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.md),
                onTap: () {
                  final double recommended = _recommendedSpeedFromWeightKg(SessionManager.to.weightKg.value);
                  setState(() => _value = recommended);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.s),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Text(
                    'Recommended',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
