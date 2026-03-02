import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
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
  static const int _defaultYear = 2000;
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

  int get _selectedYear => _years[_yearIndex];

  int get _selectedMonth => _monthIndex + 1;

  int get _maxDaysInSelectedMonth =>
      DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);

  List<String> get _dayValues =>
      List.generate(_maxDaysInSelectedMonth, (index) => '${index + 1}');

  void _clampDayIndexToValidRange() {
    final int maxDayIndex = _maxDaysInSelectedMonth - 1;
    _dayIndex = _dayIndex.clamp(0, maxDayIndex);
  }

  @override
  void initState() {
    super.initState();
    final int currentYear = DateTime.now().year;
    _years = List.generate(100, (index) => currentYear - index);
    final storedDob = SessionManager.to.dateOfBirth.value;
    if (storedDob != null) {
      _monthIndex = storedDob.month - 1;
      final yearIndex = _years.indexOf(storedDob.year);
      _yearIndex = yearIndex < 0 ? (_years.length / 2).floor() : yearIndex;
      _dayIndex = (storedDob.day - 1).clamp(0, _maxDaysInSelectedMonth - 1);
    } else {
      _monthIndex = 0;
      _dayIndex = 14;
      final defaultYearIndex = _years.indexOf(_defaultYear);
      _yearIndex =
          defaultYearIndex < 0 ? (_years.length / 2).floor() : defaultYearIndex;
    }
    _clampDayIndexToValidRange();
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
          final int day = _dayIndex + 1;
          final int year = _selectedYear;
          final int month = _selectedMonth;
          await SessionManager.to.setDateOfBirth(DateTime(year, month, day));
          widget.onNext();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.onboarding_dob_title), style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.s),
          Text(
            'This will be used to calibrate your custom plan.',
            style:
                textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _DobPickerColumn(
                  values: _months,
                  selectedIndex: _monthIndex,
                  onChanged: (index) => setState(() {
                    _monthIndex = index;
                    _clampDayIndexToValidRange();
                  }),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: _DobPickerColumn(
                  values: _dayValues,
                  selectedIndex: _dayIndex,
                  onChanged: (index) => setState(() => _dayIndex = index),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: _DobPickerColumn(
                  values: _years.map((value) => '$value').toList(),
                  selectedIndex: _yearIndex,
                  onChanged: (index) => setState(() {
                    _yearIndex = index;
                    _clampDayIndexToValidRange();
                  }),
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
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<_DobPickerColumn> createState() => _DobPickerColumnState();
}

class _DobPickerColumnState extends State<_DobPickerColumn> {
  int _selectedIndex = 0;
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex.clamp(0, widget.values.length - 1);
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void didUpdateWidget(covariant _DobPickerColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int nextSelected =
        widget.selectedIndex.clamp(0, widget.values.length - 1);
    if (nextSelected == _selectedIndex) return;
    _selectedIndex = nextSelected;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _controller.hasClients) {
        _controller.jumpToItem(nextSelected);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle selectedStyle =
        Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            );

    final TextStyle unselectedStyle =
        Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: AppColors.textTertiary,
            );

    return SizedBox(
      height: AppSizes.dobPickerHeight,
      child: CupertinoPicker(
        scrollController: _controller,
        itemExtent: AppSizes.pickerItemHeight,
        squeeze: 1.05,
        useMagnifier: true,
        magnification: 1.0,
        selectionOverlay: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: AppColors.outline),
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
