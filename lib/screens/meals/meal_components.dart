import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:flutter/material.dart';

enum MatchBadgeVariant { good, medium, low }

typedef OnTap = void Function();

class MealHeroHeader extends StatelessWidget {
  final String title;
  final String timeLabel;
  final ImageProvider? image;
  final Alignment imageAlignment;

  const MealHeroHeader({
    super.key,
    required this.title,
    required this.timeLabel,
    this.image,
    this.imageAlignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.mealHeroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: image != null
                  ? DecorationImage(
                      image: image!,
                      fit: BoxFit.cover,
                      alignment: imageAlignment,
                    )
                  : null,
              color: AppColors.surfaceMuted,
            ),
            child: image == null
                ? const Center(
                    child: Icon(Icons.photo, size: AppSizes.iconXl, color: AppColors.textTertiary),
                  )
                : null,
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.overlayDark60,
                  Color(0x00000000),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.l,
            right: AppSpacing.l,
            bottom: AppSpacing.l,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: AppSizes.iconSm, color: AppColors.onPrimary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      timeLabel,
                      style: AppTextStyles.caption12.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  title,
                  style: AppTextStyles.title24.copyWith(color: AppColors.onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MatchBadge extends StatelessWidget {
  final String text;
  final MatchBadgeVariant variant;

  const MatchBadge({
    super.key,
    required this.text,
    this.variant = MatchBadgeVariant.good,
  });

  Color get _background {
    switch (variant) {
      case MatchBadgeVariant.medium:
        return AppColors.matchYellowBg;
      case MatchBadgeVariant.low:
        return AppColors.matchRedBg;
      case MatchBadgeVariant.good:
        return AppColors.matchGreenBg;
    }
  }

  Color get _textColor {
    switch (variant) {
      case MatchBadgeVariant.medium:
        return AppColors.matchYellowText;
      case MatchBadgeVariant.low:
        return AppColors.errorText;
      case MatchBadgeVariant.good:
        return AppColors.successText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.matchBadgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTextStyles.badge14.copyWith(color: _textColor),
      ),
    );
  }
}

class CaloriesSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final MatchBadge? badge;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const CaloriesSummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.badge,
    this.margin,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.cardSmall,
      ),
      child: Stack(
        children: [
          if (badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: badge!,
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: AppTextStyles.stat48.copyWith(color: AppColors.primary)),
                  if (delta != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      height: AppSizes.matchBadgeHeight,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        delta!,
                        style: AppTextStyles.badge14.copyWith(color: AppColors.onPrimary),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MacroStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final double? height;

  const MacroStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? AppSizes.macroCardSize,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.cardSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconMd, color: iconColor),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption12.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.title24.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class MealRecordCard extends StatelessWidget {
  final String amount;
  final String mealtime;
  final String date;
  final VoidCallback? onAmountTap;
  final VoidCallback? onMealtimeTap;
  final VoidCallback? onDateTap;
  final EdgeInsetsGeometry? margin;

  const MealRecordCard({
    super.key,
    required this.amount,
    required this.mealtime,
    required this.date,
    this.onAmountTap,
    this.onMealtimeTap,
    this.onDateTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.separator),
        boxShadow: AppShadows.cardSmall,
      ),
      child: Column(
        children: [
          _RecordRow(
            label: 'Amount',
            value: amount,
            onTap: onAmountTap,
            showChevron: true,
          ),
          const Divider(color: AppColors.separator, height: AppSpacing.m, thickness: AppSizes.dividerThin),
          _RecordRow(
            label: 'Mealtime',
            value: mealtime,
            onTap: onMealtimeTap,
            showChevron: true,
          ),
          const Divider(color: AppColors.separator, height: AppSpacing.m, thickness: AppSizes.dividerThin),
          _RecordRow(
            label: 'Date',
            value: date,
            onTap: onDateTap,
            valueAsChip: true,
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showChevron;
  final bool valueAsChip;
  final VoidCallback? onTap;

  const _RecordRow({
    required this.label,
    required this.value,
    this.showChevron = false,
    this.valueAsChip = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trailing = valueAsChip
        ? Container(
            height: AppSizes.dateChipHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadii.sm1),
            ),
            alignment: Alignment.center,
            child: Text(value, style: AppTextStyles.formValue16),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppTextStyles.formValue16),
              if (showChevron) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.keyboard_arrow_down, size: AppSizes.iconSm, color: AppColors.textSecondary),
              ],
            ],
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: SizedBox(
        height: AppSizes.editFormRowHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.formLabel16),
            trailing,
          ],
        ),
      ),
    );
  }
}

class IngredientRow extends StatelessWidget {
  final Ingredient ingredient;
  final bool highlighted;
  final String? alertText;
  final VoidCallback? onTap;

  const IngredientRow({
    super.key,
    required this.ingredient,
    this.highlighted = false,
    this.alertText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = highlighted ? AppColors.warningSurface : AppColors.surface;
    final border = highlighted ? AppColors.warningStrong : Colors.transparent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        height: highlighted ? AppSizes.ingredientRowAlertHeight : AppSizes.ingredientRowHeight,
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (highlighted) ...[
                        const Icon(Icons.warning_amber_rounded, size: AppSizes.iconSm, color: AppColors.warningStrong),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        ingredient.name,
                        style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  if (alertText != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      alertText!,
                      style: AppTextStyles.label11.copyWith(color: AppColors.orange, fontWeight: FontWeight.w500),
                    ),
                  ],
                  const Spacer(),
                  _MacroDotsRow(ingredient: ingredient),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ingredient.calories.toStringAsFixed(0),
                  style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
                ),
                Text('kcal', style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroDotsRow extends StatelessWidget {
  final Ingredient ingredient;

  const _MacroDotsRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MacroDotLabel(color: AppColors.macroProtein, value: '${ingredient.proteins.toStringAsFixed(0)}g'),
        const SizedBox(width: AppSpacing.xs),
        _MacroDotLabel(color: AppColors.macroCarbsStrong, value: '${ingredient.carbs.toStringAsFixed(0)}g'),
        const SizedBox(width: AppSpacing.xs),
        _MacroDotLabel(color: AppColors.macroFats, value: '${ingredient.fats.toStringAsFixed(0)}g'),
      ],
    );
  }
}

class _MacroDotLabel extends StatelessWidget {
  final Color color;
  final String value;

  const _MacroDotLabel({required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizes.macroDotSm,
          height: AppSizes.macroDotSm,
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppOpacities.macroDot),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          value,
          style: AppTextStyles.macroDotLabel11,
        ),
      ],
    );
  }
}

class AllergyAlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final EdgeInsetsGeometry? margin;

  const AllergyAlertCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: AppSizes.alertCardHeight,
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.s, AppSpacing.m, AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.warningStrong),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warningStrong, size: AppSizes.iconMd),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.body13.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MeasurementChips extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const MeasurementChips({
    super.key,
    required this.options,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: index == options.length - 1 ? 0 : AppSpacing.s),
            child: GestureDetector(
              onTap: onChanged == null ? null : () => onChanged!(index),
              child: Container(
                height: AppSizes.chipHeight,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                alignment: Alignment.center,
                child: Text(
                  options[index],
                  style: AppTextStyles.formValue16.copyWith(
                    color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
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

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;

  const AmountInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.amountFieldWidth,
      height: AppSizes.chipHeight,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: const BorderSide(color: AppColors.surfaceMuted),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class GradientPillButton extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  final double height;

  const GradientPillButton({
    super.key,
    required this.label,
    required this.gradient,
    this.onTap,
    this.height = AppSizes.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Center(
            child: Text(label, style: AppTextStyles.body16.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class OutlinePillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const OutlinePillButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Ink(
        height: AppSizes.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.outline),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm, color: AppColors.textEmphasisAlt),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(label, style: AppTextStyles.body16.copyWith(color: AppColors.textEmphasisAlt, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassActionSheet extends StatelessWidget {
  final List<GlassActionSheetItem> items;

  const GlassActionSheet({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.glassSheet,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items
                .map((item) => Padding(
                      padding: EdgeInsets.only(bottom: item == items.last ? 0 : AppSpacing.s),
                      child: InkWell(
                        onTap: item.onTap,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: SizedBox(
                          height: AppSizes.actionRowHeight,
                          child: Row(
                            children: [
                              Icon(item.icon, color: item.color ?? AppColors.textPrimary, size: AppSizes.iconMd),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: AppTextStyles.selectMealPickerItem.copyWith(
                                    color: item.color ?? AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class GlassActionSheetItem {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const GlassActionSheetItem({
    required this.label,
    required this.icon,
    this.color,
    this.onTap,
  });
}

class SyncCard extends StatelessWidget {
  final String title;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  const SyncCard({
    super.key,
    required this.title,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg3),
        boxShadow: AppShadows.button,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.sync, size: AppSizes.iconMd, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: AppSizes.buttonHeightXxs,
                child: GradientPillButton(
                  label: primaryLabel,
                  gradient: AppGradients.primary,
                  height: AppSizes.buttonHeightXxs,
                  onTap: onPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              InkWell(
                onTap: onSecondary,
                child: Text(
                  secondaryLabel,
                  style: AppTextStyles.body16.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
