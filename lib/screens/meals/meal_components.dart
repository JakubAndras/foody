import 'dart:io' show Platform;
import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:diplomka/widgets/glass_popup.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:diplomka/widgets/animated_add_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum MatchBadgeVariant { good, medium, low }

typedef OnTap = void Function();

class MealHeroHeader extends StatelessWidget {
  final String title;
  final String timeLabel;
  final String? trailingLabel;
  final ImageProvider? image;
  final Alignment imageAlignment;
  final double? confidence;
  final VoidCallback? onTitleTap;
  final bool showTime;
  final TextEditingController? titleController;
  final FocusNode? titleFocusNode;

  const MealHeroHeader({super.key, required this.title, required this.timeLabel, this.trailingLabel, this.image, this.imageAlignment = Alignment.center, this.confidence, this.onTitleTap, this.showTime = true, this.titleController, this.titleFocusNode});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.mealHeroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [AppColors.overlayDark60, Colors.transparent]),
            ),
          ),
          Positioned(
            left: AppSpacing.l,
            right: AppSpacing.l,
            bottom: AppSpacing.l,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTime) ...[
                  Row(
                    children: [
                      Icon(CupertinoIcons.time, size: AppSizes.iconSm, color: Colors.white.withValues(alpha: 0.8)),
                      const SizedBox(width: AppSpacing.xxs),
                      Column(
                        children: [
                          Text(timeLabel, style: AppTextStyles.caption12.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                          const SizedBox(height: 0.5),
                        ],
                      ),
                      if (trailingLabel != null) ...[
                        const SizedBox(width: AppSpacing.s),
                        Icon(Icons.monitor_weight_outlined, size: AppSizes.iconSm, color: Colors.white.withValues(alpha: 0.8)),
                        const SizedBox(width: AppSpacing.xxs),
                        Column(
                          children: [
                            Text(trailingLabel!, style: AppTextStyles.caption12.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                            const SizedBox(height: 0.5),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                titleController != null
                    ? TextField(
                        controller: titleController,
                        focusNode: titleFocusNode,
                        maxLines: 1,
                        maxLength: 50,
                        style: AppTextStyles.h3.copyWith(height: 1.5, color: Colors.white),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                          hintText: tr(LocaleKeys.meal_untitled),
                          hintStyle: AppTextStyles.h3.copyWith(height: 1.5, color: Colors.white.withValues(alpha: 0.4)),
                        ),
                      )
                    : GestureDetector(
                        onTap: onTitleTap,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h3.copyWith(height: 1.5, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: AppSpacing.xxs),
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

  const MatchBadge({super.key, required this.text, this.variant = MatchBadgeVariant.good});

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
      decoration: BoxDecoration(color: _background, borderRadius: BorderRadius.circular(AppRadii.pill)),
      alignment: Alignment.center,
      child: Text(text, style: AppTextStyles.badge14.copyWith(color: _textColor)),
    );
  }
}

class ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const ConfidenceBadge({super.key, required this.confidence});

  MatchBadgeVariant get _variant {
    if (confidence >= 0.75) return MatchBadgeVariant.good;
    if (confidence >= 0.50) return MatchBadgeVariant.medium;
    return MatchBadgeVariant.low;
  }

  String get _label => '${(confidence * 100).round()}% ${tr(LocaleKeys.common_confidence)}';

  @override
  Widget build(BuildContext context) {
    return MatchBadge(text: _label, variant: _variant);
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
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? maxLength;

  const CaloriesSummaryCard({super.key, required this.label, required this.value, this.delta, this.badge, this.margin, this.padding, this.height, this.controller, this.focusNode, this.maxLength});

  @override
  Widget build(BuildContext context) {
    final bool editable = controller != null;

    final Widget valueWidget = editable
        ? Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, if (maxLength != null) LengthLimitingTextInputFormatter(maxLength)],
              style: AppTextStyles.h1.copyWith(height: 1, color: AppColors.primary),
              decoration: InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero, counterText: '', hintText: '0', hintStyle: AppTextStyles.h1.copyWith(height: 1, color: AppColors.primary.withValues(alpha: 0.3))),
            ),
          )
        : Text(value, style: AppTextStyles.h1.copyWith(height: 1, color: AppColors.primary));

    final Widget valueRow = editable
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              valueWidget,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              valueWidget,
              if (delta != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  height: AppSizes.matchBadgeHeight,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadii.pill)),
                  alignment: Alignment.center,
                  child: Text(delta!, style: AppTextStyles.badge14.copyWith(color: AppColors.onPrimary)),
                ),
              ],
            ],
          );

    final card = Container(
      margin: margin,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.l), border: AppBorders.screenCard, boxShadow: AppShadows.screenCard),
      child: Stack(
        children: [
          if (badge != null) Positioned(right: 0, top: 0, child: badge!),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              valueRow,
            ],
          ),
        ],
      ),
    );
    if (focusNode == null) return card;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => focusNode!.requestFocus(), child: card);
  }
}

class MacroStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final double? height;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? maxLength;

  const MacroStatCard({super.key, required this.label, required this.value, required this.icon, required this.iconColor, this.height, this.controller, this.focusNode, this.maxLength});

  @override
  Widget build(BuildContext context) {
    final Widget valueWidget = controller != null
        ? SizedBox(
            height: AppSizes.iconMd,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, if (maxLength != null) LengthLimitingTextInputFormatter(maxLength)],
              style: AppTextStyles.title.copyWith(height: 1),
              decoration: InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero, counterText: '', hintText: '0', hintStyle: AppTextStyles.title.copyWith(height: 1, color: AppColors.textTertiary)),
            ),
          )
        : Text(value, style: AppTextStyles.title);

    final card = Container(
      width: double.infinity,
      height: height ?? (Platform.isAndroid ? AppSizes.macroCardSize + 10 : AppSizes.macroCardSize),
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.l), border: AppBorders.screenCard, boxShadow: AppShadows.screenCard),
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
                  style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(icon, size: AppSizes.iconMd, color: Colors.transparent),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: valueWidget),
            ],
          ),
        ],
      ),
    );
    if (focusNode == null) return card;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => focusNode!.requestFocus(), child: card);
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

  const MealRecordCard({super.key, required this.amount, required this.mealtime, required this.date, this.onAmountTap, this.onMealtimeTap, this.onDateTap, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
        border: AppBorders.screenCard,
        boxShadow: AppShadows.screenCard,
      ),
      child: Column(
        children: [
          _RecordRow(label: tr(LocaleKeys.ingredient_amount), value: amount, onTap: onAmountTap, showChevron: true),
          Divider(color: AppColors.separator, height: AppSpacing.m, thickness: AppSizes.dividerThin),
          _RecordRow(label: tr(LocaleKeys.meal_mealtime), value: mealtime, onTap: onMealtimeTap, showChevron: true),
          Divider(color: AppColors.separator, height: AppSpacing.m, thickness: AppSizes.dividerThin),
          _RecordRow(label: tr(LocaleKeys.meal_date), value: date, onTap: onDateTap, valueAsChip: true),
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

  const _RecordRow({required this.label, required this.value, this.showChevron = false, this.valueAsChip = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final trailing = valueAsChip
        ? Container(
            height: AppSizes.dateChipHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadii.s)),
            alignment: Alignment.center,
            child: Text(value, style: AppTextStyles.body16.copyWith(letterSpacing: -0.3125)),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppTextStyles.body16.copyWith(letterSpacing: -0.3125)),
              if (showChevron) ...[const SizedBox(width: AppSpacing.xs), Icon(CupertinoIcons.chevron_down, size: AppSizes.iconSm, color: AppColors.textSecondary)],
            ],
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.s),
      child: SizedBox(
        height: AppSizes.editFormRowHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body16.copyWith(letterSpacing: -0.3125)),
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
  final VoidCallback? onFavorite;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAdd;

  const IngredientRow({super.key, required this.ingredient, this.highlighted = false, this.alertText, this.onTap, this.onFavorite, this.onEdit, this.onDelete, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final background = highlighted ? AppColors.warningSurface : AppColors.surface;
    final border = highlighted ? Border.all(color: AppColors.warningStrong, width: 1) : AppBorders.screenCard;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.l),
      child: Container(
        height: (highlighted ? AppSizes.ingredientRowAlertHeight : AppSizes.ingredientRowHeight) + (Platform.isAndroid ? 4 : 0),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.l),
          border: border,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (highlighted) ...[const Icon(CupertinoIcons.exclamationmark_triangle, size: AppSizes.iconSm, color: AppColors.warningStrong), const SizedBox(width: AppSpacing.xs)],
                      Flexible(
                        child: Text(
                          ingredient.name,
                          style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  _MacroDotsRowWithCalories(ingredient: ingredient),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            if (onAdd != null)
              AnimatedAddButton(itemKey: ingredient.name, onAdd: onAdd!)
            else
              _IngredientPopupButton(onFavorite: onFavorite, onEdit: onEdit, onDelete: onDelete, isFavorite: ingredient.isFavorite),
          ],
        ),
      ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: AppSizes.macroDot,
          height: AppSizes.macroDot,
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppOpacities.soft),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          value,
          style: AppTextStyles.body13.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _MacroDotsRowWithCalories extends StatelessWidget {
  final Ingredient ingredient;

  const _MacroDotsRowWithCalories({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final showAmount = (ingredient.amount - 1.0).abs() > 0.001;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showAmount) ...[
          Text(
            ingredient.amountLabel,
            style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          _separator,
        ],
        Text(
          '${ingredient.weight.toStringAsFixed(0)}g',
          style: AppTextStyles.body13.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${ingredient.calories.toStringAsFixed(0)} ${tr(LocaleKeys.common_kcal)}',
          style: AppTextStyles.body13.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: AppSpacing.s),
        _MacroDotLabel(color: AppColors.macroProtein, value: '${ingredient.proteins.toStringAsFixed(0)}g'),
        const SizedBox(width: AppSpacing.s),
        _MacroDotLabel(color: AppColors.warningStrong, value: '${ingredient.carbs.toStringAsFixed(0)}g'),
        const SizedBox(width: AppSpacing.s),
        _MacroDotLabel(color: AppColors.macroFats, value: '${ingredient.fats.toStringAsFixed(0)}g'),
      ],
    );
  }

  static final Widget _separator = Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
    child: Text('·', style: AppTextStyles.label11.copyWith(color: AppColors.textTertiary)),
  );
}

class _IngredientPopupButton extends StatelessWidget {
  final VoidCallback? onFavorite;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isFavorite;

  const _IngredientPopupButton({this.onFavorite, this.onEdit, this.onDelete, this.isFavorite = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPopup(context),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(CupertinoIcons.ellipsis, size: AppSizes.iconMd, color: AppColors.textPrimary),
      ),
    );
  }

  void _showPopup(BuildContext context) {
    showGlassPopup(
      context: context,
      targetContext: context,
      targetOffset: const Offset(0, 8),
      items: [
        GlassPopupItem(
          label: tr(LocaleKeys.common_favorites),
          icon: isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          onTap: () {
            Navigator.of(context).pop();
            onFavorite?.call();
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.common_edit),
          icon: CupertinoIcons.pencil,
          onTap: () {
            Navigator.of(context).pop();
            onEdit?.call();
          },
        ),
        GlassPopupItem(
          label: tr(LocaleKeys.common_delete),
          icon: CupertinoIcons.trash,
          color: AppColors.error,
          showDividerAbove: true,
          onTap: () {
            Navigator.of(context).pop();
            onDelete?.call();
          },
        ),
      ],
    );
  }
}

class AllergyAlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final EdgeInsetsGeometry? margin;

  const AllergyAlertCard({super.key, required this.title, required this.subtitle, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: AppSizes.alertCardHeight,
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.s, AppSpacing.m, AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppRadii.l),
        border: Border.all(color: AppColors.warningStrong),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.exclamationmark_triangle, color: AppColors.warningStrong, size: AppSizes.iconMd),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
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

  const MeasurementChips({super.key, required this.options, required this.selectedIndex, this.onChanged});

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
                decoration: BoxDecoration(color: isSelected ? AppColors.primary : AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadii.pill)),
                alignment: Alignment.center,
                child: Text(
                  options[index],
                  style: AppTextStyles.body16.copyWith(letterSpacing: -0.3125, color: isSelected ? AppColors.onPrimary : AppColors.textPrimary, fontWeight: FontWeight.w500),
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
            borderRadius: BorderRadius.circular(AppRadii.m),
            borderSide: BorderSide(color: AppColors.surfaceMuted),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.m),
            borderSide: BorderSide(color: AppColors.primary),
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
      borderRadius: BorderRadius.circular(AppRadii.l),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.m),
          decoration: BoxDecoration(color: AppColors.glassSheet, borderRadius: BorderRadius.circular(AppRadii.l)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: item == items.last ? 0 : AppSpacing.s),
                    child: InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.circular(AppRadii.s),
                      child: SizedBox(
                        height: AppSizes.actionRowHeight,
                        child: Row(
                          children: [
                            Icon(item.icon, color: item.color ?? AppColors.textPrimary, size: AppSizes.iconMd),
                            const SizedBox(width: AppSpacing.s),
                            Expanded(
                              child: Text(
                                item.label,
                                style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, height: 1.75, color: item.color ?? AppColors.textPrimary, letterSpacing: -0.4492),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
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

  const GlassActionSheetItem({required this.label, required this.icon, this.color, this.onTap});
}

class SyncCard extends StatelessWidget {
  final String title;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  const SyncCard({super.key, required this.title, required this.primaryLabel, required this.secondaryLabel, this.onPrimary, this.onSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.xl), border: AppBorders.screenCard, boxShadow: AppShadows.screenCard),
      child: Column(
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.arrow_2_circlepath, size: AppSizes.iconMd, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(title, style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: AppSizes.buttonHeightXxs,
                child: FoodyPrimaryButton(label: primaryLabel, gradient: AppGradients.primary, height: AppSizes.buttonHeightXxs, onTap: onPrimary),
              ),
              const SizedBox(width: AppSpacing.s),
              InkWell(
                onTap: onSecondary,
                child: Text(
                  secondaryLabel,
                  style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
