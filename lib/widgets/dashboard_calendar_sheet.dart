import 'dart:io' show Platform;
import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardCalendarSheet extends StatefulWidget {
  const DashboardCalendarSheet({super.key, required this.selectedDate, required this.onDateSelected, this.selectOnPickerScroll = true});

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool selectOnPickerScroll;

  static void show(BuildContext context, {required DateTime selectedDate, required ValueChanged<DateTime> onDateSelected}) {
    MainScreenController.to.isCalendarSheetVisible.value = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark40,
      isScrollControlled: true,
      builder: (sheetContext) => DashboardCalendarSheet(selectedDate: selectedDate, onDateSelected: onDateSelected),
    ).whenComplete(() {
      MainScreenController.to.isCalendarSheetVisible.value = false;
    });
  }

  @override
  State<DashboardCalendarSheet> createState() => _DashboardCalendarSheetState();
}

class _DashboardCalendarSheetState extends State<DashboardCalendarSheet> {
  late DateTime _displayedMonth;
  late DateTime _today;
  late DateTime _selectedDate;
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
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selectedDate = widget.selectedDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _pickerMonth = _displayedMonth.month;
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

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    final firstWeekday = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday;
    final totalSlots = (firstWeekday - 1) + daysInMonth;
    final rowCount = (totalSlots / 7).ceil();
    final contentHeightSheet = MediaQuery.of(context).size.height * 0.36;
    final contentHeightSheetWithoutBottom = MediaQuery.of(context).size.height * 0.34;
    final contentHeightSheetBackToToday = MediaQuery.of(context).size.height * 0.02;
    final selectedDayIsToday = _selectedDate != _today || _displayedMonth.year != _today.year || _displayedMonth.month != _today.month;

    return Padding(
      padding: Platform.isAndroid ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxxl + AppSpacing.xs) : const EdgeInsets.all(AppSpacing.xs),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl), bottom: Radius.circular(AppRadii.xxl + 10)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: CustomPaint(
            painter: const _GlassSheetPainter(),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.xxs),
                  const SheetDragHandle(),
                  const SizedBox(height: AppSpacing.l),
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    height: selectedDayIsToday ? contentHeightSheetWithoutBottom : contentHeightSheet,
                    child: _showMonthYearPicker ? _buildMonthYearPicker() : _buildCalendarGrid(daysInMonth, firstWeekday, rowCount),
                  ),
                  if (selectedDayIsToday)
                    SizedBox(
                      height: contentHeightSheetBackToToday,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = _today;
                              _displayedMonth = DateTime(_today.year, _today.month, 1);
                              _pickerMonth = _today.month - 1;
                              _pickerYear = _today.year;
                              _showMonthYearPicker = false;
                            });
                            widget.onDateSelected(_today);
                          },
                          child: Text(
                            tr(LocaleKeys.common_back_to_today),
                            style: AppTextStyles.body14.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekdayColor = isDark ? Colors.white70 : AppColors.calendarDarkMuted;
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
                        child: Text(tr(key).toUpperCase(), style: AppTextStyles.label12.copyWith(color: weekdayColor)),
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
    final isToday = date.year == _today.year && date.month == _today.month && date.day == _today.day;
    final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isSelected ? (isDark ? Colors.white : AppColors.white1) : (isDark ? Colors.white : AppColors.black);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDate = date);
        widget.onDateSelected(date);
      },
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
                ? AppColors.calendarDarkMuted.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: AppTextStyles.body16.copyWith(fontSize: 17, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500, height: 1.412, color: textColor),
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
              // Base font is scaled up ~1.12x by CupertinoPicker magnification for the selected row.
              // Use a smaller base so the magnified size matches the non-selected rows visually.
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
                _selectedDate = DateTime(date.year, date.month, 1);
              });
              if (widget.selectOnPickerScroll) {
                widget.onDateSelected(_selectedDate);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _GlassSheetPainter extends CustomPainter {
  const _GlassSheetPainter();

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

    // Glass fill
    canvas.drawRRect(rrect, Paint()..color = AppColors.pickerGlassBase);

    // Border
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
