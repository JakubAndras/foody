import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/weight_entry_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:diplomka/widgets/picker_column.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OnboardingHeightWeightScreen extends StatefulWidget {
  const OnboardingHeightWeightScreen({super.key, required this.onNext, required this.onBack, required this.step, required this.totalSteps});

  final VoidCallback onNext;
  final VoidCallback onBack;
  final int step;
  final int totalSteps;

  @override
  State<OnboardingHeightWeightScreen> createState() => _OnboardingHeightWeightScreenState();
}

class _OnboardingHeightWeightScreenState extends State<OnboardingHeightWeightScreen> {
  bool _metric = true;
  late final List<int> _heightCmValues;
  late final List<int> _weightKgValues;
  late final List<int> _heightInchValues;
  late final List<int> _weightLbValues;
  int _selectedHeightCm = 175;
  int _selectedWeightKg = 80;

  static const int _maleDefaultHeightCm = 175;
  static const int _maleDefaultWeightKg = 80;
  static const int _femaleDefaultHeightCm = 160;
  static const int _femaleDefaultWeightKg = 60;

  @override
  void initState() {
    super.initState();
    _metric = SessionManager.to.prefersMetric.value;
    _heightCmValues = List.generate(120, (index) => 140 + index);
    _weightKgValues = List.generate(140, (index) => 40 + index);
    _heightInchValues = List.generate(_cmToInches(_heightCmValues.last) - _cmToInches(_heightCmValues.first) + 1, (index) => _cmToInches(_heightCmValues.first) + index);
    _weightLbValues = List.generate(_kgToPounds(_weightKgValues.last) - _kgToPounds(_weightKgValues.first) + 1, (index) => _kgToPounds(_weightKgValues.first) + index);

    final double? storedHeight = SessionManager.to.heightCm.value;
    final double? storedWeight = SessionManager.to.weightKg.value;
    if (storedHeight != null) {
      _selectedHeightCm = storedHeight.round();
    } else {
      final sex = SessionManager.to.sex.value;
      if (sex == ProfileSex.female) {
        _selectedHeightCm = _femaleDefaultHeightCm;
      } else if (sex == ProfileSex.male) {
        _selectedHeightCm = _maleDefaultHeightCm;
      }
    }
    if (storedWeight != null) {
      _selectedWeightKg = storedWeight.round();
    } else {
      final sex = SessionManager.to.sex.value;
      if (sex == ProfileSex.female) {
        _selectedWeightKg = _femaleDefaultWeightKg;
      } else if (sex == ProfileSex.male) {
        _selectedWeightKg = _maleDefaultWeightKg;
      }
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
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: tr(LocaleKeys.common_continue_btn),
        onPressed: () async {
          await SessionManager.to.setHeightCm(_selectedHeightCm.toDouble());
          await SessionManager.to.setWeightKg(_selectedWeightKg.toDouble());
          await SessionManager.to.setPrefersMetric(_metric);
          await WeightEntryController.to.saveEntry(WeightEntry(date: DateTime.now(), weight: _selectedWeightKg.toDouble()));
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
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(tr(LocaleKeys.common_imperial), style: textTheme.titleSmall?.copyWith(color: metric ? AppColors.textTertiary : AppColors.textPrimary)),
        const SizedBox(width: AppSpacing.s),
        GestureDetector(
          onTap: () => onChanged(!metric),
          child: Container(
            width: AppSizes.toggleWidth,
            height: AppSizes.toggleHeight,
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: AnimatedAlign(
              alignment: metric ? Alignment.centerRight : Alignment.centerLeft,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: AppSizes.toggleHeight - AppSpacing.xs,
                height: AppSizes.toggleHeight - AppSpacing.xs,
                decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Text(tr(LocaleKeys.common_metric), style: textTheme.titleSmall?.copyWith(color: metric ? AppColors.textPrimary : AppColors.textTertiary)),
      ],
    );
  }
}
