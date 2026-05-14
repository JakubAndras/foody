import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/widgets/sheet_top_bar.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MealCopyToSheet extends StatefulWidget {
  final DateTime currentDate;
  final ValueChanged<List<DateTime>> onDatesSelected;

  const MealCopyToSheet({super.key, required this.currentDate, required this.onDatesSelected});

  static void show(BuildContext context, {required DateTime currentDate, required ValueChanged<List<DateTime>> onDatesSelected}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark40,
      isScrollControlled: true,
      builder: (_) => MealCopyToSheet(currentDate: currentDate, onDatesSelected: onDatesSelected),
    );
  }

  @override
  State<MealCopyToSheet> createState() => _MealCopyToSheetState();
}

class _MealCopyToSheetState extends State<MealCopyToSheet> {
  late DateTime _displayedMonth;
  final Set<DateTime> _selectedDates = {};
  bool _showMonthYearPicker = false;

  int _pickerMonth = 0;
  int _pickerYear = 0;

  static const int _minYear = 2020;
  static const int _maxYear = 2035;
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
    _displayedMonth = DateTime(widget.currentDate.year, widget.currentDate.month, 1);
    _pickerMonth = _displayedMonth.month;
    _pickerYear = _displayedMonth.year;
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isCurrentDate(DateTime date) {
    final current = _normalizeDate(widget.currentDate);
    return date.year == current.year && date.month == current.month && date.day == current.day;
  }

  bool _isDateSelected(DateTime date) {
    return _selectedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
  }

  void _toggleDate(DateTime date) {
    if (_isCurrentDate(date)) return;
    setState(() {
      if (_isDateSelected(date)) {
        _selectedDates.removeWhere((d) => d.year == date.year && d.month == date.month && d.day == date.day);
      } else {
        _selectedDates.add(_normalizeDate(date));
      }
    });
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
        _displayedMonth = DateTime(_pickerYear, _pickerMonth, 1);
        _showMonthYearPicker = false;
      } else {
        _pickerMonth = _displayedMonth.month;
        _pickerYear = _displayedMonth.year;
        _showMonthYearPicker = true;
      }
    });
  }

  String _monthYearLabel() {
    final locale = context.locale.toString();
    final raw = DateFormat('MMMM yyyy', locale).format(_displayedMonth);
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  void _handleConfirm() {
    if (_selectedDates.isEmpty) return;
    widget.onDatesSelected(_selectedDates.toList()..sort());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    final firstWeekday = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday;
    final totalSlots = (firstWeekday - 1) + daysInMonth;
    final rowCount = (totalSlots / 7).ceil();
    final contentHeight = MediaQuery.of(context).size.height * 0.36;
    final contentHeightWithCount = MediaQuery.of(context).size.height * 0.34;
    final countBarHeight = MediaQuery.of(context).size.height * 0.02;
    final showCountBar = _selectedDates.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl), bottom: Radius.circular(AppRadii.xxl + 10)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: CustomPaint(
            painter: const _CopyToGlassSheetPainter(),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.xxs),
                  const SheetDragHandle(),
                  const SizedBox(height: AppSpacing.xs),
                  SheetTopBar(title: tr(LocaleKeys.meal_copy_to_dates), onClose: () => Navigator.of(context).pop(), onConfirm: _selectedDates.isNotEmpty ? _handleConfirm : null),
                  const SizedBox(height: AppSpacing.xs),
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    height: showCountBar ? contentHeightWithCount : contentHeight,
                    child: _showMonthYearPicker ? _buildMonthYearPicker() : _buildCalendarGrid(daysInMonth, firstWeekday, rowCount),
                  ),
                  if (showCountBar)
                    SizedBox(
                      height: countBarHeight,
                      child: Center(
                        child: Text(
                          tr(LocaleKeys.meal_copied_to_dates, namedArgs: {'count': '${_selectedDates.length}'}),
                          style: AppTextStyles.body14.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
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
                    style: AppTextStyles.title17.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(_showMonthYearPicker ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_right, color: AppColors.textPrimary, size: AppSizes.iconLg),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (!_showMonthYearPicker) ...[
            GestureDetector(
              onTap: _goToPreviousMonth,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(CupertinoIcons.chevron_left, color: AppColors.textPrimary, size: AppSizes.iconMd),
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            GestureDetector(
              onTap: _goToNextMonth,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Icon(CupertinoIcons.chevron_right, color: AppColors.textPrimary, size: AppSizes.iconMd),
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
            child: Row(
              children: _weekdayKeys
                  .map(
                    (key) => Expanded(
                      child: Center(
                        child: Text(tr(key).toUpperCase(), style: AppTextStyles.label12.copyWith(color: AppColors.calendarDarkMuted)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrent = _isCurrentDate(date);
    final isSelected = _isDateSelected(date);

    Color bgColor;
    Color textColor;
    if (isSelected) {
      bgColor = isDark ? Colors.white : AppColors.calendarDarkSurface;
      textColor = isDark ? AppColors.black : AppColors.white1;
    } else if (isCurrent) {
      bgColor = AppColors.calendarDarkMuted.withValues(alpha: 0.15);
      textColor = AppColors.calendarDarkMuted;
    } else {
      bgColor = Colors.transparent;
      textColor = isDark ? Colors.white : AppColors.black;
    }

    return GestureDetector(
      onTap: () => _toggleDate(date),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: AppTextStyles.body16.copyWith(fontSize: 17, fontWeight: isCurrent || isSelected ? FontWeight.w700 : FontWeight.w500, height: 1.412, color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    return Align(
      alignment: const Alignment(0, -0.4),
      child: SizedBox(
        height: 200,
        child: CupertinoTheme(
          data: CupertinoThemeData(
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: AppTextStyles.h4.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w400, fontSize: 20),
            ),
          ),
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.monthYear,
            initialDateTime: DateTime(_pickerYear, _pickerMonth),
            minimumDate: DateTime(_minYear),
            maximumDate: DateTime(_maxYear, 12),
            backgroundColor: Colors.transparent,
            onDateTimeChanged: (DateTime date) {
              setState(() {
                _pickerMonth = date.month;
                _pickerYear = date.year;
                _displayedMonth = DateTime(date.year, date.month, 1);
              });
            },
          ),
        ),
      ),
    );
  }
}

class _CopyToGlassSheetPainter extends CustomPainter {
  const _CopyToGlassSheetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromLTRBAndCorners(
      0,
      0,
      size.width,
      size.height,
      topLeft: Radius.circular(AppRadii.xxl),
      topRight: Radius.circular(AppRadii.xxl),
      bottomRight: Radius.circular(AppRadii.xxl + 10),
      bottomLeft: Radius.circular(AppRadii.xxl + 10),
    );

    canvas.drawRRect(rrect, Paint()..color = AppColors.pickerGlassSolid);

    canvas.drawRRect(
      rrect.deflate(0.4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.glassBorder,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
