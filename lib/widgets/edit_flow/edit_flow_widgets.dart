import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ingredient.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class InlineErrorText extends StatelessWidget {
  final String message;

  const InlineErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(message, style: AppTextStyles.body14Regular.copyWith(color: AppColors.errorText)),
    );
  }
}

class EditBottomActionBar extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final IconData? secondaryIcon;
  final VoidCallback? onSecondary;
  final EdgeInsetsGeometry? padding;

  const EditBottomActionBar({super.key, required this.primaryLabel, this.onPrimary, this.secondaryLabel, this.secondaryIcon, this.onSecondary, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.s, AppSpacing.m, AppSpacing.m),
      child: Row(
        children: [
          if (secondaryLabel != null) ...[
            Expanded(
              child: FoodySecondaryButton(label: secondaryLabel!, icon: secondaryIcon, onTap: onSecondary),
            ),
            const SizedBox(width: AppSpacing.s),
          ],
          Expanded(
            child: FoodyPrimaryButton(label: primaryLabel, gradient: AppGradients.primary, onTap: onPrimary),
          ),
        ],
      ),
    );
  }
}

class EditConfirmSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const EditConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.confirmColor = AppColors.error,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.lg), boxShadow: AppShadows.sheet),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title18.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(
                child: FoodySecondaryButton(label: cancelLabel, onTap: onCancel),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: FoodyPrimaryButton(
                  label: confirmLabel,
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [confirmColor, confirmColor.withValues(alpha: 0.85)]),
                  onTap: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditIngredientRow extends StatelessWidget {
  final Ingredient ingredient;
  final bool highlighted;
  final String? alertText;
  final VoidCallback? onTap;

  const EditIngredientRow({super.key, required this.ingredient, this.highlighted = false, this.alertText, this.onTap});

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
          border: Border.all(color: border, width: AppSizes.dividerThin),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (highlighted) ...[const Icon(Icons.warning_amber_rounded, size: AppSizes.iconSm, color: AppColors.warningStrong), const SizedBox(width: AppSpacing.xs)],
                      Text(
                        ingredient.name,
                        style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  if (alertText != null) ...[const SizedBox(height: AppSpacing.xxs), Text(alertText!, style: AppTextStyles.label11.copyWith(fontWeight: FontWeight.w500, color: AppColors.orange, letterSpacing: 0.0645))],
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
                Text(ingredient.calories.toStringAsFixed(0), style: AppTextStyles.title),
                Text(tr(LocaleKeys.common_kcal), style: AppTextStyles.caption12.copyWith(color: AppColors.textTertiary)),
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
        _MacroDotLabel(color: AppColors.warningStrong, value: '${ingredient.carbs.toStringAsFixed(0)}g'),
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
            color: color.withValues(alpha: AppOpacities.soft),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(value, style: AppTextStyles.label11.copyWith(fontWeight: FontWeight.w500, color: AppColors.textTertiary, letterSpacing: 0.0645)),
      ],
    );
  }
}
