import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/widgets/picker_column.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PickerSheet extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const PickerSheet({super.key, required this.options, this.selectedIndex = 0, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.m),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.l)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(bottom: index == options.length - 1 ? 0 : AppSpacing.xs),
            child: InkWell(
              onTap: onSelected == null ? null : () => onSelected!(index),
              borderRadius: BorderRadius.circular(AppRadii.s),
              child: SizedBox(
                height: AppSizes.actionRowHeight,
                child: Row(
                  children: [
                    SizedBox(
                      width: AppSizes.iconLg,
                      child: isSelected ? const Icon(Icons.check, color: AppColors.textPrimary, size: AppSizes.iconMd) : const SizedBox(width: AppSizes.iconMd),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        options[index],
                        style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, height: 1.75, color: AppColors.textHeading, letterSpacing: -0.4492),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class DatePickerCard extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onSelected;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;

  const DatePickerCard({super.key, required this.month, required this.selectedDate, this.onSelected, this.onPrevMonth, this.onNextMonth});

  List<DateTime?> _buildCalendarDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = (firstDay.weekday + 6) % 7; // Monday = 0
    final totalDays = lastDay.day;

    final List<DateTime?> days = List.generate(startWeekday, (_) => null);
    for (int i = 1; i <= totalDays; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    while (days.length % 7 != 0) {
      days.add(null);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays(month);
    final weekdayLabels = [
      tr(LocaleKeys.day_mon).toUpperCase(),
      tr(LocaleKeys.day_tue).toUpperCase(),
      tr(LocaleKeys.day_wed).toUpperCase(),
      tr(LocaleKeys.day_thu).toUpperCase(),
      tr(LocaleKeys.day_fri).toUpperCase(),
      tr(LocaleKeys.day_sat).toUpperCase(),
      tr(LocaleKeys.day_sun).toUpperCase(),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.m),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.l)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderButton(icon: Icons.chevron_left, onTap: onPrevMonth),
              Text(_formatMonth(month), style: AppTextStyles.title18.copyWith(color: AppColors.textHeading, letterSpacing: -0.4395)),
              _HeaderButton(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekdayLabels
                .map(
                  (label) => SizedBox(
                    width: AppSizes.datePickerCell,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: days.map((day) {
              if (day == null) {
                return const SizedBox(width: AppSizes.datePickerCell, height: AppSizes.datePickerCell);
              }
              final isSelected = day.year == selectedDate.year && day.month == selectedDate.month && day.day == selectedDate.day;
              return InkWell(
                onTap: onSelected == null ? null : () => onSelected!(day),
                borderRadius: BorderRadius.circular(isSelected ? AppRadii.xxl : AppRadii.s),
                child: Container(
                  width: isSelected ? AppSizes.datePickerCellSelected : AppSizes.datePickerCell,
                  height: isSelected ? AppSizes.datePickerCellSelected : AppSizes.datePickerCell,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(isSelected ? AppRadii.xxl : AppRadii.s),
                    boxShadow: isSelected ? AppShadows.calendarDay : null,
                  ),
                  child: Text(
                    '${day.day}',
                    style: AppTextStyles.body14.copyWith(color: isSelected ? AppColors.onPrimary : AppColors.textEmphasis, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatMonth(DateTime date) {
    final months = [
      tr(LocaleKeys.month_january),
      tr(LocaleKeys.month_february),
      tr(LocaleKeys.month_march),
      tr(LocaleKeys.month_april),
      tr(LocaleKeys.month_may),
      tr(LocaleKeys.month_june),
      tr(LocaleKeys.month_july),
      tr(LocaleKeys.month_august),
      tr(LocaleKeys.month_september),
      tr(LocaleKeys.month_october),
      tr(LocaleKeys.month_november),
      tr(LocaleKeys.month_december),
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.s),
      child: Container(
        height: AppSizes.chipHeight,
        width: AppSizes.chipHeight,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.s)),
        child: Icon(icon, color: AppColors.textHeading),
      ),
    );
  }
}

class AmountPickerSheet extends StatefulWidget {
  final String title;
  final double initialValue;
  final ValueChanged<double>? onChanged;

  const AmountPickerSheet({super.key, required this.title, required this.initialValue, this.onChanged});

  static void show(BuildContext context, {required String title, required double initialValue, required ValueChanged<double> onChanged}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark,
      isScrollControlled: true,
      builder: (_) => AmountPickerSheet(title: title, initialValue: initialValue, onChanged: onChanged),
    );
  }

  @override
  State<AmountPickerSheet> createState() => _AmountPickerSheetState();
}

class _AmountPickerSheetState extends State<AmountPickerSheet> {
  late int _wholeIndex;
  late int _fractionIndex;

  static final List<String> _wholeValues = List.generate(43, (i) => '$i');

  static const List<String> _fractionLabels = ['\u2013', '\u215B', '\u00BC', '\u2153', '\u215C', '\u00BD', '\u2154', '\u215D', '\u00BE', '\u215E'];
  static const List<double> _fractionValues = [0, 0.125, 0.25, 1 / 3, 0.375, 0.5, 2 / 3, 0.625, 0.75, 0.875];

  @override
  void initState() {
    super.initState();
    final whole = widget.initialValue.truncate().clamp(0, 42);
    final frac = widget.initialValue - widget.initialValue.truncate();
    _wholeIndex = whole;
    _fractionIndex = _closestFractionIndex(frac);
  }

  int _closestFractionIndex(double frac) {
    if (frac < 0.001) return 0;
    int bestIndex = 0;
    double bestDiff = double.infinity;
    for (int i = 0; i < _fractionValues.length; i++) {
      final diff = (frac - _fractionValues[i]).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  double get _currentValue => _wholeIndex + _fractionValues[_fractionIndex];

  /// When whole is 0, hide the "–" option so the user can't pick 0 + nothing.
  List<String> get _activeFractionLabels => _wholeIndex == 0 ? _fractionLabels.sublist(1) : _fractionLabels;

  int get _activeFractionIndex => _wholeIndex == 0 ? (_fractionIndex - 1).clamp(0, _activeFractionLabels.length - 1) : _fractionIndex;

  void _onPickerChanged() {
    widget.onChanged?.call(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0), // out spacing
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)), // bottom: Radius.circular(AppRadii.xxl + 10)
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: CustomPaint(
            painter: const _AmountSheetPainter(),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.xxs),
                  const SheetDragHandle(color: AppColors.greyLight3),
                  const SizedBox(height: AppSpacing.s),
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl * 2),
                    child: SizedBox(height: 200, child: _buildPicker()),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Row(
        children: [
          Text(
            tr(LocaleKeys.ingredient_amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title17.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker() {
    final fractionLabels = _activeFractionLabels;
    final fractionIndex = _activeFractionIndex;

    return Row(
      children: [
        Expanded(
          child: PickerColumn(
            values: _wholeValues,
            selectedIndex: _wholeIndex,
            height: 200,
            selectionHighlightBorderRadius: AppRadii.l,
            onSelected: (index) {
              setState(() {
                final wasZero = _wholeIndex == 0;
                _wholeIndex = index;
                if (index == 0 && _fractionIndex == 0) {
                  // Moving to 0 with "–" selected → jump to first real fraction
                  _fractionIndex = 1;
                } else if (wasZero && index != 0) {
                  // Moving away from 0 → offset was shifted, restore real index
                  // _fractionIndex is already correct, no adjustment needed
                }
              });
              _onPickerChanged();
            },
          ),
        ),
        Expanded(
          child: PickerColumn(
            key: ValueKey(_wholeIndex == 0),
            values: fractionLabels,
            selectedIndex: fractionIndex,
            height: 200,
            selectionHighlightBorderRadius: AppRadii.l,
            onSelected: (index) {
              setState(() {
                _fractionIndex = _wholeIndex == 0 ? index + 1 : index;
              });
              _onPickerChanged();
            },
          ),
        ),
      ],
    );
  }
}

class MealtimePickerSheet extends StatefulWidget {
  final List<String> options;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  const MealtimePickerSheet({super.key, required this.options, required this.initialIndex, this.onChanged});

  static void show(BuildContext context, {required List<String> options, required int initialIndex, required ValueChanged<int> onChanged}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark,
      isScrollControlled: true,
      builder: (_) => MealtimePickerSheet(options: options, initialIndex: initialIndex, onChanged: onChanged),
    );
  }

  @override
  State<MealtimePickerSheet> createState() => _MealtimePickerSheetState();
}

class _MealtimePickerSheetState extends State<MealtimePickerSheet> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.options.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: CustomPaint(
            painter: const _GlassPickerSheetPainter(),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.xxs),
                  const SheetDragHandle(color: AppColors.greyLight3),
                  const SizedBox(height: AppSpacing.s),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: Row(
                      children: [
                        Text(
                          tr(LocaleKeys.meal_mealtime),
                          style: AppTextStyles.title17.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl * 2),
                    child: SizedBox(
                      height: 200,
                      child: PickerColumn(
                        values: widget.options,
                        selectedIndex: _selectedIndex,
                        height: 200,
                        selectionHighlightBorderRadius: AppRadii.l,
                        onSelected: (index) {
                          setState(() => _selectedIndex = index);
                          widget.onChanged?.call(index);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPickerSheetPainter extends CustomPainter {
  const _GlassPickerSheetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromLTRBAndCorners(
      0, 0, size.width, size.height,
      topLeft: Radius.circular(AppRadii.xxl),
      topRight: Radius.circular(AppRadii.xxl),
    );

    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFFFFFF));

    final highlightRect = Rect.fromLTWH(size.width * 0.1, 0, size.width * 0.8, size.height * 0.12);
    canvas.drawRRect(
      RRect.fromRectAndCorners(highlightRect, topLeft: Radius.circular(AppRadii.xxl), topRight: Radius.circular(AppRadii.xxl)),
      Paint()
        ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x30FFFFFF), Color(0x00FFFFFF)]).createShader(highlightRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    canvas.drawRRect(
      rrect.deflate(0.4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.white1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AmountSheetPainter extends CustomPainter {
  const _AmountSheetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromLTRBAndCorners(
      0,
      0,
      size.width,
      size.height,
      topLeft: Radius.circular(AppRadii.xl),
      topRight: Radius.circular(AppRadii.xl),
      bottomRight: Radius.circular(AppRadii.xxl + 10),
      bottomLeft: Radius.circular(AppRadii.xxl + 10),
    );

    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFFFFFF)); // 0xB0FFFFFF

    final highlightRect = Rect.fromLTWH(size.width * 0.1, 0, size.width * 0.8, size.height * 0.12);
    canvas.drawRRect(
      RRect.fromRectAndCorners(highlightRect, topLeft: Radius.circular(AppRadii.xl), topRight: Radius.circular(AppRadii.xl)),
      Paint()
        ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x30FFFFFF), Color(0x00FFFFFF)]).createShader(highlightRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    canvas.drawRRect(
      rrect.deflate(0.4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.white1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
