import 'dart:math';

import 'package:diplomka/app_theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';

class WeightProgressCard extends StatefulWidget {
  const WeightProgressCard({super.key, required this.entries});

  final List<WeightEntry> entries;

  @override
  State<WeightProgressCard> createState() => _WeightProgressCardState();
}

class _WeightProgressCardState extends State<WeightProgressCard> {
  int _selectedIndex = 0;

  static const List<String> _rangeLabels = ['90D', '6M', '1Y', 'ALL'];

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
        cutoff = now.subtract(const Duration(days: 90));
        break;
      case 1:
        cutoff = DateTime(now.year, now.month - 6, now.day);
        break;
      case 2:
        cutoff = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        cutoff = now.subtract(const Duration(days: 90));
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
      minValue -= 0.5;
      maxValue += 0.5;
    }
    double range = maxValue - minValue;
    if (range < 1) {
      final extra = (1 - range) / 2;
      minValue -= extra;
      maxValue += extra;
      range = maxValue - minValue;
    }
    final step = range / 4;
    return List<double>.generate(5, (index) => maxValue - step * index);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries();
    final hasEntries = entries.isNotEmpty;
    final latest = hasEntries ? entries.first : null;
    final earliest = hasEntries ? entries.last : null;
    final change = hasEntries && entries.length > 1 ? latest!.weight - earliest!.weight : 0.0;
    final changeLabel = hasEntries && entries.length > 1 ? '${change >= 0 ? '+' : ''}${_formatWeight(change)} kg' : '—';
    final changeIcon = change > 0
        ? Icons.trending_up
        : change < 0
        ? Icons.trending_down
        : Icons.trending_flat;

    final ticks = hasEntries ? _buildTicks(entries) : <double>[];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.cardSoft,
      ),
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr(LocaleKeys.progress_weight_progress), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
              Container(
                height: AppSizes.badgeHeight,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: AppColors.surfaceMuted),
                ),
                child: Row(
                  children: [
                    Icon(changeIcon, size: AppSizes.iconXs, color: AppColors.textEmphasis),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      changeLabel,
                      style: AppTextStyles.caption12.copyWith(color: AppColors.textEmphasis, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(tr(LocaleKeys.progress_since_start), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          if (!hasEntries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
              child: Text(tr(LocaleKeys.progress_no_weight_data), style: AppTextStyles.body15.copyWith(color: AppColors.textSecondary)),
            )
          else
            _WeightLineChart(entries: entries, ticks: ticks, formatWeight: _formatWeight),
          const SizedBox(height: AppSpacing.l),
          _SegmentedControl(labels: _rangeLabels, selectedIndex: _selectedIndex, onTap: (index) => setState(() => _selectedIndex = index)),
        ],
      ),
    );
  }
}

class _WeightLineChart extends StatelessWidget {
  const _WeightLineChart({required this.entries, required this.ticks, required this.formatWeight});

  final List<WeightEntry> entries;
  final List<double> ticks;
  final String Function(double) formatWeight;

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

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 140;
    final data = _downsample(_sortedAscending(), 40);
    final minWeight = ticks.isEmpty ? 0.0 : ticks.last;
    final maxWeight = ticks.isEmpty ? 0.0 : ticks.first;

    return Row(
      children: [
        SizedBox(
          width: AppSizes.chartLabelWidth,
          height: chartHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ticks
                .map(
                  (value) => Text(
                    formatWeight(value),
                    style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: SizedBox(
            height: chartHeight,
            child: CustomPaint(
              painter: _WeightLinePainter(entries: data, minWeight: minWeight, maxWeight: maxWeight, gridLines: ticks.length),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightLinePainter extends CustomPainter {
  _WeightLinePainter({required this.entries, required this.minWeight, required this.maxWeight, required this.gridLines});

  final List<WeightEntry> entries;
  final double minWeight;
  final double maxWeight;
  final int gridLines;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.surfaceSubtle
      ..strokeWidth = AppSizes.dividerThin;

    if (gridLines > 1) {
      for (int i = 0; i < gridLines; i++) {
        final y = size.height * (i / (gridLines - 1));
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    if (entries.isEmpty) return;

    final minDate = entries.first.date;
    final maxDate = entries.last.date;
    final dateSpan = maxDate.difference(minDate).inMilliseconds;
    final weightSpan = maxWeight - minWeight == 0 ? 1 : maxWeight - minWeight;

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final dx = dateSpan == 0
          ? (entries.length == 1 ? size.width / 2 : size.width * (i / (entries.length - 1)))
          : size.width * (entry.date.difference(minDate).inMilliseconds / dateSpan);
      final normalized = (entry.weight - minWeight) / weightSpan;
      final dy = size.height * (1 - normalized);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = AppColors.primary;
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final dx = dateSpan == 0
          ? (entries.length == 1 ? size.width / 2 : size.width * (i / (entries.length - 1)))
          : size.width * (entry.date.difference(minDate).inMilliseconds / dateSpan);
      final normalized = (entry.weight - minWeight) / weightSpan;
      final dy = size.height * (1 - normalized);
      final radius = i == entries.length - 1 ? 4.5 : 3.0;
      canvas.drawCircle(Offset(dx, dy), radius, dotPaint);
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
    return GlassSegmentedControl(segments: labels, selectedIndex: selectedIndex, onSegmentSelected: onTap, useOwnLayer: true);
  }
}
