import 'dart:math';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/liquid_glass/glass_segmented_tabs.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class WeightProgressCard extends StatefulWidget {
  const WeightProgressCard({super.key, required this.entries});

  final List<WeightEntry> entries;

  @override
  State<WeightProgressCard> createState() => _WeightProgressCardState();
}

class _WeightProgressCardState extends State<WeightProgressCard> {
  int _selectedIndex = 0;

  static const List<String> _rangeLabels = ['30D', '6M', '1Y', 'ALL'];

  List<WeightEntry> _sortedEntries() {
    final data = List<WeightEntry>.from(widget.entries);
    data.sort((a, b) => b.date.compareTo(a.date));
    return data;
  }

  List<WeightEntry> _filteredEntries() {
    final entries = _sortedEntries();
    if (entries.isEmpty) return entries;
    if (_selectedIndex == 3) return entries;

    final now = DateTime.now();
    DateTime cutoff;
    switch (_selectedIndex) {
      case 0:
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case 1:
        cutoff = DateTime(now.year, now.month - 6, now.day);
        break;
      case 2:
        cutoff = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        cutoff = now.subtract(const Duration(days: 30));
    }
    return entries.where((entry) => !entry.date.isBefore(cutoff)).toList();
  }

  String _formatWeight(double value) {
    final isInt = value % 1 == 0;
    return value.toStringAsFixed(isInt ? 0 : 1);
  }

  List<double> _buildTicks(List<WeightEntry> entries) {
    final weights = entries.map((e) => e.weight).toList();
    double minValue = weights.reduce(min);
    double maxValue = weights.reduce(max);
    if (minValue == maxValue) {
      minValue -= 1;
      maxValue += 1;
    }
    double range = maxValue - minValue;
    if (range < 2) {
      final extra = (2 - range) / 2;
      minValue -= extra;
      maxValue += extra;
      range = maxValue - minValue;
    }

    // Pick nice step: 1, 2, or 5 kg intervals to get 3–5 ticks
    final rawStep = range / 4;
    final niceStep = rawStep <= 1 ? 1.0 : rawStep <= 2.5 ? 2.0 : 5.0;

    minValue = (minValue / niceStep).floorToDouble() * niceStep;
    maxValue = (maxValue / niceStep).ceilToDouble() * niceStep;

    final tickCount = ((maxValue - minValue) / niceStep).round() + 1;
    return List<double>.generate(tickCount, (index) => maxValue - niceStep * index);
  }

  int? _computeGoalPercent() {
    final sm = SessionManager.to;
    final startWeight = sm.weightKg.value;
    final goalWeight = sm.goalWeightKg.value;
    if (startWeight == null || goalWeight == null || startWeight == goalWeight) return null;

    final entries = _sortedEntries();
    if (entries.isEmpty) return null;
    final current = entries.first.weight;

    final double progress;
    if (goalWeight > startWeight) {
      progress = (current - startWeight) / (goalWeight - startWeight);
    } else {
      progress = (startWeight - current) / (startWeight - goalWeight);
    }
    return (progress.clamp(0.0, 1.0) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries();
    final hasEntries = entries.isNotEmpty;
    final goalPercent = _computeGoalPercent();

    final ticks = hasEntries ? _buildTicks(entries) : <double>[];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
        border: AppBorders.screenCard,
        boxShadow: AppShadows.screenCard,
      ),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr(LocaleKeys.progress_weight_progress), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
              if (goalPercent != null)
                Container(
                  height: AppSizes.badgeHeight,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: AppBorders.screenCard,
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.flag, size: AppSizes.iconXs, color: AppColors.textEmphasis),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$goalPercent%',
                        style: AppTextStyles.caption12.copyWith(color: AppColors.textEmphasis, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(tr(LocaleKeys.progress_of_goal), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !hasEntries
                ? Padding(
                    key: ValueKey('empty_$_selectedIndex'),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                    child: Text(tr(LocaleKeys.progress_no_weight_data), style: AppTextStyles.body15.copyWith(color: AppColors.textSecondary)),
                  )
                : _WeightLineChart(key: ValueKey(_selectedIndex), entries: entries, ticks: ticks, formatWeight: _formatWeight),
          ),
          const SizedBox(height: AppSpacing.m),
          _SegmentedControl(labels: _rangeLabels, selectedIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i)),
        ],
      ),
    );
  }
}

class _WeightLineChart extends StatelessWidget {
  const _WeightLineChart({super.key, required this.entries, required this.ticks, required this.formatWeight});

  final List<WeightEntry> entries;
  final List<double> ticks;
  final String Function(double) formatWeight;

  static const double _vPad = 8;

  List<WeightEntry> _sortedAscending() {
    final data = List<WeightEntry>.from(entries);
    data.sort((a, b) => a.date.compareTo(b.date));
    return data;
  }

  List<WeightEntry> _downsample(List<WeightEntry> data, int maxPoints) {
    if (data.length <= maxPoints) return data;
    final List<WeightEntry> result = [];
    final double step = (data.length - 1) / (maxPoints - 1);
    for (int i = 0; i < maxPoints; i++) {
      final index = (i * step).round();
      result.add(data[index]);
    }
    return result;
  }

  List<String> _buildDateLabels(BuildContext context, DateTime minDate, DateTime maxDate, int count) {
    final formatter = DateFormat('MMM d', context.locale.toString());
    if (count <= 1) return [formatter.format(minDate)];
    final spanMs = maxDate.difference(minDate).inMilliseconds;
    return List.generate(count, (i) {
      final ms = (spanMs * i / (count - 1)).round();
      return formatter.format(minDate.add(Duration(milliseconds: ms)));
    });
  }

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 160;
    final totalHeight = chartHeight + _vPad * 2;
    final data = _downsample(_sortedAscending(), 40);
    final minWeight = ticks.isEmpty ? 0.0 : ticks.last;
    final maxWeight = ticks.isEmpty ? 0.0 : ticks.first;
    final minDate = data.isNotEmpty ? data.first.date : DateTime.now();
    final maxDate = data.isNotEmpty ? data.last.date : DateTime.now();
    final dateLabels = _buildDateLabels(context, minDate, maxDate, 5);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 18,
                height: totalHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: ticks
                      .map(
                        (value) => Transform.translate(
                          offset: const Offset(0, -1),
                          child: Text(
                            formatWeight(value),
                            style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: SizedBox(
                  height: totalHeight,
                  child: CustomPaint(
                    painter: _WeightLinePainter(entries: data, minWeight: minWeight, maxWeight: maxWeight, gridLines: ticks.length, vPad: _vPad),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Padding(
          padding: const EdgeInsets.only(left: 18 + AppSpacing.xxs, right: AppSpacing.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dateLabels
                .map((label) => Text(label, style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _WeightLinePainter extends CustomPainter {
  _WeightLinePainter({required this.entries, required this.minWeight, required this.maxWeight, required this.gridLines, this.vPad = 0});

  final List<WeightEntry> entries;
  final double minWeight;
  final double maxWeight;
  final int gridLines;
  final double vPad;

  double _weightToY(double weight, double drawHeight) {
    final weightSpan = maxWeight - minWeight == 0 ? 1.0 : maxWeight - minWeight;
    final normalized = (weight - minWeight) / weightSpan;
    return vPad + drawHeight * (1 - normalized);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final drawHeight = size.height - vPad * 2;

    // --- Dashed grid lines aligned to tick positions ---
    if (gridLines > 1) {
      final gridPaint = Paint()
        ..color = AppColors.textTertiary.withValues(alpha: 0.25)
        ..strokeWidth = 1;

      for (int i = 0; i < gridLines; i++) {
        final y = vPad + drawHeight * (i / (gridLines - 1));
        _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint, dashWidth: 4, gapWidth: 3);
      }
    }

    if (entries.isEmpty) return;

    final minDate = entries.first.date;
    final maxDate = entries.last.date;
    final dateSpan = maxDate.difference(minDate).inMilliseconds;

    // --- Actual weight line (solid, dark) ---
    final linePaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final dx = dateSpan == 0
          ? (entries.length == 1 ? size.width / 2 : size.width * (i / (entries.length - 1)))
          : size.width * (entry.date.difference(minDate).inMilliseconds / dateSpan);
      final dy = _weightToY(entry.weight, drawHeight);
      points.add(Offset(dx, dy));
    }

    if (points.length >= 2) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // --- Dots ---
    final dotPaint = Paint()..color = AppColors.textPrimary;
    for (int i = 0; i < points.length; i++) {
      final radius = i == points.length - 1 ? 4.5 : 3.0;
      canvas.drawCircle(points[i], radius, dotPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, {double dashWidth = 5, double gapWidth = 3}) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = sqrt(dx * dx + dy * dy);
    final dirX = dx / length;
    final dirY = dy / length;

    double drawn = 0;
    while (drawn < length) {
      final segEnd = min(drawn + dashWidth, length);
      canvas.drawLine(
        Offset(start.dx + dirX * drawn, start.dy + dirY * drawn),
        Offset(start.dx + dirX * segEnd, start.dy + dirY * segEnd),
        paint,
      );
      drawn = segEnd + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _WeightLinePainter oldDelegate) {
    return oldDelegate.entries != entries || oldDelegate.minWeight != minWeight || oldDelegate.maxWeight != maxWeight || oldDelegate.gridLines != gridLines;
  }
}

class _SegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _SegmentedControl({required this.labels, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassSegmentedTabs(labels: labels, activeIndex: selectedIndex, onTap: onTap);
  }
}
