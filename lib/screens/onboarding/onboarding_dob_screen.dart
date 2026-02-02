import 'package:diplomka/app_theme.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingDobScreen extends StatefulWidget {
  const OnboardingDobScreen({
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
  State<OnboardingDobScreen> createState() => _OnboardingDobScreenState();
}

class _OnboardingDobScreenState extends State<OnboardingDobScreen> {
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late final List<int> _years;
  int _monthIndex = 0;
  int _dayIndex = 0;
  int _yearIndex = 0;

  @override
  void initState() {
    super.initState();
    final int currentYear = DateTime.now().year;
    _years = List.generate(100, (index) => currentYear - index);
    final storedDob = SessionManager.to.dateOfBirth.value;
    if (storedDob != null) {
      _monthIndex = storedDob.month - 1;
      _dayIndex = (storedDob.day - 1).clamp(0, 30);
      final yearIndex = _years.indexOf(storedDob.year);
      _yearIndex = yearIndex < 0 ? (_years.length / 2).floor() : yearIndex;
    } else {
      _monthIndex = (_months.length / 2).floor();
      _dayIndex = 14;
      _yearIndex = (_years.length / 2).floor();
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
          final int year = _years[_yearIndex];
          final int month = _monthIndex + 1;
          final int maxDay = DateUtils.getDaysInMonth(year, month);
          final int day = (_dayIndex + 1).clamp(1, maxDay);
          await SessionManager.to.setDateOfBirth(DateTime(year, month, day));
          widget.onNext();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('When were you born?', style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This will be used to calibrate your custom plan.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _DobPickerColumn(
                  values: _months,
                  initialIndex: _monthIndex,
                  onChanged: (index) => setState(() => _monthIndex = index),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DobPickerColumn(
                  values: List.generate(31, (index) => '${index + 1}'),
                  initialIndex: _dayIndex,
                  onChanged: (index) => setState(() => _dayIndex = index),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DobPickerColumn(
                  values: _years.map((value) => '$value').toList(),
                  initialIndex: _yearIndex,
                  onChanged: (index) => setState(() => _yearIndex = index),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DobPickerColumn extends StatefulWidget {
  const _DobPickerColumn({
    required this.values,
    required this.initialIndex,
    required this.onChanged,
  });

  final List<String> values;
  final int initialIndex;
  final ValueChanged<int> onChanged;

  @override
  State<_DobPickerColumn> createState() => _DobPickerColumnState();
}

class _DobPickerColumnState extends State<_DobPickerColumn> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.values.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle selectedStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );

    final TextStyle unselectedStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: AppColors.textTertiary,
        );

    return SizedBox(
      height: AppSizes.dobPickerHeight,
      child: CupertinoPicker(
        itemExtent: AppSizes.pickerItemHeight,
        squeeze: 1.05,
        useMagnifier: true,
        magnification: 1.0,
        selectionOverlay: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        onSelectedItemChanged: (index) {
          setState(() => _selectedIndex = index);
          widget.onChanged(index);
        },
        children: List.generate(widget.values.length, (index) {
          return Center(
            child: Text(
              widget.values[index],
              style: index == _selectedIndex ? selectedStyle : unselectedStyle,
            ),
          );
        }),
      ),
    );
  }
}
