import 'dart:math';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/weight_entry_controller.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/widgets/dashboard_calendar_sheet.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/widgets/sheet_top_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

Future<void> showWeightLogSheet(
  BuildContext context, {
  WeightEntry? entry,
  String? title,
  double? initialWeight,
  bool showDate = true,
  Future<void> Function(double weight)? onSave,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: AppColors.overlayDark,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: WeightLogSheet(entry: entry, title: title, initialWeight: initialWeight, showDate: showDate, onSave: onSave),
    ),
  );
}

class WeightLogSheet extends StatefulWidget {
  const WeightLogSheet({super.key, this.entry, this.title, this.initialWeight, this.showDate = true, this.onSave});

  final WeightEntry? entry;
  final String? title;
  final double? initialWeight;
  final bool showDate;
  final Future<void> Function(double weight)? onSave;

  @override
  State<WeightLogSheet> createState() => _WeightLogSheetState();
}

class _WeightLogSheetState extends State<WeightLogSheet> {
  late DateTime _selectedDate;
  late double _selectedWeight;
  bool _isSaving = false;

  double? get _lastEntryWeight => WeightEntryController.to.latestEntry?.weight;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.entry?.date ?? DateTime(now.year, now.month, now.day);
    _selectedWeight = widget.initialWeight ?? widget.entry?.weight ?? _lastEntryWeight ?? 70.0;
  }

  bool get _isEditing => widget.entry != null;

  String _formatWeight(double value) {
    final bool isInt = value % 1 == 0;
    return value.toStringAsFixed(isInt ? 0 : 1);
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    if (selected == today) return tr(LocaleKeys.common_today);
    return DateFormat('MMM d, yyyy', context.locale.toString()).format(date);
  }

  DateTime _applyDate(DateTime base, DateTime date) {
    return DateTime(date.year, date.month, date.day, base.hour, base.minute);
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      if (widget.onSave != null) {
        await widget.onSave!(_selectedWeight);
      } else {
        final baseDate = widget.entry?.date ?? DateTime.now();
        final date = _applyDate(baseDate, _selectedDate);
        final entry = WeightEntry(id: widget.entry?.id, date: date, weight: _selectedWeight, photoPath: widget.entry?.photoPath);
        await WeightEntryController.to.saveEntry(entry);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      showSnackBar(context: context, message: tr(LocaleKeys.weight_log_save_failed), type: SnackBarType.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete() async {
    final entry = widget.entry;
    if (entry == null) return;
    await WeightEntryController.to.deleteEntry(entry);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _openDatePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark,
      isScrollControlled: true,
      builder: (_) => DashboardCalendarSheet(
        selectedDate: _selectedDate,
        selectOnPickerScroll: false,
        onDateSelected: (date) {
          setState(() => _selectedDate = _applyDate(_selectedDate, date));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    final lastWeight = _lastEntryWeight;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl), bottom: Radius.circular(AppRadii.xxl + 10)),
      ),
      padding: EdgeInsets.only(bottom: max(bottomPadding, AppSpacing.l)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xxs),
            const SheetDragHandle(),
            const SizedBox(height: AppSpacing.xs),
            SheetTopBar(
              title: widget.title ?? tr(LocaleKeys.weight_log_label_weight),
              onClose: () => Navigator.of(context).pop(),
              onConfirm: _isSaving ? null : _handleSave,
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(_formatWeight(_selectedWeight), style: AppTextStyles.displayXL.copyWith(fontSize: 56)),
                const SizedBox(width: AppSpacing.xs),
                Text(tr(LocaleKeys.common_kg), style: AppTextStyles.h3),
              ],
            ),
            if (lastWeight != null && widget.showDate) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                tr(LocaleKeys.weight_log_last_entry, args: [_formatWeight(lastWeight)]),
                style: AppTextStyles.body15.copyWith(color: AppColors.textTertiary),
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              height: 60,
              child: _WeightRulerPicker(value: _selectedWeight, onChanged: (v) => setState(() => _selectedWeight = v)),
            ),
            if (widget.showDate) ...[
              const SizedBox(height: AppSpacing.l),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openDatePicker,
                    borderRadius: BorderRadius.circular(AppRadii.l),
                    child: Container(
                      height: AppSizes.buttonHeightSm,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.l),
                        border: Border.all(color: AppColors.outline),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                      child: Row(
                        children: [
                          Text(tr(LocaleKeys.weight_log_label_date), style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text(
                            _formatDateLabel(_selectedDate),
                            style: AppTextStyles.title17.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(CupertinoIcons.chevron_right, size: AppSizes.iconMd, color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (_isEditing) ...[
              const SizedBox(height: AppSpacing.l),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                child: _DangerButton(label: tr(LocaleKeys.common_delete), onPressed: _handleDelete),
              ),
            ],
            const SizedBox(height: AppSpacing.s),
          ],
        ),
      ),
    );
  }
}

class _WeightRulerPicker extends StatefulWidget {
  const _WeightRulerPicker({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_WeightRulerPicker> createState() => _WeightRulerPickerState();
}

class _WeightRulerPickerState extends State<_WeightRulerPicker> {
  late ScrollController _scrollController;
  bool _isUserScrolling = false;

  static const double _minWeight = 20.0;
  static const double _maxWeight = 250.0;
  static const double _stepKg = 0.1;
  static const double _tickSpacing = 10.0;

  double _weightToOffset(double weight) => ((weight - _minWeight) / _stepKg) * _tickSpacing;
  double _offsetToWeight(double offset) => _minWeight + (offset / _tickSpacing) * _stepKg;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: _weightToOffset(widget.value));
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(_WeightRulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isUserScrolling && (widget.value - oldWidget.value).abs() > 0.05) {
      _scrollController.jumpTo(_weightToOffset(widget.value));
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final raw = _offsetToWeight(_scrollController.offset);
    final snapped = (raw * 10).roundToDouble() / 10;
    final clamped = snapped.clamp(_minWeight, _maxWeight);
    if ((clamped - widget.value).abs() >= 0.05) {
      HapticFeedback.mediumImpact();
      widget.onChanged(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final halfScreen = screenWidth / 2;
    final totalTicks = ((_maxWeight - _minWeight) / _stepKg).round() + 1;
    final contentWidth = totalTicks * _tickSpacing;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollStartNotification) _isUserScrolling = true;
        if (n is ScrollEndNotification) _isUserScrolling = false;
        return false;
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: halfScreen),
              child: CustomPaint(size: Size(contentWidth, 60), painter: _RulerPainter()),
            ),
          ),
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Container(width: 1.5, height: 52, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double tickSpacing = 10.0;
    final int totalTicks = (size.width / tickSpacing).round();

    final tickColor = AppColors.textTertiary.withValues(alpha: 0.35);

    final minorPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1;

    final halfPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1.2;

    final majorPaint = Paint()
      ..color = AppColors.textTertiary.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;

    const double majorHeight = 36;
    const double halfHeight = 28;
    const double minorHeight = 20;

    for (int i = 0; i <= totalTicks; i++) {
      final dx = i * tickSpacing;
      final isWhole = i % 10 == 0;
      final isHalf = i % 5 == 0;

      final double tickH;
      final Paint paint;
      if (isWhole) {
        tickH = majorHeight;
        paint = majorPaint;
      } else if (isHalf) {
        tickH = halfHeight;
        paint = halfPaint;
      } else {
        tickH = minorHeight;
        paint = minorPaint;
      }

      canvas.drawLine(Offset(dx, size.height), Offset(dx, size.height - tickH), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: Material(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.title17.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
