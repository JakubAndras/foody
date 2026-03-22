import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PickerSheet extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const PickerSheet({
    super.key,
    required this.options,
    this.selectedIndex = 0,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
      ),
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
                      child: isSelected
                          ? const Icon(Icons.check, color: AppColors.textPrimary, size: AppSizes.iconMd)
                          : const SizedBox(width: AppSizes.iconMd),
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

  const DatePickerCard({
    super.key,
    required this.month,
    required this.selectedDate,
    this.onSelected,
    this.onPrevMonth,
    this.onNextMonth,
  });

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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderButton(icon: Icons.chevron_left, onTap: onPrevMonth),
              Text(
                _formatMonth(month),
                style: AppTextStyles.title18.copyWith(
                  color: AppColors.textHeading,
                  letterSpacing: -0.4395,
                ),
              ),
              _HeaderButton(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekdayLabels
                .map((label) => SizedBox(
                      width: AppSizes.datePickerCell,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                      ),
                    ))
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
              final isSelected =
                  day.year == selectedDate.year && day.month == selectedDate.month && day.day == selectedDate.day;
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
                    style: AppTextStyles.body14.copyWith(
                      color: isSelected ? AppColors.onPrimary : AppColors.textEmphasis,
                      fontWeight: FontWeight.w500,
                    ),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.s),
        ),
        child: Icon(icon, color: AppColors.textHeading),
      ),
    );
  }
}
