import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardCalendarSheet extends StatefulWidget {
  const DashboardCalendarSheet({super.key, required this.selectedDate, required this.onDateSelected});

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  static const double sheetHeight = 400.0;

  @override
  State<DashboardCalendarSheet> createState() => _DashboardCalendarSheetState();
}

class _DashboardCalendarSheetState extends State<DashboardCalendarSheet> {
  late DateTime _displayedMonth;
  late DateTime _today;
  bool _showMonthYearPicker = false;

  int _pickerMonth = 0;
  int _pickerYear = 0;

  static const int _minYear = 2020;
  static const int _maxYear = 2035;
  static const double _pickerItemExtent = 44.0;
  static const double _calendarRowHeight = 46.0;

  static const List<String> _weekdayKeys = [
    LocaleKeys.day_mon,
    LocaleKeys.day_tue,
    LocaleKeys.day_wed,
    LocaleKeys.day_thu,
    LocaleKeys.day_fri,
    LocaleKeys.day_sat,
    LocaleKeys.day_sun,
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _displayedMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
    _pickerMonth = _displayedMonth.month - 1;
    _pickerYear = _displayedMonth.year;
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  void _toggleMonthYearPicker() {
    setState(() {
      if (_showMonthYearPicker) {
        _displayedMonth = DateTime(_pickerYear, _pickerMonth + 1, 1);
        _showMonthYearPicker = false;
      } else {
        _pickerMonth = _displayedMonth.month - 1;
        _pickerYear = _displayedMonth.year;
        _showMonthYearPicker = true;
      }
    });
  }

  String _monthYearLabel() {
    return DateFormat('MMMM yyyy').format(_displayedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    final firstWeekday = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday;
    final totalSlots = (firstWeekday - 1) + daysInMonth;
    final rowCount = (totalSlots / 7).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: AppColors.calendarDarkMuted, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        _buildHeader(),
        const SizedBox(height: AppSpacing.s),
        if (_showMonthYearPicker) Expanded(child: _buildMonthYearPicker()) else _buildCalendarGrid(daysInMonth, firstWeekday, rowCount),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleMonthYearPicker,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _monthYearLabel(),
                    style: AppTextStyles.title17.copyWith(color: AppColors.calendarDarkText, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(_showMonthYearPicker ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right, color: AppColors.calendarDarkText, size: AppSizes.iconLg),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (!_showMonthYearPicker) ...[
            GestureDetector(
              onTap: _goToPreviousMonth,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Icon(Icons.chevron_left, color: AppColors.calendarDarkText, size: AppSizes.iconLg),
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            GestureDetector(
              onTap: _goToNextMonth,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Icon(Icons.chevron_right, color: AppColors.calendarDarkText, size: AppSizes.iconLg),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(int daysInMonth, int firstWeekday, int rowCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 22,
            child: Row(
              children: _weekdayKeys
                  .map(
                    (key) => Expanded(
                      child: Center(
                        child: Text(tr(key).toUpperCase(), style: AppTextStyles.label11.copyWith(color: AppColors.calendarDarkMuted)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...List.generate(rowCount, (row) {
            return SizedBox(
              height: _calendarRowHeight,
              child: Row(
                children: List.generate(7, (col) {
                  final slotIndex = row * 7 + col;
                  final dayOffset = slotIndex - (firstWeekday - 1);
                  if (dayOffset < 0 || dayOffset >= daysInMonth) {
                    return const Expanded(child: SizedBox());
                  }
                  final day = dayOffset + 1;
                  final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
                  return Expanded(child: _buildDayCell(date));
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isToday = date.year == _today.year && date.month == _today.month && date.day == _today.day;
    final isSelected = date.year == widget.selectedDate.year && date.month == widget.selectedDate.month && date.day == widget.selectedDate.day;

    Color textColor = AppColors.calendarDarkText;

    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            //gradient: isSelected ? AppGradients.primary : null,
            color: isSelected
                ? AppColors.calendarDarkSurface
                : isToday
                ? AppColors.calendarDarkMuted.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: AppTextStyles.body16.copyWith(fontWeight: isToday ? FontWeight.w700 : FontWeight.w500, color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    final monthNames = List.generate(12, (i) => DateFormat('MMMM').format(DateTime(2026, i + 1)));
    final yearCount = _maxYear - _minYear + 1;

    return Stack(
      children: [
        Center(
          child: Container(
            height: _pickerItemExtent,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            decoration: BoxDecoration(color: AppColors.calendarDarkSurface, borderRadius: BorderRadius.circular(AppRadii.sm)),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: _pickerMonth),
                itemExtent: _pickerItemExtent,
                diameterRatio: 1.3,
                squeeze: 0.85,
                selectionOverlay: const SizedBox.shrink(),
                magnification: 1.0,
                onSelectedItemChanged: (index) {
                  setState(() => _pickerMonth = index);
                },
                children: List.generate(12, (i) {
                  return Center(
                    child: Text(
                      monthNames[i],
                      style: AppTextStyles.h4.copyWith(color: AppColors.calendarDarkText, fontWeight: FontWeight.w600),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: _pickerYear - _minYear),
                itemExtent: _pickerItemExtent,
                diameterRatio: 1.3,
                squeeze: 0.85,
                selectionOverlay: const SizedBox.shrink(),
                magnification: 1.0,
                onSelectedItemChanged: (index) {
                  setState(() => _pickerYear = _minYear + index);
                },
                children: List.generate(yearCount, (i) {
                  final year = _minYear + i;
                  return Center(
                    child: Text(
                      '$year',
                      style: AppTextStyles.h4.copyWith(color: AppColors.calendarDarkText, fontWeight: FontWeight.w600),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
