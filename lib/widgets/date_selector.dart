import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/services/calendar_day_ring_service.dart';
import 'package:diplomka/widgets/calendar_day_ring_painter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool useSegmentedRing;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.useSegmentedRing = true,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late PageController _pageController;
  final DayRecordController _dayRecordController = DayRecordController.to;

  static const int _totalPages = 10400; // Roughly 100 years past/future
  static const int _initialPageIndex = _totalPages ~/ 2;

  @override
  void initState() {
    super.initState();
    _initializePageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mondayOfWeek = _getMondayForWeekContaining(widget.selectedDate);
      _dayRecordController.loadWeek(mondayOfWeek);
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

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

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
          _dayRecordController.loadWeek(mondayOfWeek);
        },
        itemBuilder: (context, pageIndex) {
          final mondayOfWeek = _getMondayForWeekContaining(DateTime.now()).add(Duration(days: (pageIndex - _initialPageIndex) * 7));
          return _buildWeekView(mondayOfWeek);
        },
      ),
    );
  }

  Widget _buildWeekView(DateTime mondayOfWeek) {
    return Row(
      children: List.generate(7, (dayIndex) {
        final date = mondayOfWeek.add(Duration(days: dayIndex));
        final isSelected = date.year == widget.selectedDate.year && date.month == widget.selectedDate.month && date.day == widget.selectedDate.day;
        return Expanded(
          child: GestureDetector(
            onTap: () => _handleDateTap(date),
            child: Center(child: _buildDate(date, isSelected)),
          ),
        );
      }),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildDate(DateTime date, bool isSelected) {
    final normalizedDate = _normalizeDate(date);
    final labelAndNumberColor = isSelected ? AppColors.textPrimary : AppColors.borderStrong;
    final ringStrokeWidth = AppSizes.dateCircleBorder * 0.8;
    final isToday = _isToday(date);
    final dayNames = [
      tr(LocaleKeys.day_mon),
      tr(LocaleKeys.day_tue),
      tr(LocaleKeys.day_wed),
      tr(LocaleKeys.day_thu),
      tr(LocaleKeys.day_fri),
      tr(LocaleKeys.day_sat),
      tr(LocaleKeys.day_sun),
    ];
    final dayLabel = isToday ? tr(LocaleKeys.common_today) : dayNames[date.weekday - 1];

    return Obx(() {
      final ringStyle = _dayRecordController.weekRingStyles[normalizedDate] ?? CalendarDayRingService.emptyStyle;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayLabel,
            style: AppTextStyles.label11.copyWith(
              color: isToday ? AppColors.textPrimary : labelAndNumberColor,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            width: AppSizes.minTap,
            height: AppSizes.minTap,
            child: Center(
              child: SizedBox(
                width: AppSizes.dateCircleSize,
                height: AppSizes.dateCircleSize,
                child: CustomPaint(
                  painter: CalendarDayRingPainter(
                    ringStyle: ringStyle,
                    strokeWidth: ringStrokeWidth,
                    useSegmentedRing: widget.useSegmentedRing,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.dateCircleBorder),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        date.day.toString(),
                        style: AppTextStyles.body16.copyWith(
                          fontWeight: FontWeight.w700,
                          color: labelAndNumberColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
