import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:flutter/material.dart';

class SelectMealSearchBar extends StatelessWidget {
  const SelectMealSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;
    return Container(
      height: AppSizes.searchBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSearch,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary, size: AppSizes.iconMd),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Search Food',
                hintStyle: AppTextStyles.body16.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.body16.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (hasValue)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, color: AppColors.textSecondary, size: AppSizes.iconMd),
            ),
        ],
      ),
    );
  }
}

class SelectMealSegmentedTabs extends StatelessWidget {
  const SelectMealSegmentedTabs({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.selectMealSegmentHeight,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline, width: 1)),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = index == activeIndex;
          return Padding(
            padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : AppSpacing.lg),
            child: GestureDetector(
              onTap: () => onTap(index),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      labels[index],
                      style: AppTextStyles.selectMealSegmentLabel.copyWith(
                        color: isActive ? AppColors.primary : AppColors.textTertiary,
                      ),
                    ),
                    if (isActive)
                      Container(
                        height: AppSizes.selectMealSegmentIndicator,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
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

class SelectMealQuickActionTile extends StatelessWidget {
  const SelectMealQuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.selectMealActionTileHeight,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: AppShadows.cardSmall,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: AppSizes.iconLg),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: AppTextStyles.selectMealQuickActionLabel, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class SelectMealSectionHeader extends StatelessWidget {
  const SelectMealSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.selectMealSectionTitle),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class SelectMealMacroDot extends StatelessWidget {
  const SelectMealMacroDot({
    super.key,
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppOpacities.macroDot),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.selectMealMacro),
      ],
    );
  }
}

class SelectMealCard extends StatelessWidget {
  const SelectMealCard({
    super.key,
    required this.title,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.imageProvider,
    this.onTap,
  });

  final String title;
  final String kcal;
  final String protein;
  final String carbs;
  final String fats;
  final ImageProvider? imageProvider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.selectMealCardHeight,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppShadows.cardSubtle,
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.selectMealCardImageSize,
              height: AppSizes.selectMealCardImageSize,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadii.md),
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: AppTextStyles.selectMealMealTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SelectMealMacroDot(color: AppColors.macroProtein, label: protein),
                            const SizedBox(width: AppSpacing.sm),
                            SelectMealMacroDot(color: AppColors.macroCarbs, label: carbs),
                            const SizedBox(width: AppSpacing.sm),
                            SelectMealMacroDot(color: AppColors.macroFats, label: fats),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(kcal, style: AppTextStyles.selectMealKcalValue),
                      Text('kcal', style: AppTextStyles.selectMealKcalLabel),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectMealInlineMacroCard extends StatelessWidget {
  const SelectMealInlineMacroCard({
    super.key,
    required this.title,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.imageProvider,
    this.onAdd,
  });

  final String title;
  final String kcal;
  final String protein;
  final String carbs;
  final String fats;
  final ImageProvider? imageProvider;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.selectMealCardHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.cardSubtle,
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: AppSizes.selectMealCardImageSize,
              height: AppSizes.selectMealCardImageSize,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadii.md),
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.selectMealMealTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.selectMealIngredientSubtitle,
                      children: [
                        TextSpan(text: '$kcal cal, '),
                        TextSpan(
                          text: protein,
                          style: AppTextStyles.selectMealIngredientSubtitle.copyWith(
                            color: AppColors.macroProtein.withValues(alpha: AppOpacities.macroTextSoft),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(text: ', '),
                        TextSpan(
                          text: carbs,
                          style: AppTextStyles.selectMealIngredientSubtitle.copyWith(
                            color: AppColors.macroCarbs.withValues(alpha: AppOpacities.macroTextStrong),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(text: ', '),
                        TextSpan(
                          text: fats,
                          style: AppTextStyles.selectMealIngredientSubtitle.copyWith(
                            color: AppColors.macroFats.withValues(alpha: AppOpacities.macroTextStrong),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.onPrimary, size: AppSizes.iconMd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectMealIngredientRow extends StatelessWidget {
  const SelectMealIngredientRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onAdd,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.selectMealIngredientRowHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: AppShadows.cardSmall,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.selectMealIngredientTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.selectMealIngredientSubtitle),
                ],
              ),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.onPrimary, size: AppSizes.iconMd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectMealEmptyState extends StatelessWidget {
  const SelectMealEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, color: AppColors.textTertiary, size: AppSizes.emptyStateIconSize),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTextStyles.title18Tight, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SelectMealLoadingState extends StatelessWidget {
  const SelectMealLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class SelectMealErrorState extends StatelessWidget {
  const SelectMealErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: AppSizes.emptyStateIconSize),
            const SizedBox(height: AppSpacing.md),
            Text('Something went wrong', style: AppTextStyles.title18Tight, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again', style: AppTextStyles.body14.copyWith(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectMealPickerSheet extends StatelessWidget {
  const SelectMealPickerSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(title, style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary)),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              ...List.generate(options.length, (index) {
                final isSelected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: InkWell(
                    onTap: () => onSelected(index),
                    child: Row(
                      children: [
                        SizedBox(
                          width: AppSizes.iconLg,
                          height: AppSizes.iconLg,
                          child: isSelected
                              ? const Icon(Icons.check, color: AppColors.primary, size: AppSizes.iconMd)
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(options[index], style: AppTextStyles.selectMealPickerItem),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
