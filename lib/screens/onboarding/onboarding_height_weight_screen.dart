import 'package:diplomka/app_theme.dart';
import 'package:diplomka/state/weight_entry_notifier.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:diplomka/widgets/picker_column.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class OnboardingHeightWeightScreen extends ConsumerStatefulWidget {
  const OnboardingHeightWeightScreen({super.key, required this.onNext, required this.onBack, this.progress});

  final VoidCallback onNext;
  final VoidCallback onBack;
  final double? progress;

  @override
  ConsumerState<OnboardingHeightWeightScreen> createState() => _OnboardingHeightWeightScreenState();
}

class _OnboardingHeightWeightScreenState extends ConsumerState<OnboardingHeightWeightScreen> {
  bool _metric = true;
  late final List<int> _heightCmValues;
  late final List<int> _weightKgValues;
  late final List<int> _heightInchValues;
  late final List<int> _weightLbValues;
  int _selectedHeightCm = _otherDefaultHeightCm;
  int _selectedWeightKg = _otherDefaultWeightKg;

  static const int _maleDefaultHeightCm = 175;
  static const int _maleDefaultWeightKg = 80;
  static const int _femaleDefaultHeightCm = 160;
  static const int _femaleDefaultWeightKg = 60;
  // ProfileSex.other averages male and female defaults.
  static const int _otherDefaultHeightCm = 168;
  static const int _otherDefaultWeightKg = 70;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider);
    _metric = session.prefersMetric;
    _heightCmValues = List.generate(120, (index) => 140 + index);
    _weightKgValues = List.generate(140, (index) => 40 + index);
    _heightInchValues = List.generate(_cmToInches(_heightCmValues.last) - _cmToInches(_heightCmValues.first) + 1, (index) => _cmToInches(_heightCmValues.first) + index);
    _weightLbValues = List.generate(_kgToPounds(_weightKgValues.last) - _kgToPounds(_weightKgValues.first) + 1, (index) => _kgToPounds(_weightKgValues.first) + index);

    final double? storedHeight = session.heightCm;
    final double? storedWeight = session.weightKg;
    if (storedHeight != null) {
      _selectedHeightCm = storedHeight.round();
    } else {
      _selectedHeightCm = switch (session.sex) {
        ProfileSex.male => _maleDefaultHeightCm,
        ProfileSex.female => _femaleDefaultHeightCm,
        ProfileSex.other || null => _otherDefaultHeightCm,
      };
    }
    if (storedWeight != null) {
      _selectedWeightKg = storedWeight.round();
    } else {
      _selectedWeightKg = switch (session.sex) {
        ProfileSex.male => _maleDefaultWeightKg,
        ProfileSex.female => _femaleDefaultWeightKg,
        ProfileSex.other || null => _otherDefaultWeightKg,
      };
    }

    _selectedHeightCm = _selectedHeightCm.clamp(_heightCmValues.first, _heightCmValues.last);
    _selectedWeightKg = _selectedWeightKg.clamp(_weightKgValues.first, _weightKgValues.last);
  }

  int _cmToInches(int cm) => (cm / 2.54).round();

  int _inchesToCm(int inches) => (inches * 2.54).round();

  int _kgToPounds(int kg) => (kg * 2.20462262185).round();

  int _poundsToKg(int pounds) => (pounds / 2.20462262185).round();

  String _formatFeetInches(int totalInches) {
    final int feet = totalInches ~/ 12;
    final int inches = totalInches % 12;
    return '$feet\'$inches"';
  }

  int get _heightSelectedIndex {
    if (_metric) {
      return (_selectedHeightCm - _heightCmValues.first).clamp(0, _heightCmValues.length - 1);
    }
    final int selectedInches = _cmToInches(_selectedHeightCm);
    return (selectedInches - _heightInchValues.first).clamp(0, _heightInchValues.length - 1);
  }

  int get _weightSelectedIndex {
    if (_metric) {
      return (_selectedWeightKg - _weightKgValues.first).clamp(0, _weightKgValues.length - 1);
    }
    final int selectedPounds = _kgToPounds(_selectedWeightKg);
    return (selectedPounds - _weightLbValues.first).clamp(0, _weightLbValues.length - 1);
  }

  List<String> get _heightDisplayValues {
    if (_metric) {
      return _heightCmValues.map((value) => '$value cm').toList();
    }
    return _heightInchValues.map(_formatFeetInches).toList();
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
          final sessionNotifier = ref.read(sessionProvider.notifier);
          await sessionNotifier.setHeightCm(_selectedHeightCm.toDouble());
          await sessionNotifier.setWeightKg(_selectedWeightKg.toDouble());
          await sessionNotifier.setPrefersMetric(_metric);
          await ref.read(weightEntriesProvider.notifier).saveEntry(WeightEntry(date: DateTime.now(), weight: _selectedWeightKg.toDouble()));
          widget.onNext();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.onboarding_height_weight_title), style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.s),
          Text(tr(LocaleKeys.onboarding_gender_subtitle), style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Center(
            child: _UnitToggle(metric: _metric, onChanged: (value) => setState(() => _metric = value)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(tr(LocaleKeys.onboarding_height), style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.s),
                    PickerColumn(
                      key: ValueKey('height-${_metric ? 'metric' : 'imperial'}'),
                      values: _heightDisplayValues,
                      selectedIndex: _heightSelectedIndex,
                      height: AppSizes.pickerHeight,
                      onSelected: (index) {
                        if (_metric) {
                          _selectedHeightCm = _heightCmValues[index];
                        } else {
                          _selectedHeightCm = _inchesToCm(_heightInchValues[index]);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  children: [
                    Text(tr(LocaleKeys.common_weight), style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.s),
                    PickerColumn(
                      key: ValueKey('weight-${_metric ? 'metric' : 'imperial'}'),
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.metric, required this.onChanged});

  final bool metric;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onChanged(false),
          child: Text(tr(LocaleKeys.common_imperial), style: AppTextStyles.title18.copyWith(color: metric ? AppColors.textTertiary : AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: AppSpacing.m),
        GlassSwitch(value: metric, onChanged: onChanged, useOwnLayer: true, activeColor: AppColors.primary, inactiveColor: AppColors.primary),
        const SizedBox(width: AppSpacing.m),
        GestureDetector(
          onTap: () => onChanged(true),
          child: Text(tr(LocaleKeys.common_metric), style: AppTextStyles.title18.copyWith(color: metric ? AppColors.textPrimary : AppColors.textTertiary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
