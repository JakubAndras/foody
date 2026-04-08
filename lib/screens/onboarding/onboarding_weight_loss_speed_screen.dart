import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class OnboardingWeightLossSpeedScreen extends StatefulWidget {
  const OnboardingWeightLossSpeedScreen({super.key, required this.onNext, required this.onBack, required this.step, required this.totalSteps});

  final VoidCallback onNext;
  final VoidCallback onBack;
  final int step;
  final int totalSteps;

  @override
  State<OnboardingWeightLossSpeedScreen> createState() => _OnboardingWeightLossSpeedScreenState();
}

class _OnboardingWeightLossSpeedScreenState extends State<OnboardingWeightLossSpeedScreen> {
  static const double _minSpeed = 0.1;
  static const double _maxSpeedGain = 1.0;

  double _value = 0.8;

  bool get _isGain => SessionManager.to.goal.value == ProfileGoal.gain;

  /// Max loss speed scales with body weight: ~1.2% of body weight.
  /// 100 kg → 1.2, 125 kg → 1.5, 75 kg → 0.9. Clamped to [0.5, 1.5].
  double _maxSpeedLose(double? weightKg) {
    if (weightKg == null) return 1.2;
    final raw = (weightKg * 0.012 * 10).round() / 10;
    return raw.clamp(0.5, 1.5);
  }

  double get _maxSpeed => _isGain ? _maxSpeedGain : _maxSpeedLose(SessionManager.to.weightKg.value);

  double _recommendedSpeed(double? weightKg) {
    if (weightKg == null) return _isGain ? 0.4 : 0.8;
    // Lose: 0.75% of body weight; Gain: 0.5% of body weight (gentler).
    final double factor = _isGain ? 0.005 : 0.0075;
    final double raw = weightKg * factor;
    final double roundedToTenth = (raw * 10).round() / 10;
    return roundedToTenth.clamp(_minSpeed, _maxSpeed);
  }

  @override
  void initState() {
    super.initState();
    final double? storedSpeed = SessionManager.to.weightChangeRateKgPerWeek.value;
    if (storedSpeed != null) {
      _value = storedSpeed.clamp(_minSpeed, _maxSpeed);
      return;
    }
    _value = _recommendedSpeed(SessionManager.to.weightKg.value);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final speedLabel = _isGain ? tr(LocaleKeys.onboarding_weight_gain_speed_per_week) : tr(LocaleKeys.onboarding_weight_loss_speed_per_week);

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
          Text(tr(LocaleKeys.onboarding_weight_loss_goal_title), style: textTheme.headlineLarge?.copyWith(height: 1.25)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(
            child: Column(
              children: [
                Text(speedLabel, style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
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
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: GlassSlider(
                  value: _value,
                  min: _minSpeed,
                  max: _maxSpeed,
                  activeColor: AppColors.primary,
                  thumbColor: AppColors.primary,
                  trackHeight: 8,
                  thumbRadius: 18,
                  onChanged: (value) {
                    final snapped = ((value * 10).round() / 10).clamp(_minSpeed, _maxSpeed);
                    setState(() => _value = snapped);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.m),
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
              Text('${_maxSpeed.toStringAsFixed(1)} kg', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          if ((_value - _recommendedSpeed(SessionManager.to.weightKg.value)).abs() > 0.05)
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.m),
                  onTap: () {
                    final double recommended = _recommendedSpeed(SessionManager.to.weightKg.value);
                    setState(() => _value = recommended);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.s),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.m)),
                    child: Text(
                      tr(LocaleKeys.onboarding_recommended),
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
