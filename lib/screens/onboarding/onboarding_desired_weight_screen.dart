import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:diplomka/widgets/picker_column.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingDesiredWeightScreen extends ConsumerStatefulWidget {
  const OnboardingDesiredWeightScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    this.progress,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final double? progress;

  @override
  ConsumerState<OnboardingDesiredWeightScreen> createState() => _OnboardingDesiredWeightScreenState();
}

class _OnboardingDesiredWeightScreenState extends ConsumerState<OnboardingDesiredWeightScreen> {
  static const int _absoluteMinKg = 40;
  static const int _absoluteMaxKg = 179;

  late final List<int> _weightKgValues;
  late final List<int> _weightLbValues;
  int _selectedWeightKg = 75;
  bool _metric = true;

  int _kgToPounds(int kg) => (kg * 2.20462262185).round();

  int _poundsToKg(int pounds) => (pounds / 2.20462262185).round();

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider);
    _metric = session.prefersMetric;
    final ProfileGoal? goal = session.goal;
    final int currentKg = (session.weightKg ?? 80).round().clamp(_absoluteMinKg, _absoluteMaxKg);

    // Lose → values below current weight; Gain → values above current weight
    final int minKg = goal == ProfileGoal.gain ? currentKg : _absoluteMinKg;
    final int maxKg = goal == ProfileGoal.lose ? currentKg : _absoluteMaxKg;

    _weightKgValues = List.generate(maxKg - minKg + 1, (index) => minKg + index);
    _weightLbValues = List.generate(_kgToPounds(_weightKgValues.last) - _kgToPounds(_weightKgValues.first) + 1, (index) => _kgToPounds(_weightKgValues.first) + index);

    // Start picker at current weight
    _selectedWeightKg = currentKg;
  }

  int get _weightSelectedIndex {
    if (_metric) {
      return (_selectedWeightKg - _weightKgValues.first).clamp(0, _weightKgValues.length - 1);
    }
    final int selectedPounds = _kgToPounds(_selectedWeightKg);
    return (selectedPounds - _weightLbValues.first).clamp(0, _weightLbValues.length - 1);
  }

  List<String> get _weightDisplayValues {
    if (_metric) {
      return _weightKgValues.map((value) => '$value kg').toList();
    }
    return _weightLbValues.map((value) => '$value lb').toList();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.progress,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: tr(LocaleKeys.common_continue_btn),
        onPressed: () async {
          await ref.read(sessionProvider.notifier).setGoalWeightKg(_selectedWeightKg.toDouble());
          widget.onNext();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.onboarding_desired_weight_title), style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.s),
          Text(tr(LocaleKeys.onboarding_gender_subtitle), style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          Center(
            child: PickerColumn(
              key: ValueKey('goal-weight-${_metric ? 'metric' : 'imperial'}'),
              values: _weightDisplayValues,
              selectedIndex: _weightSelectedIndex,
              height: AppSizes.pickerHeight,
              onSelected: (index) {
                if (_metric) {
                  _selectedWeightKg = _weightKgValues[index];
                } else {
                  _selectedWeightKg = _poundsToKg(_weightLbValues[index]);
                }
                _selectedWeightKg = _selectedWeightKg.clamp(_weightKgValues.first, _weightKgValues.last);
              },
            ),
          ),
        ],
      ),
    );
  }
}
