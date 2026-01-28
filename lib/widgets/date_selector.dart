import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/app_theme.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late PageController _pageController;

  static const int _totalPages = 10400; // Roughly 100 years past/future
  static const int _initialPageIndex = _totalPages ~/ 2;

  @override
  void initState() {
    super.initState();
    _initializePageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mondayOfWeek = _getMondayForWeekContaining(widget.selectedDate);
      DayRecordController.to.loadWeek(mondayOfWeek);
    });
  }

  void _initializePageController() {
    final pageIndex = _calculatePageIndex(widget.selectedDate);
    _pageController = PageController(initialPage: pageIndex);
  }

  int _calculatePageIndex(DateTime date) {
    final mondayOfTargetWeek = _getMondayForWeekContaining(date);
    final today = DateTime.now();
    final mondayOfCurrentWeek = _getMondayForWeekContaining(today);
    final differenceInDays = mondayOfTargetWeek.difference(mondayOfCurrentWeek).inDays;
    return _initialPageIndex + (differenceInDays / 7).round();
  }

  DateTime _getMondayForWeekContaining(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - DateTime.monday));
  }

  void _handleDateTap(DateTime date) => widget.onDateSelected(date);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _totalPages,
        onPageChanged: (pageIndex) {
          final mondayOfWeek = _getMondayForWeekContaining(DateTime.now()).add(Duration(days: (pageIndex - _initialPageIndex) * 7));
          DayRecordController.to.loadWeek(mondayOfWeek);
        },
        itemBuilder: (context, pageIndex) {
          final mondayOfWeek = _getMondayForWeekContaining(DateTime.now()).add(Duration(days: (pageIndex - _initialPageIndex) * 7));
          // Use Obx to listen to changes in weekStatuses
          return Obx(() => _buildWeekView(mondayOfWeek, DayRecordController.to.weekStatuses));
        },
      ),
    );
  }

  Widget _buildWeekView(DateTime mondayOfWeek, RxMap<DateTime, bool> mealStatuses) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (dayIndex) {
          final date = mondayOfWeek.add(Duration(days: dayIndex));
          final normalized = DateTime(date.year, date.month, date.day);
          final isSelected = date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;
          final today = DateTime.now();
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          // Access the value from the RxMap
          final hasSomeMealRecorded = mealStatuses[normalized] ?? false;

          return GestureDetector(
            onTap: () => _handleDateTap(date),
            child: _buildDate(date, isSelected, isToday, hasSomeMealRecorded),
          );
        }),
      ),
    );
  }

  Widget _buildDate(DateTime date, bool isSelected, bool isToday, bool hasSomeMealRecorded) {
    final dayNames = [
      tr(LocaleKeys.day_monday_short),
      tr(LocaleKeys.day_tuesday_short),
      tr(LocaleKeys.day_wednesday_short),
      tr(LocaleKeys.day_thursday_short),
      tr(LocaleKeys.day_friday_short),
      tr(LocaleKeys.day_saturday_short),
      tr(LocaleKeys.day_sunday_short),
    ];

    Widget dayNameWidget = SizedBox(
      height: 20,
      width: 20,
      child: Center(
        child: Text(
          dayNames[date.weekday - 1],
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.black : (Colors.grey.shade700),
            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );

    Widget circleWidget = DottedBorder(
      borderType: BorderType.Circle,
      padding: const EdgeInsets.all(6),
      dashPattern: [5, isSelected ? 0 : (isToday ? 0 : hasSomeMealRecorded ? 0 : 3)],
      strokeWidth: 1.5,
      color: isSelected ? Colors.black : (hasSomeMealRecorded ? Colors.green.shade300 : Colors.grey.shade300),
      child: dayNameWidget,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: circleWidget),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.black : (Colors.grey.shade700),
              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
