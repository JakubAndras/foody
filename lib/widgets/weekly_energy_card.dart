import 'dart:math' as math;

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/day_record_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/widgets/liquid_glass/glass_segmented_tabs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

class _DayEnergyData {
  final double burned;
  final double consumed;
  const _DayEnergyData({required this.burned, required this.consumed});
}

class _WeeklyEnergyStats {
  final List<_DayEnergyData> days;
  final double totalBurned;
  final double totalConsumed;
  final double totalEnergy;
  const _WeeklyEnergyStats({required this.days, required this.totalBurned, required this.totalConsumed, required this.totalEnergy});
}

class WeeklyEnergyCard extends StatefulWidget {
  const WeeklyEnergyCard({super.key});

  @override
  State<WeeklyEnergyCard> createState() => _WeeklyEnergyCardState();
}

class _WeeklyEnergyCardState extends State<WeeklyEnergyCard> {
  int _selectedIndex = 0;

  List<String> get _labels => [tr(LocaleKeys.progress_this_wk), tr(LocaleKeys.progress_last_wk), tr(LocaleKeys.progress_two_wk_ago), tr(LocaleKeys.progress_three_wk_ago)];

  DateTime _startOfWeekMonday(DateTime date) => date.subtract(Duration(days: date.weekday - 1));

  _WeeklyEnergyStats _calculateStats(List<DayRecord> records, int index) {
    final today = _dateOnly(DateTime.now());
    final weekStart = _startOfWeekMonday(today).subtract(Duration(days: 7 * index));
    final byDate = {for (final r in records) _dateOnly(r.date): r};

    double totalBurned = 0;
    double totalConsumed = 0;
    final days = <_DayEnergyData>[];

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final record = byDate[date];
      final burned = record?.totalExerciseCalories ?? 0;
      final consumed = record?.totalCalories ?? 0;
      totalBurned += burned;
      totalConsumed += consumed;
      days.add(_DayEnergyData(burned: burned, consumed: consumed));
    }

    return _WeeklyEnergyStats(days: days, totalBurned: totalBurned, totalConsumed: totalConsumed, totalEnergy: totalConsumed - totalBurned);
  }

  String _formatCalories(double value) {
    final int v = value.round().abs();
    final formatted = v.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return value < 0 ? '-$formatted' : formatted;
  }

  List<int> _computeTicks(double maxValue) {
    if (maxValue <= 0) return [0];
    int step;
    if (maxValue <= 300) {
      step = 100;
    } else if (maxValue <= 1000) {
      step = 500;
    } else {
      step = 1000;
    }
    final int ceiling = ((maxValue / step).ceil()) * step;
    return List.generate((ceiling ~/ step) + 1, (i) => ceiling - i * step);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = DayRecordController.to.dayRecords.toList(growable: false);
      final stats = _calculateStats(records, _selectedIndex);
      final calUnit = tr(LocaleKeys.common_kcal);

      double maxBar = 0;
      for (final d in stats.days) {
        maxBar = math.max(maxBar, math.max(d.burned, d.consumed));
      }
      final ticks = _computeTicks(maxBar);
      final double chartMax = ticks.isNotEmpty ? ticks.first.toDouble() : 1;

      final weekStart = _startOfWeekMonday(_dateOnly(DateTime.now())).subtract(Duration(days: 7 * _selectedIndex));
      final dayLabels = List.generate(7, (i) {
        final date = weekStart.add(Duration(days: i));
        return DateFormat.E(context.locale.toString()).format(date);
      });

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.l),
          border: AppBorders.screenCard,
          boxShadow: AppShadows.screenCard,
        ),
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr(LocaleKeys.progress_weekly_energy), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.s),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey(_selectedIndex),
                children: [
                  Row(
                    children: [
                      Expanded(child: _EnergyStat(label: tr(LocaleKeys.progress_burned), value: _formatCalories(stats.totalBurned), unit: calUnit, valueColor: AppColors.exerciseOrange)),
                      Expanded(child: _EnergyStat(label: tr(LocaleKeys.progress_consumed), value: _formatCalories(stats.totalConsumed), unit: calUnit, valueColor: AppColors.greenStrong)),
                      Expanded(
                        child: _EnergyStat(
                          label: tr(LocaleKeys.progress_energy),
                          value: stats.totalEnergy > 0 ? '+${_formatCalories(stats.totalEnergy)}' : _formatCalories(stats.totalEnergy),
                          unit: calUnit,
                          valueColor: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _WeeklyEnergyChart(days: stats.days, ticks: ticks, chartMax: chartMax, dayLabels: dayLabels),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            GlassSegmentedTabs(labels: _labels, activeIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i)),
          ],
        ),
      );
    });
  }
}

class _EnergyStat extends StatelessWidget {
  const _EnergyStat({required this.label, required this.value, required this.unit, required this.valueColor});

  final String label;
  final String value;
  final String unit;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: AppSpacing.xxs),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: value, style: AppTextStyles.h3.copyWith(color: valueColor, fontWeight: FontWeight.w800)),
              TextSpan(text: ' $unit', style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyEnergyChart extends StatelessWidget {
  const _WeeklyEnergyChart({required this.days, required this.ticks, required this.chartMax, required this.dayLabels});

  final List<_DayEnergyData> days;
  final List<int> ticks;
  final double chartMax;
  final List<String> dayLabels;

  static const double _chartHeight = 200;

  String _tickLabel(int value) {
    if (value == 0) return '0';
    if (value >= 1000 && value % 1000 == 0) return '${value ~/ 1000},000';
    if (value >= 1000) return '${value ~/ 1000},${(value % 1000).toString().padLeft(3, '0')}';
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xxs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: AppSizes.chartLabelWidth,
                height: _chartHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (int i = 0; i < ticks.length; i++)
                      Positioned(
                        top: ticks.length > 1 ? _chartHeight * (i / (ticks.length - 1)) - 8.5 : 0,
                        right: 0,
                        child: Text(_tickLabel(ticks[i]), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: SizedBox(
                  height: _chartHeight,
                  child: CustomPaint(size: Size.infinite, painter: _WeeklyEnergyBarPainter(days: days, chartMax: chartMax, gridLineCount: ticks.length)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: EdgeInsets.only(left: AppSizes.chartLabelWidth + AppSpacing.xxs, right: AppSpacing.xxs),
          child: Row(
            children: dayLabels.map((l) => Expanded(child: Center(child: Text(l, style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary))))).toList(),
          ),
        ),
      ],
    );
  }
}

class _WeeklyEnergyBarPainter extends CustomPainter {
  _WeeklyEnergyBarPainter({required this.days, required this.chartMax, required this.gridLineCount});

  final List<_DayEnergyData> days;
  final double chartMax;
  final int gridLineCount;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.textTertiary.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    if (gridLineCount > 1) {
      for (int i = 0; i < gridLineCount; i++) {
        final y = size.height * (i / (gridLineCount - 1));
        _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    if (chartMax <= 0) return;

    final burnedPaint = Paint()..color = AppColors.exerciseOrange;
    final consumedPaint = Paint()..color = AppColors.greenStrong;

    final slotWidth = size.width / 7;
    final barWidth = slotWidth * 0.25;
    final gap = slotWidth * 0.04;

    for (int i = 0; i < 7; i++) {
      final day = i < days.length ? days[i] : const _DayEnergyData(burned: 0, consumed: 0);
      final slotCenter = slotWidth * (i + 0.5);

      if (day.burned > 0) {
        final barHeight = (day.burned / chartMax) * size.height;
        final left = slotCenter - barWidth - gap / 2;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(left, size.height - barHeight, barWidth, barHeight), const Radius.circular(3)), burnedPaint);
      }

      if (day.consumed > 0) {
        final barHeight = (day.consumed / chartMax) * size.height;
        final left = slotCenter + gap / 2;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(left, size.height - barHeight, barWidth, barHeight), const Radius.circular(3)), consumedPaint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, {double dashWidth = 4, double gapWidth = 3}) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final dirX = dx / length;
    final dirY = dy / length;
    double drawn = 0;
    while (drawn < length) {
      final segEnd = math.min(drawn + dashWidth, length);
      canvas.drawLine(Offset(start.dx + dirX * drawn, start.dy + dirY * drawn), Offset(start.dx + dirX * segEnd, start.dy + dirY * segEnd), paint);
      drawn = segEnd + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyEnergyBarPainter oldDelegate) {
    return oldDelegate.days != days || oldDelegate.chartMax != chartMax || oldDelegate.gridLineCount != gridLineCount;
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.legendDot,
          height: AppSizes.legendDot,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.label10.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}
