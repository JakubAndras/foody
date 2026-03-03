import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/calendar_day_ring_style.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/dietary_violation.dart';
import 'package:diplomka/services/calendar_day_ring_service.dart';
import 'package:diplomka/services/dietary_violation_service.dart';
import 'package:diplomka/widgets/calendar_day_ring_painter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

enum CalendarViewMode { calories, violations }

class MonthlyCalendarCard extends StatefulWidget {
  const MonthlyCalendarCard({super.key, this.showViolationsToggle = false});

  final bool showViolationsToggle;

  @override
  State<MonthlyCalendarCard> createState() => _MonthlyCalendarCardState();
}

class _MonthlyCalendarCardState extends State<MonthlyCalendarCard> {
  late DateTime _currentMonth;
  CalendarViewMode _viewMode = CalendarViewMode.calories;
  final CalendarDayRingService _ringService = CalendarDayRingService();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1));

  void _nextMonth() => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1));

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = DayRecordController.to.dayRecords.toList(growable: false);
      final violationService = DietaryViolationService.to;

      final Map<DateTime, DayRecord> recordsByDate = {for (final r in records) _dateOnly(r.date): r};

      final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
      final startWeekday = firstDayOfMonth.weekday; // 1=Mon, 7=Sun
      final today = _dateOnly(DateTime.now());

      final monthLabel = DateFormat('MMMM yyyy').format(_currentMonth);

      // Precompute ring styles for the month
      final Map<DateTime, CalendarDayRingStyle> monthRingStyles = {};
      for (int day = 1; day <= daysInMonth; day++) {
        final date = _dateOnly(DateTime(_currentMonth.year, _currentMonth.month, day));
        final record = recordsByDate[date];
        monthRingStyles[date] = _ringService.resolve(record);
      }

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _viewMode == CalendarViewMode.violations ? tr(LocaleKeys.violations_calendar_title) : tr(LocaleKeys.calendar_title),
                    style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _previousMonth,
                      child: const SizedBox(width: AppSizes.minTap, height: AppSizes.minTap, child: Icon(Icons.chevron_left, color: AppColors.textSecondary)),
                    ),
                    Text(monthLabel, style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
                    GestureDetector(
                      onTap: _nextMonth,
                      child: const SizedBox(width: AppSizes.minTap, height: AppSizes.minTap, child: Icon(Icons.chevron_right, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ],
            ),

            // Toggle
            if (widget.showViolationsToggle) ...[
              const SizedBox(height: AppSpacing.m),
              _ModeToggle(
                labels: [tr(LocaleKeys.calendar_mode_calories), tr(LocaleKeys.calendar_mode_violations)],
                selectedIndex: _viewMode == CalendarViewMode.calories ? 0 : 1,
                onTap: (index) => setState(() {
                  _viewMode = index == 0 ? CalendarViewMode.calories : CalendarViewMode.violations;
                }),
              ),
            ],
            const SizedBox(height: AppSpacing.m),

            // Day names row
            Row(
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
                  Expanded(child: Center(child: Text(tr(key), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600)))),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Month grid
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1,
              children: [
                // Empty cells before first day
                for (int i = 1; i < startWeekday; i++) const SizedBox.shrink(),
                // Day cells
                for (int day = 1; day <= daysInMonth; day++)
                  Builder(builder: (context) {
                    final date = _dateOnly(DateTime(_currentMonth.year, _currentMonth.month, day));
                    final record = recordsByDate[date];
                    final hasMeals = record != null && record.meals.isNotEmpty;
                    final hasViolation = record != null ? violationService.hasDietaryViolations(record) : false;
                    final ringStyle = monthRingStyles[date] ?? CalendarDayRingService.emptyStyle;

                    return _DayCell(
                      day: day,
                      isToday: date == today,
                      viewMode: _viewMode,
                      hasMeals: hasMeals,
                      hasViolation: hasViolation,
                      ringStyle: ringStyle,
                      onViolationTap: () {
                        if (record == null) return;
                        final violations = violationService.checkDayRecord(record);
                        if (violations.isEmpty) return;
                        _showViolationsSheet(context, date, violations);
                      },
                    );
                  }),
              ],
            ),
            const SizedBox(height: AppSpacing.m),

            // Legend
            if (_viewMode == CalendarViewMode.calories)
              Row(
                children: [
                  _LegendDot(color: AppColors.primarySoft),
                  const SizedBox(width: AppSpacing.xs),
                  Text(tr(LocaleKeys.calendar_legend_on_track), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
                  const SizedBox(width: AppSpacing.m),
                  _LegendDot(color: AppColors.error),
                  const SizedBox(width: AppSpacing.xs),
                  Text(tr(LocaleKeys.calendar_legend_over), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
                  const SizedBox(width: AppSpacing.m),
                  _LegendDot(color: AppColors.borderStrong),
                  const SizedBox(width: AppSpacing.xs),
                  Text(tr(LocaleKeys.calendar_legend_no_data), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
                ],
              )
            else
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: AppSizes.iconSm, color: AppColors.warningStrong),
                  const SizedBox(width: AppSpacing.xs),
                  Text(tr(LocaleKeys.violations_legend), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
                ],
              ),
          ],
        ),
      );
    });
  }

  void _showViolationsSheet(BuildContext context, DateTime date, List<DietaryViolation> violations) {
    final dateLabel = DateFormat('MMM d, yyyy').format(date);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadii.pill)),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(tr(LocaleKeys.violations_on_date, namedArgs: {'date': dateLabel}), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.m),
              ...violations.map((v) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: AppSizes.iconMd, color: AppColors.warningStrong),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v.ingredientName, style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
                              Text('${v.mealName} — ${v.reason}', style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.viewMode,
    required this.hasMeals,
    this.hasViolation = false,
    this.ringStyle,
    this.onViolationTap,
  });

  final int day;
  final bool isToday;
  final CalendarViewMode viewMode;
  final bool hasMeals;
  final bool hasViolation;
  final CalendarDayRingStyle? ringStyle;
  final VoidCallback? onViolationTap;

  @override
  Widget build(BuildContext context) {
    if (viewMode == CalendarViewMode.calories) {
      return _buildCaloriesCell();
    }
    return _buildViolationsCell();
  }

  Widget _buildCaloriesCell() {
    final effectiveRingStyle = ringStyle ?? CalendarDayRingService.emptyStyle;
    const ringSize = 32.0;
    const strokeWidth = 2.5;

    return Center(
      child: SizedBox(
        width: ringSize,
        height: ringSize,
        child: CustomPaint(
          painter: CalendarDayRingPainter(
            ringStyle: effectiveRingStyle,
            strokeWidth: strokeWidth,
            useSegmentedRing: false,
          ),
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

  Widget _buildViolationsCell() {
    return GestureDetector(
      onTap: hasViolation ? onViolationTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isToday)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadii.xs),
              ),
            ),
          Text(
            '$day',
            style: AppTextStyles.body14.copyWith(
              fontWeight: isToday ? FontWeight.w700 : (hasMeals ? FontWeight.w600 : FontWeight.w400),
              color: hasMeals ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
          if (hasViolation)
            const Positioned(
              top: 2,
              right: 2,
              child: Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.warningStrong),
            ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const _ModeToggle({
    required this.labels,
    required this.selectedIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.segmentedHeight,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.lg2),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final bool selected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: onTap == null ? null : () => onTap!(index),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  boxShadow: selected ? AppShadows.cardSmall : null,
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: AppTextStyles.caption12.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
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
