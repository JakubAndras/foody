import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Cell height for each day row.
const double _cellSize = AppSizes.datePickerCell;

/// Height of the month label row.
const double _monthHeaderHeight = 44.0;

/// Bottom padding per month section.
const double _monthBottomPadding = 4.0;

/// An iOS-style continuously scrollable calendar overlay.
///
/// Months flow vertically with inline month labels on the right.
/// Supports date selection, optional per-day decoration, and a "Today" jump button.
///
/// Use [ScrollableCalendar.show] to present as a modal bottom sheet.
class ScrollableCalendar extends StatefulWidget {
  const ScrollableCalendar({super.key, required this.selectedDate, required this.onDateSelected, this.onClose, this.dayDecorationBuilder, this.minDate, this.maxDate});

  /// The currently highlighted date.
  final DateTime selectedDate;

  /// Called when the user taps a date cell.
  final ValueChanged<DateTime> onDateSelected;

  /// Called when the user taps the close (X) button. Falls back to [Navigator.pop].
  final VoidCallback? onClose;

  /// Optional builder for custom per-day decorations (rings, dots, badges).
  /// The returned widget is placed behind the day number in a [Stack].
  final Widget Function(DateTime date)? dayDecorationBuilder;

  /// Earliest scrollable month. Defaults to 2 years before today.
  final DateTime? minDate;

  /// Latest scrollable month. Defaults to 1 year after today.
  final DateTime? maxDate;

  /// Shows the scrollable calendar as a modal bottom sheet.
  ///
  /// Returns the selected [DateTime] or `null` if dismissed.
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime selectedDate,
    Widget Function(DateTime date)? dayDecorationBuilder,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.overlayDark40,
      builder: (_) => _ScrollableCalendarSheet(selectedDate: selectedDate, dayDecorationBuilder: dayDecorationBuilder, minDate: minDate, maxDate: maxDate),
    );
  }

  @override
  State<ScrollableCalendar> createState() => _ScrollableCalendarState();
}

/// Wrapper that sizes the bottom sheet and provides close/select behaviour.
class _ScrollableCalendarSheet extends StatelessWidget {
  const _ScrollableCalendarSheet({required this.selectedDate, this.dayDecorationBuilder, this.minDate, this.maxDate});

  final DateTime selectedDate;
  final Widget Function(DateTime date)? dayDecorationBuilder;
  final DateTime? minDate;
  final DateTime? maxDate;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      height: screenH * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.calendarDarkBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: ScrollableCalendar(
          selectedDate: selectedDate,
          onDateSelected: (date) => Navigator.of(context).pop(date),
          onClose: () => Navigator.of(context).pop(),
          dayDecorationBuilder: dayDecorationBuilder,
          minDate: minDate,
          maxDate: maxDate,
        ),
      ),
    );
  }
}

class _ScrollableCalendarState extends State<ScrollableCalendar> {
  late final ScrollController _scrollController;
  late final List<DateTime> _months;
  late final DateTime _today;
  late final DateFormat _monthFmt;
  int _currentVisibleYear = DateTime.now().year;

  // Weekday locale keys — Monday first.
  static const _weekdayKeys = [
    LocaleKeys.day_monday_short,
    LocaleKeys.day_tuesday_short,
    LocaleKeys.day_wednesday_short,
    LocaleKeys.day_thursday_short,
    LocaleKeys.day_friday_short,
    LocaleKeys.day_saturday_short,
    LocaleKeys.day_sunday_short,
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _monthFmt = DateFormat('MMM');

    final effectiveMin = widget.minDate ?? DateTime(now.year - 2, now.month, 1);
    final effectiveMax = widget.maxDate ?? DateTime(now.year + 1, now.month, 1);

    _months = [];
    var cursor = DateTime(effectiveMin.year, effectiveMin.month, 1);
    final end = DateTime(effectiveMax.year, effectiveMax.month, 1);
    while (!cursor.isAfter(end)) {
      _months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToToday();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll helpers ──

  int get _todayMonthIndex => _months.indexWhere((m) => m.year == _today.year && m.month == _today.month);

  double _estimateMonthHeight(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; // 1=Mon
    final totalSlots = (firstWeekday - 1) + daysInMonth;
    final rowCount = (totalSlots / 7).ceil();
    return _monthHeaderHeight + (rowCount * _cellSize) + _monthBottomPadding;
  }

  double _cumulativeOffset(int targetIndex) {
    var offset = 0.0;
    for (var i = 0; i < targetIndex; i++) {
      offset += _estimateMonthHeight(_months[i]);
    }
    return offset;
  }

  void _jumpToToday() {
    final idx = _todayMonthIndex;
    if (idx < 0) return;
    final offset = _cumulativeOffset(idx);
    _scrollController.jumpTo(offset.clamp(0, _scrollController.position.maxScrollExtent));
    _updateVisibleYear();
  }

  void _scrollToToday() {
    final idx = _todayMonthIndex;
    if (idx < 0) return;
    final offset = _cumulativeOffset(idx);
    _scrollController.animateTo(offset.clamp(0, _scrollController.position.maxScrollExtent), duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
  }

  void _onScroll() {
    _updateVisibleYear();
  }

  void _updateVisibleYear() {
    if (!_scrollController.hasClients) return;
    final scrollOffset = _scrollController.offset;
    var cumulative = 0.0;
    for (var i = 0; i < _months.length; i++) {
      cumulative += _estimateMonthHeight(_months[i]);
      if (cumulative > scrollOffset) {
        if (_currentVisibleYear != _months[i].year) {
          setState(() => _currentVisibleYear = _months[i].year);
        }
        return;
      }
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.s),
        _buildHeader(),
        const SizedBox(height: AppSpacing.m),
        _buildWeekdayRow(),
        const SizedBox(height: AppSpacing.xs),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            itemCount: _months.length,
            itemBuilder: (_, i) => _buildMonth(_months[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: widget.onClose ?? () => Navigator.of(context).pop(),
            child: Container(
              width: AppSizes.minTap,
              height: AppSizes.minTap,
              decoration: BoxDecoration(color: AppColors.calendarDarkSurface, borderRadius: BorderRadius.circular(AppRadii.pill)),
              child: const Icon(CupertinoIcons.xmark, color: AppColors.white, size: AppSizes.iconLg),
            ),
          ),
          // Year label
          Expanded(
            child: Center(
              child: Text('$_currentVisibleYear', style: AppTextStyles.h4.copyWith(color: AppColors.white)),
            ),
          ),
          // Today button
          GestureDetector(
            onTap: _scrollToToday,
            child: Container(
              height: AppSizes.minTap,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              decoration: BoxDecoration(color: AppColors.calendarDarkSurface, borderRadius: BorderRadius.circular(AppRadii.pill)),
              alignment: Alignment.center,
              child: Text(
                tr(LocaleKeys.common_today),
                style: AppTextStyles.body16.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Row(
        children: _weekdayKeys
            .map(
              (key) => Expanded(
                child: Center(
                  child: Text(
                    tr(key),
                    style: AppTextStyles.body14.copyWith(color: AppColors.calendarDarkMuted, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMonth(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; // 1=Mon

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Month label — right-aligned abbreviation
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.s, AppSpacing.m, AppSpacing.xxs),
          child: Text(
            _monthFmt.format(month),
            style: AppTextStyles.h4.copyWith(color: month.year == _today.year && month.month == _today.month ? AppColors.info : AppColors.white, fontWeight: FontWeight.w700),
          ),
        ),
        // Day grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: _buildDayGrid(month, daysInMonth, firstWeekday),
        ),
        SizedBox(height: _monthBottomPadding),
      ],
    );
  }

  Widget _buildDayGrid(DateTime month, int daysInMonth, int firstWeekday) {
    final rows = <Widget>[];
    var dayCounter = 1;
    final totalSlots = (firstWeekday - 1) + daysInMonth;
    final rowCount = (totalSlots / 7).ceil();

    for (var row = 0; row < rowCount; row++) {
      final cells = <Widget>[];
      for (var col = 0; col < 7; col++) {
        final slotIndex = row * 7 + col;
        final dayOffset = slotIndex - (firstWeekday - 1);
        if (dayOffset < 0 || dayCounter > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: _cellSize)));
        } else {
          final date = DateTime(month.year, month.month, dayCounter);
          cells.add(Expanded(child: _buildDayCell(date)));
          dayCounter++;
        }
      }
      rows.add(
        SizedBox(
          height: _cellSize,
          child: Row(children: cells),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime date) {
    final isToday = _isSameDay(date, _today);
    final isSelected = !isToday && _isSameDay(date, widget.selectedDate);
    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    Color textColor;
    if (isToday) {
      textColor = AppColors.white;
    } else if (isWeekend) {
      textColor = AppColors.calendarDarkWeekend;
    } else {
      textColor = AppColors.white;
    }

    final dayText = Text(
      '${date.day}',
      style: AppTextStyles.body16.copyWith(fontWeight: isToday ? FontWeight.w700 : FontWeight.w500, color: textColor),
    );

    Widget content;
    if (widget.dayDecorationBuilder != null) {
      content = Stack(alignment: Alignment.center, children: [widget.dayDecorationBuilder!(date), dayText]);
    } else {
      content = dayText;
    }

    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: _cellSize,
        child: Center(
          child: Container(
            width: AppSizes.dateCircleSize,
            height: AppSizes.dateCircleSize,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? AppColors.info : (isSelected ? AppColors.calendarDarkSurface : Colors.transparent)),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
