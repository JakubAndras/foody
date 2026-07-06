import 'package:diplomka/app_theme.dart';
import 'package:diplomka/state/day_record_notifier.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/services/calendar_day_ring_service.dart';
import 'package:diplomka/widgets/calendar_day_ring_painter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateSelector extends ConsumerStatefulWidget {
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
  ConsumerState<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends ConsumerState<DateSelector> {
  late PageController _pageController;

  static const int _totalPages = 10400; // Roughly 100 years past/future
  static const int _initialPageIndex = _totalPages ~/ 2;

  @override
  void initState() {
    super.initState();
    _initializePageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mondayOfWeek = _getMondayForWeekContaining(widget.selectedDate);
      ref.read(dayRecordProvider.notifier).loadWeek(mondayOfWeek);
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
    return DateTime(normalized.year, normalized.month, normalized.day - (normalized.weekday - DateTime.monday));
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  void _handleDateTap(DateTime date) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      HapticFeedback.mediumImpact();
    }
    widget.onDateSelected(date);
  }

  @override
  void didUpdateWidget(covariant DateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldMonday = _getMondayForWeekContaining(oldWidget.selectedDate);
    final newMonday = _getMondayForWeekContaining(widget.selectedDate);
    if (oldMonday != newMonday) {
      final targetPage = _calculatePageIndex(widget.selectedDate);
      _pageController.jumpToPage(targetPage);
      ref.read(dayRecordProvider.notifier).loadWeek(newMonday);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.calendarStripHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _totalPages,
        onPageChanged: (pageIndex) {
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            HapticFeedback.mediumImpact();
          }
          final baseMonday = _getMondayForWeekContaining(DateTime.now());
          final mondayOfWeek = DateTime(baseMonday.year, baseMonday.month, baseMonday.day + (pageIndex - _initialPageIndex) * 7);
          ref.read(dayRecordProvider.notifier).loadWeek(mondayOfWeek);
        },
        itemBuilder: (context, pageIndex) {
          final baseMonday = _getMondayForWeekContaining(DateTime.now());
          final mondayOfWeek = DateTime(baseMonday.year, baseMonday.month, baseMonday.day + (pageIndex - _initialPageIndex) * 7);
          return _buildWeekView(mondayOfWeek);
        },
      ),
    );
  }

  Widget _buildWeekView(DateTime mondayOfWeek) {
    return Row(
      children: List.generate(7, (dayIndex) {
        final date = DateTime(mondayOfWeek.year, mondayOfWeek.month, mondayOfWeek.day + dayIndex);
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
    final ringStrokeWidth = AppSizes.progressRingStroke * 0.8;
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

    return Consumer(
      builder: (context, ref, _) {
      final ringStyle = ref.watch(dayRecordProvider).weekRingStyles[normalizedDate] ?? CalendarDayRingService.emptyStyle;
      return Container(
        padding: EdgeInsets.only(left: 1, top: AppSpacing.xxs + 2, right: 1, bottom: 2),
        decoration: BoxDecoration(
          color: isSelected
            ? AppColors.surface
            : isToday
              ? AppColors.surface.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.m),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayLabel,
              style: AppTextStyles.label11.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.borderStrong,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
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
                      padding: const EdgeInsets.all(AppSizes.progressRingStroke),
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
