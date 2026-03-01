import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/export_controller.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class ExportPdfDateRangeScreen extends GetView<ExportController> {
  const ExportPdfDateRangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Scrollable content ──
          // ── Top bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, 0),
            child: ProfileTopBar(title: 'Select date range', onBack: () => Get.back()),
          ),

          // ── Centered content ──
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen, vertical: AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...ExportDateRange.values.map((range) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.m),
                          child: Obx(() => _DateRangeButton(
                                label: _rangeLabel(range),
                                isSelected: controller.selectedRange.value == range,
                                onTap: () async {
                                  controller.selectRange(range);
                                  if (range == ExportDateRange.custom) {
                                    await _pickCustomRange(context);
                                  }
                                },
                              )),
                        )),
                    Obx(() {
                      final range = controller.selectedRange.value;
                      final show = range == ExportDateRange.custom && controller.customStart.value != null && controller.customEnd.value != null;
                      return Center(
                        child: Text(
                          show ? '${_fmtDate(controller.customStart.value!)} – ${_fmtDate(controller.customEnd.value!)}' : ' ',
                          style: AppTextStyles.body16.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.screen),
            child: Column(
                    children: [
                      ProfilePrimaryButton(
                        label: 'Export PDF',
                        height: AppSizes.buttonHeightCompact,
                        radius: AppRadii.pill,
                        onPressed: controller.exportPdf,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeightCompact,
                        child: OutlinedButton(
                          onPressed: controller.exportCsv,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.textSecondary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
                          ),
                          child: Text('Export CSV', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final result = await showModalBottomSheet<(DateTime, DateTime)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalendarRangeSheet(
        initialStart: controller.customStart.value,
        initialEnd: controller.customEnd.value,
      ),
    );
    if (result != null) {
      controller.setCustomDates(result.$1, result.$2);
    }
  }

  String _rangeLabel(ExportDateRange range) {
    switch (range) {
      case ExportDateRange.last7:
        return 'Last 7 Days';
      case ExportDateRange.last30:
        return 'Last 30 Days';
      case ExportDateRange.allTime:
        return 'All Time';
      case ExportDateRange.custom:
        return 'Custom Date Range';
    }
  }

  String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}';
}

class _CalendarRangeSheet extends StatefulWidget {
  const _CalendarRangeSheet({this.initialStart, this.initialEnd});

  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<_CalendarRangeSheet> createState() => _CalendarRangeSheetState();
}

class _CalendarRangeSheetState extends State<_CalendarRangeSheet> {
  DateTime? _start;
  DateTime? _end;

  late final DateTime _today;
  late final List<DateTime> _months;
  late final ScrollController _scrollController;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static final _monthFmt = DateFormat('MMMM yyyy');
  static const _cellSize = 48.0;
  static const _rangeBg = Color(0xFFEEEFF3);
  static const _edgeBorderColor = AppColors.textSecondary;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);

    // Build month list: 12 months back from current month (current month is last)
    _months = List.generate(13, (i) {
      final offset = 12 - i;
      return DateTime(_today.year, _today.month - offset, 1);
    });

    // Scroll to bottom (current month) after first frame
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onDayTap(DateTime day) {
    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        // First tap or reset
        _start = day;
        _end = null;
      } else {
        // Second tap
        if (day.isBefore(_start!)) {
          _end = _start;
          _start = day;
        } else {
          _end = day;
        }
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInRange(DateTime day) {
    if (_start == null || _end == null) return false;
    return !day.isBefore(_start!) && !day.isAfter(_end!);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        boxShadow: AppShadows.modal,
      ),
      child: Column(
        children: [
          // ── Handle bar ──
          const SizedBox(height: AppSpacing.s),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: AppColors.outline, borderRadius: BorderRadius.circular(2)),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Custom Date Range', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700)),
                ProfileBackButton(icon: Icons.close, onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),

          // ── Selection summary ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Row(
              children: [
                Text(
                  _start != null ? _fmtDateShort(_start!) : 'Start date',
                  style: AppTextStyles.body14.copyWith(
                    color: _start != null ? AppColors.textPrimary : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Text('–', style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
                ),
                Text(
                  _end != null ? _fmtDateShort(_end!) : 'End date',
                  style: AppTextStyles.body14.copyWith(
                    color: _end != null ? AppColors.textPrimary : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s),

          // ── Weekday header (pinned) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Row(
              children: _weekdays
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d, style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Divider(height: 1, color: AppColors.outline.withValues(alpha: 0.5)),

          // ── Scrollable months ──
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              itemCount: _months.length,
              itemBuilder: (_, i) => _buildMonth(_months[i]),
            ),
          ),

          // ── Apply button ──
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.s, AppSpacing.screen, MediaQuery.of(context).padding.bottom),
            child: ProfilePrimaryButton(
              label: 'Apply',
              onPressed: (_start != null && _end != null) ? () => Navigator.of(context).pop((_start!, _end!)) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonth(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; // 1=Mon … 7=Sun

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.l, AppSpacing.m, AppSpacing.s),
          child: Text(
            _monthFmt.format(month),
            style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Divider(height: 1, color: AppColors.outline.withValues(alpha: 0.3)),
        const SizedBox(height: AppSpacing.xs),

        // Day grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: _buildDayGrid(month, daysInMonth, firstWeekday),
        ),
      ],
    );
  }

  Widget _buildDayGrid(DateTime month, int daysInMonth, int firstWeekday) {
    final rows = <Widget>[];
    var dayCounter = 1;
    final totalSlots = ((firstWeekday - 1) + daysInMonth);
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

      rows.add(SizedBox(height: _cellSize, child: Row(children: cells)));
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime date) {
    final isToday = _isSameDay(date, _today);
    final isFuture = date.isAfter(_today);
    final isStart = _start != null && _isSameDay(date, _start!);
    final isEnd = _end != null && _isSameDay(date, _end!);
    final isEdge = isStart || isEnd;
    final inRange = _isInRange(date);
    final isSingleDay = _start != null && _end != null && _isSameDay(_start!, _end!);

    // Background decoration
    BoxDecoration? decoration;

    if (isEdge && !isSingleDay) {
      // Start or end edge: rounded on the edge side, flat on the range side
      final isLeft = isStart;
      decoration = BoxDecoration(
        color: _rangeBg,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(AppRadii.xs) : Radius.zero,
          right: !isLeft ? const Radius.circular(AppRadii.xs) : Radius.zero,
        ),
        border: Border(
          top: const BorderSide(color: _edgeBorderColor, width: 1.5),
          bottom: const BorderSide(color: _edgeBorderColor, width: 1.5),
          left: isLeft ? const BorderSide(color: _edgeBorderColor, width: 1.5) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: _edgeBorderColor, width: 1.5) : BorderSide.none,
        ),
      );
    } else if (isSingleDay && isStart) {
      decoration = BoxDecoration(
        color: _rangeBg,
        borderRadius: BorderRadius.circular(AppRadii.xs),
        border: Border.all(color: _edgeBorderColor, width: 1.5),
      );
    } else if (inRange) {
      decoration = const BoxDecoration(color: _rangeBg);
    }

    // Text color
    Color textColor;
    if (isFuture) {
      textColor = AppColors.textTertiary.withValues(alpha: 0.4);
    } else if (isEdge) {
      textColor = AppColors.textPrimary;
    } else if (inRange) {
      textColor = AppColors.textPrimary;
    } else {
      textColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: isFuture ? null : () => _onDayTap(date),
      child: Container(
        height: _cellSize,
        decoration: decoration,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isToday)
                Text('Today', style: AppTextStyles.caption12.copyWith(fontWeight: FontWeight.w700, color: AppColors.textSecondary, fontSize: 9, height: 1)),
              Text(
                '${date.day}',
                style: AppTextStyles.body16.copyWith(fontWeight: isEdge || isToday ? FontWeight.w700 : FontWeight.w500, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDateShort(DateTime d) {
    final fmt = DateFormat('MMM d, yyyy');
    return fmt.format(d);
  }
}

// ─── Reusable widgets ──────────────────────────────────────────────────

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({required this.label, this.isSelected = false, this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.inputHeightLg,
        decoration: BoxDecoration(
          color: isSelected ? null : AppColors.surfaceSubtle,
          gradient: isSelected ? AppGradients.primary : null,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body16.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
