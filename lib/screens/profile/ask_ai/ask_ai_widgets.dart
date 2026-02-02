import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class AskAiTopBar extends StatelessWidget {
  const AskAiTopBar({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.askAiTopBarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ProfileBackButton(onPressed: onBack ?? () => Get.back()),
          ),
          Text(
            'Ask AI',
            style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

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
    this.onAsk,
    this.onClear,
  });

  final VoidCallback? onAsk;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      radius: AppRadii.lg,
      shadow: AppShadows.cardSubtle,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Container(
            height: AppSizes.askAiInputHeight,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.search, size: AppSizes.iconMd, color: AppColors.violet),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Ask about your nutrition data in natural language...',
                    style: AppTextStyles.body14.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onClear,
                  child: const Icon(Icons.close, size: AppSizes.iconMd, color: AppColors.textSecondaryAlt),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AskAiPrimaryButton(
            label: 'Ask AI',
            leading: const Icon(Icons.auto_awesome, size: AppSizes.iconMd, color: AppColors.onPrimary),
            onPressed: onAsk,
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
          const AskAiSectionHeader(
            title: 'AI Response',
            icon: Icons.auto_awesome,
            iconGradient: AppGradients.askAiPrimary,
            iconRadius: AppRadii.pill,
            iconSize: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
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
            title: 'Summary',
            icon: icon,
            iconGradient: iconGradient,
            iconRadius: AppRadii.xs,
            iconSize: 28,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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

class AskAiCalendarCard extends StatelessWidget {
  const AskAiCalendarCard({
    super.key,
    required this.affectedDays,
    required this.affectedGradient,
    required this.monthLabel,
    required this.year,
    required this.month,
  });

  final List<int> affectedDays;
  final LinearGradient affectedGradient;
  final String monthLabel;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      radius: AppRadii.lg,
      shadow: AppShadows.cardSubtle,
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AskAiSectionHeader(
            title: 'Affected Days',
            icon: Icons.calendar_month,
            iconGradient: AppGradients.primary,
            iconRadius: AppRadii.xs,
            iconSize: 28,
          ),
          const SizedBox(height: AppSpacing.sm),
          _MonthSelector(label: monthLabel),
          const SizedBox(height: AppSpacing.sm),
          AskAiCalendarGrid(
            affectedDays: affectedDays,
            affectedGradient: affectedGradient,
            year: year,
            month: month,
          ),
          const SizedBox(height: AppSpacing.sm),
          _LegendRow(affectedGradient: affectedGradient),
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
  });

  final List<int> affectedDays;
  final LinearGradient affectedGradient;
  final int year;
  final int month;

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
  final List<String> labels = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
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
  });

  final List<int?> days;
  final double cellSize;
  final double gap;
  final List<int> affectedDays;
  final LinearGradient affectedGradient;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(days.length, (index) {
        final day = days[index];
        final isAffected = day != null && affectedDays.contains(day);
        final child = day == null
            ? const SizedBox.shrink()
            : Text(
                '$day',
                style: AppTextStyles.body15.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isAffected ? AppColors.onPrimary : AppColors.textPrimary,
                ),
              );
        return Padding(
          padding: EdgeInsets.only(right: index == days.length - 1 ? 0 : gap),
          child: Container(
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: day == null ? Colors.transparent : AppColors.surfaceSubtle,
              gradient: isAffected ? affectedGradient : null,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              boxShadow: isAffected ? AppShadows.calendarDay : null,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        );
      }),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          _MonthButton(icon: Icons.chevron_left),
          const Spacer(),
          Text(
            label,
            style: AppTextStyles.title.copyWith(fontSize: 18, height: 1.55),
          ),
          const Spacer(),
          _MonthButton(icon: Icons.chevron_right),
        ],
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 38,
      child: Center(
        child: Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(
            label: 'Affected',
            gradient: affectedGradient,
            useShadow: true,
          ),
          const SizedBox(width: AppSpacing.lg),
          _LegendItem(
            label: 'Normal',
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
