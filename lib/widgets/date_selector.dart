import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
      height: AppSizes.calendarStripHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _totalPages,
        onPageChanged: (pageIndex) {
          final mondayOfWeek = _getMondayForWeekContaining(DateTime.now()).add(Duration(days: (pageIndex - _initialPageIndex) * 7));
          DayRecordController.to.loadWeek(mondayOfWeek);
        },
        itemBuilder: (context, pageIndex) {
          final mondayOfWeek = _getMondayForWeekContaining(DateTime.now()).add(Duration(days: (pageIndex - _initialPageIndex) * 7));
          return _buildWeekView(mondayOfWeek);
        },
      ),
    );
  }

  Widget _buildWeekView(DateTime mondayOfWeek) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (dayIndex) {
          final date = mondayOfWeek.add(Duration(days: dayIndex));
          final isSelected = date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;
          return GestureDetector(
            onTap: () => _handleDateTap(date),
            child: _buildDate(date, isSelected),
          );
        }),
      ),
    );
  }

  Widget _buildDate(DateTime date, bool isSelected) {
    final dayNames = [
      tr(LocaleKeys.day_monday_short),
      tr(LocaleKeys.day_tuesday_short),
      tr(LocaleKeys.day_wednesday_short),
      tr(LocaleKeys.day_thursday_short),
      tr(LocaleKeys.day_friday_short),
      tr(LocaleKeys.day_saturday_short),
      tr(LocaleKeys.day_sunday_short),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayNames[date.weekday - 1].toUpperCase(),
          style: AppTextStyles.label11.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: AppSizes.minTap,
          height: AppSizes.minTap,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected ? Border.all(color: AppColors.primary, width: AppSizes.borderThick) : null,
            color: isSelected ? AppColors.surface : Colors.transparent,
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: AppTextStyles.body16.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
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
