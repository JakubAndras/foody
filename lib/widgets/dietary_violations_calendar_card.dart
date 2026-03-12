import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/calendar_day_ring_style.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/services/calendar_day_ring_service.dart';
import 'package:diplomka/widgets/calendar_day_ring_painter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class MonthlyCalendarCard extends StatefulWidget {
  const MonthlyCalendarCard({super.key});

  @override
  State<MonthlyCalendarCard> createState() => _MonthlyCalendarCardState();
}

class _MonthlyCalendarCardState extends State<MonthlyCalendarCard> {
  late DateTime _currentMonth;
  final CalendarDayRingService _ringService = CalendarDayRingService();
  bool _showMonthYearPicker = false;

  static const int _minYear = 2020;
  static const int _maxYear = 2035;
  static const double _calendarRowHeight = 46.0;
  static const double _dayNamesHeight = 18.0;
  static const double _legendHeight = 16.0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1));

  void _nextMonth() => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1));

  void _toggleMonthYearPicker() {
    setState(() => _showMonthYearPicker = !_showMonthYearPicker);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = DayRecordController.to.dayRecords.toList(growable: false);

      final Map<DateTime, DayRecord> recordsByDate = {for (final r in records) _dateOnly(r.date): r};

      final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
      final startWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
      final today = _dateOnly(DateTime.now());

      final rawMonthLabel = DateFormat('MMMM yyyy').format(_currentMonth);
      final monthLabel = '${rawMonthLabel[0].toUpperCase()}${rawMonthLabel.substring(1)}';

      // Precompute ring styles for the month
      final Map<DateTime, CalendarDayRingStyle> monthRingStyles = {};
      for (int day = 1; day <= daysInMonth; day++) {
        final date = _dateOnly(DateTime(_currentMonth.year, _currentMonth.month, day));
        final record = recordsByDate[date];
        monthRingStyles[date] = _ringService.resolve(record);
      }

      final totalSlots = (startWeekday - 1) + daysInMonth;
      final rowCount = (totalSlots / 7).ceil();

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.cardSoft,
        ),
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly calories overview",
              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            // Header
            SizedBox(
              height: AppSizes.minTap,
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
                          Text(monthLabel, style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: AppSpacing.xxs),
                          Icon(_showMonthYearPicker ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right, color: AppColors.textSecondary, size: AppSizes.iconMd),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!_showMonthYearPicker) ...[
                    GestureDetector(
                      onTap: _previousMonth,
                      child: const SizedBox(
                        width: AppSizes.minTap,
                        height: AppSizes.minTap,
                        child: Icon(Icons.chevron_left, color: AppColors.textSecondary),
                      ),
                    ),
                    GestureDetector(
                      onTap: _nextMonth,
                      child: const SizedBox(
                        width: AppSizes.minTap,
                        height: AppSizes.minTap,
                        child: Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Both views share the same fixed height so the card doesn't jump.
            // 6 rows is the max a month can occupy; day-names + gap + grid.
            Stack(
              children: [
                SizedBox(
                  height: _dayNamesHeight + AppSpacing.xs + (6 * _calendarRowHeight),
                  child: _showMonthYearPicker ? _buildMonthYearPicker() : _buildCalendarContent(daysInMonth, startWeekday, rowCount, recordsByDate, monthRingStyles, today),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _backToTodayButton(today),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  bool _isCurrentMonth(DateTime today) => _currentMonth.year == today.year && _currentMonth.month == today.month;

  Widget _backToTodayButton(DateTime today) {
    if (_isCurrentMonth(today)) return const SizedBox.shrink();
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentMonth = DateTime(today.year, today.month);
            _showMonthYearPicker = false;
          });
        },
        child: Text(
          tr(LocaleKeys.common_back_to_today),
          style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCalendarContent(
    int daysInMonth,
    int startWeekday,
    int rowCount,
    Map<DateTime, DayRecord> recordsByDate,
    Map<DateTime, CalendarDayRingStyle> monthRingStyles,
    DateTime today,
  ) {
    return Column(
      children: [
        // Day names row
        SizedBox(
          height: _dayNamesHeight,
          child: Row(
            children: [
              for (final key in [
                LocaleKeys.day_monday_short,
                LocaleKeys.day_tuesday_short,
                LocaleKeys.day_wednesday_short,
                LocaleKeys.day_thursday_short,
                LocaleKeys.day_friday_short,
                LocaleKeys.day_saturday_short,
                LocaleKeys.day_sunday_short,
              ])
                Expanded(
                  child: Center(
                    child: Text(
                      tr(key),
                      style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Month grid
        ...List.generate(rowCount, (row) {
          return SizedBox(
            height: _calendarRowHeight,
            child: Row(
              children: List.generate(7, (col) {
                final slotIndex = row * 7 + col;
                final dayOffset = slotIndex - (startWeekday - 1);
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                final day = dayOffset + 1;
                final date = _dateOnly(DateTime(_currentMonth.year, _currentMonth.month, day));
                final record = recordsByDate[date];
                final hasMeals = record != null && record.meals.isNotEmpty;
                final ringStyle = monthRingStyles[date] ?? CalendarDayRingService.emptyStyle;

                return Expanded(
                  child: _DayCell(day: day, isToday: date == today, hasMeals: hasMeals, ringStyle: ringStyle),
                );
              }),
            ),
          );
        }),

        // Legend (hidden for now)
        // Row(
        //   children: [
        //   _LegendDot(color: AppColors.primarySoft),
        //   const SizedBox(width: AppSpacing.xs),
        //   Text(tr(LocaleKeys.calendar_legend_on_track), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
        //   const SizedBox(width: AppSpacing.m),
        //   _LegendDot(color: AppColors.error),
        //   const SizedBox(width: AppSpacing.xs),
        //   Text(tr(LocaleKeys.calendar_legend_over), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
        //   const SizedBox(width: AppSpacing.m),
        //   _LegendDot(color: AppColors.borderStrong),
        //   const SizedBox(width: AppSpacing.xs),
        //   Text(tr(LocaleKeys.calendar_legend_no_data), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
        // ],
        // ),
      ],
    );
  }

  Widget _buildMonthYearPicker() {
    return Align(
      alignment: const Alignment(0, -0.4),
      child: SizedBox(
        height: 170,
        child: CupertinoTheme(
          data: CupertinoThemeData(
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: AppTextStyles.title17.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w400, fontSize: 18),
            ),
          ),
          child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.monthYear,
          initialDateTime: _currentMonth,
          minimumDate: DateTime(_minYear),
          maximumDate: DateTime(_maxYear, 12),
          backgroundColor: Colors.transparent,
          onDateTimeChanged: (DateTime date) {
            setState(() {
              _currentMonth = DateTime(date.year, date.month);
            });
          },
        ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isToday, required this.hasMeals, this.ringStyle});

  final int day;
  final bool isToday;
  final bool hasMeals;
  final CalendarDayRingStyle? ringStyle;

  @override
  Widget build(BuildContext context) {
    final effectiveRingStyle = ringStyle ?? CalendarDayRingService.emptyStyle;
    const cellSize = 32.0;
    const strokeWidth = 2.5;

    return Center(
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? AppColors.greyLight3 : Colors.transparent),
        alignment: Alignment.center,
        child: CustomPaint(
          painter: CalendarDayRingPainter(ringStyle: effectiveRingStyle, strokeWidth: strokeWidth, useSegmentedRing: false),
          child: Center(
            child: Text(
              '$day',
              style: AppTextStyles.caption12.copyWith(
                fontWeight: isToday ? FontWeight.w700 : (hasMeals ? FontWeight.w600 : FontWeight.w400),
                color: isToday ? AppColors.textPrimary : (hasMeals ? AppColors.textPrimary : AppColors.textTertiary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
