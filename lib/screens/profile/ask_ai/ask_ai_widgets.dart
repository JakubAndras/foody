import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ask_ai_query_response.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class AskAiPrimaryButton extends StatelessWidget {
  const AskAiPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.height = AppSizes.askAiActionHeight,
    this.radius = AppRadii.md,
    this.gradient = AppGradients.askAiPrimary,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final double height;
  final double radius;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.body15.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AskAiPromptCard extends StatelessWidget {
  const AskAiPromptCard({
    super.key,
    this.controller,
    this.onAsk,
    this.onClear,
    this.readOnly = false,
    this.isLoading = false,
  });

  final TextEditingController? controller;
  final VoidCallback? onAsk;
  final VoidCallback? onClear;
  final bool readOnly;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      radius: AppRadii.lg,
      shadow: AppShadows.cardSubtle,
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        children: [
          Container(
            height: AppSizes.askAiInputHeight,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.search, size: AppSizes.iconMd, color: AppColors.violet),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: readOnly,
                    maxLines: null,
                    maxLength: 500,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: AppTextStyles.body14.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textBody,
                    ),
                    decoration: InputDecoration(
                      hintText: tr(LocaleKeys.ask_ai_hint),
                      hintStyle: AppTextStyles.body14.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (!readOnly)
                  InkWell(
                    onTap: onClear,
                    child: const Icon(Icons.close, size: AppSizes.iconMd, color: AppColors.textSecondaryAlt),
                  ),
              ],
            ),
          ),
          if (!readOnly) ...[
            const SizedBox(height: AppSpacing.m),
            AskAiPrimaryButton(
              label: isLoading ? tr(LocaleKeys.voice_analyzing) : tr(LocaleKeys.ask_ai_title),
              leading: isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
                  : const Icon(Icons.auto_awesome, size: AppSizes.iconMd, color: AppColors.onPrimary),
              onPressed: isLoading ? null : onAsk,
            ),
          ],
        ],
      ),
    );
  }
}

class AskAiSectionHeader extends StatelessWidget {
  const AskAiSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.iconGradient,
    this.iconRadius = AppRadii.xs,
    this.iconSize = 28,
  });

  final String title;
  final IconData icon;
  final LinearGradient iconGradient;
  final double iconRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: iconGradient,
            borderRadius: BorderRadius.circular(iconRadius),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: AppSizes.iconSm, color: AppColors.onPrimary),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class AskAiExampleQuestionCard extends StatelessWidget {
  const AskAiExampleQuestionCard({super.key, required this.label, this.height, this.onTap});

  final String label;
  final double? height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Container(
            constraints: BoxConstraints(minHeight: height ?? 48),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: AppTextStyles.body14.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.textBody,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AskAiResponseCard extends StatelessWidget {
  const AskAiResponseCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      radius: AppRadii.lg,
      shadow: AppShadows.cardSubtle,
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AskAiSectionHeader(
            title: tr(LocaleKeys.ask_ai_response_title),
            icon: Icons.auto_awesome,
            iconGradient: AppGradients.askAiPrimary,
            iconRadius: AppRadii.pill,
            iconSize: 32,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            text,
            style: AppTextStyles.body15.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

class AskAiSummaryCard extends StatelessWidget {
  const AskAiSummaryCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.iconGradient,
    required this.panelGradient,
    required this.valueGradient,
  });

  final int value;
  final String label;
  final IconData icon;
  final LinearGradient iconGradient;
  final LinearGradient panelGradient;
  final LinearGradient valueGradient;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      radius: AppRadii.lg,
      shadow: AppShadows.cardSubtle,
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AskAiSectionHeader(
            title: tr(LocaleKeys.ask_ai_summary),
            icon: icon,
            iconGradient: iconGradient,
            iconRadius: AppRadii.xs,
            iconSize: 28,
          ),
          const SizedBox(height: AppSpacing.s),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
            decoration: BoxDecoration(
              gradient: panelGradient,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              children: [
                GradientText(
                  text: value.toString(),
                  style: AppTextStyles.displayL.copyWith(fontSize: 48, height: 1.0),
                  gradient: valueGradient,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppTextStyles.body13.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryAlt,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AskAiCalendarCard extends StatefulWidget {
  const AskAiCalendarCard({
    super.key,
    required this.allAffectedDays,
    required this.affectedGradient,
    required this.initialYear,
    required this.initialMonth,
    this.onDayTap,
  });

  /// All affected days across all months.
  final List<AskAiAffectedDay> allAffectedDays;
  final LinearGradient affectedGradient;
  final int initialYear;
  final int initialMonth;
  final void Function(DateTime date)? onDayTap;

  @override
  State<AskAiCalendarCard> createState() => _AskAiCalendarCardState();
}

class _AskAiCalendarCardState extends State<AskAiCalendarCard> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
  }

  void _prevMonth() {
    setState(() {
      _month -= 1;
      if (_month < 1) {
        _month = 12;
        _year -= 1;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      _month += 1;
      if (_month > 12) {
        _month = 1;
        _year += 1;
      }
    });
  }

  List<int> _affectedDaysForCurrentMonth() {
    return widget.allAffectedDays
        .where((d) => d.year == _year && d.month == _month)
        .map((d) => d.day)
        .toList();
  }

  String _monthLabel() {
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
    return '${months[_month - 1]} $_year';
  }

  void _onHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 200) {
      _prevMonth();
    } else if (velocity < -200) {
      _nextMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysForMonth = _affectedDaysForCurrentMonth();

    return ProfileCard(
      radius: AppRadii.lg,
      shadow: AppShadows.cardSubtle,
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AskAiSectionHeader(
            title: tr(LocaleKeys.ask_ai_affected_days),
            icon: Icons.calendar_month,
            iconGradient: AppGradients.primary,
            iconRadius: AppRadii.xs,
            iconSize: 28,
          ),
          const SizedBox(height: AppSpacing.s),
          GestureDetector(
            onHorizontalDragEnd: _onHorizontalSwipe,
            child: Column(
              children: [
                _MonthSelector(
                  label: _monthLabel(),
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                ),
                const SizedBox(height: AppSpacing.s),
                AskAiCalendarGrid(
                  affectedDays: daysForMonth,
                  affectedGradient: widget.affectedGradient,
                  year: _year,
                  month: _month,
                  onDayTap: widget.onDayTap != null
                      ? (day) => widget.onDayTap!(DateTime(_year, _month, day))
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          _LegendRow(affectedGradient: widget.affectedGradient),
        ],
      ),
    );
  }
}

class AskAiCalendarGrid extends StatelessWidget {
  const AskAiCalendarGrid({
    super.key,
    required this.affectedDays,
    required this.affectedGradient,
    required this.year,
    required this.month,
    this.onDayTap,
  });

  final List<int> affectedDays;
  final LinearGradient affectedGradient;
  final int year;
  final int month;
  final void Function(int day)? onDayTap;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDay = DateTime(year, month, 1);
    final leadingEmpty = firstDay.weekday % 7;

    final List<int?> cells = [
      ...List<int?>.filled(leadingEmpty, null),
      ...List<int?>.generate(daysInMonth, (index) => index + 1),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Column(
      children: [
        _WeekdayHeader(),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = AppSpacing.xs;
            final cellSize = (constraints.maxWidth - gap * 6) / 7;
            final rows = <Widget>[];
            for (int i = 0; i < cells.length; i += 7) {
              rows.add(_DayRow(
                days: cells.sublist(i, i + 7),
                cellSize: cellSize,
                gap: gap,
                affectedDays: affectedDays,
                affectedGradient: affectedGradient,
                onDayTap: onDayTap,
              ));
              if (i + 7 < cells.length) {
                rows.add(const SizedBox(height: AppSpacing.xs));
              }
            }
            return Column(children: rows);
          },
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final labels = [
      tr(LocaleKeys.day_sun),
      tr(LocaleKeys.day_mon),
      tr(LocaleKeys.day_tue),
      tr(LocaleKeys.day_wed),
      tr(LocaleKeys.day_thu),
      tr(LocaleKeys.day_fri),
      tr(LocaleKeys.day_sat),
    ];
    return Row(
      children: labels
          .map((label) => Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.label11.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.days,
    required this.cellSize,
    required this.gap,
    required this.affectedDays,
    required this.affectedGradient,
    this.onDayTap,
  });

  final List<int?> days;
  final double cellSize;
  final double gap;
  final List<int> affectedDays;
  final LinearGradient affectedGradient;
  final void Function(int day)? onDayTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(days.length, (index) {
        final day = days[index];
        final isAffected = day != null && affectedDays.contains(day);
        final label = day == null
            ? const SizedBox.shrink()
            : Text(
                '$day',
                style: AppTextStyles.body15.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isAffected ? AppColors.onPrimary : AppColors.textPrimary,
                ),
              );

        Widget cell = Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: day == null ? Colors.transparent : AppColors.surfaceSubtle,
            gradient: isAffected ? affectedGradient : null,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            boxShadow: isAffected ? AppShadows.calendarDay : null,
          ),
          alignment: Alignment.center,
          child: label,
        );

        if (isAffected && onDayTap != null) {
          cell = GestureDetector(
            onTap: () => onDayTap!(day),
            child: cell,
          );
        }

        return Padding(
          padding: EdgeInsets.only(right: index == days.length - 1 ? 0 : gap),
          child: cell,
        );
      }),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.label,
    this.onPrev,
    this.onNext,
  });

  final String label;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          _MonthButton(icon: Icons.chevron_left, onTap: onPrev),
          const Spacer(),
          Text(
            label,
            style: AppTextStyles.title.copyWith(fontSize: 18, height: 1.55),
          ),
          const Spacer(),
          _MonthButton(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.affectedGradient});

  final LinearGradient affectedGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(
            label: tr(LocaleKeys.ask_ai_affected),
            gradient: affectedGradient,
            useShadow: true,
          ),
          const SizedBox(width: AppSpacing.l),
          _LegendItem(
            label: tr(LocaleKeys.ask_ai_normal),
            gradient: null,
            useShadow: false,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.gradient, required this.useShadow});

  final String label;
  final LinearGradient? gradient;
  final bool useShadow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? AppColors.surfaceMuted : null,
            borderRadius: BorderRadius.circular(6),
            border: gradient == null ? Border.all(color: AppColors.outline) : null,
            boxShadow: useShadow ? AppShadows.cardSmall : null,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.body13.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textBody,
          ),
        ),
      ],
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText({super.key, required this.text, required this.style, required this.gradient});

  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style),
    );
  }
}
