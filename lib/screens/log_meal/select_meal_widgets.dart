import 'dart:ui';

import 'package:diplomka/app_theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SelectMealSearchBar extends StatelessWidget {
  const SelectMealSearchBar({super.key, required this.controller, required this.onChanged, required this.onClear, this.focusNode});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;
    return Container(
      height: AppSizes.searchBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(color: AppColors.surfaceSearch, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary, size: AppSizes.iconMd),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: tr(LocaleKeys.meal_search_food),
                hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w400, color: AppColors.textPrimary),
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
  const SelectMealSegmentedTabs({super.key, required this.labels, required this.activeIndex, required this.onTap});

  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GlassTabBar(
      tabs: labels.map((l) => GlassTab(label: l)).toList(),
      selectedIndex: activeIndex,
      onTabSelected: onTap,
    );
  }
}

class SelectMealQuickActionTile extends StatelessWidget {
  const SelectMealQuickActionTile({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.selectMealActionTileHeight,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.md), boxShadow: AppShadows.cardSmall),
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
  const SelectMealSectionHeader({super.key, required this.title, this.trailing});

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
  const SelectMealMacroDot({super.key, required this.color, required this.label});

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
    this.onAdd,
  });

  final String title;
  final String kcal;
  final String protein;
  final String carbs;
  final String fats;
  final ImageProvider? imageProvider;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.selectMealCardHeight,
        padding: const EdgeInsets.only(right: AppSpacing.m),
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
                image: imageProvider != null ? DecorationImage(image: imageProvider!, fit: BoxFit.cover) : null,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
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
                      const SizedBox(width: AppSpacing.s),
                      SelectMealMacroDot(color: AppColors.macroCarbs, label: carbs),
                      const SizedBox(width: AppSpacing.s),
                      SelectMealMacroDot(color: AppColors.macroFats, label: fats),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: AppColors.onPrimary, size: AppSizes.iconMd),
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
        padding: const EdgeInsets.only(right: AppSpacing.m),
        child: Row(
          children: [
            Container(
              width: AppSizes.selectMealCardImageSize,
              height: AppSizes.selectMealCardImageSize,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadii.md),
                image: imageProvider != null ? DecorationImage(image: imageProvider!, fit: BoxFit.cover) : null,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
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
            const SizedBox(width: AppSpacing.s),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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
  const SelectMealIngredientRow({super.key, required this.title, required this.subtitle, required this.onAdd, this.onTap});

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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.md), boxShadow: AppShadows.cardSmall),
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
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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
  const SelectMealEmptyState({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, color: AppColors.textTertiary, size: AppSizes.emptyStateIconSize),
            const SizedBox(height: AppSpacing.m),
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
      child: SizedBox(height: 40, width: 40, child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary)),
    );
  }
}

class SelectMealErrorState extends StatelessWidget {
  const SelectMealErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: AppSizes.emptyStateIconSize),
            const SizedBox(height: AppSpacing.m),
            Text(tr(LocaleKeys.common_something_went_wrong), style: AppTextStyles.title18Tight, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            TextButton(
              onPressed: onRetry,
              child: Text(tr(LocaleKeys.common_try_again), style: AppTextStyles.body14.copyWith(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectMealPickerSheet extends StatelessWidget {
  const SelectMealPickerSheet({super.key, required this.title, required this.options, required this.selectedIndex, required this.onSelected});

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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.m),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.lg)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(title, style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary)),
                ),
                const SizedBox(height: AppSpacing.s),
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
                          child: isSelected ? const Icon(Icons.check, color: AppColors.primary, size: AppSizes.iconMd) : const SizedBox.shrink(),
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

class SelectMealSuggestionTile extends StatelessWidget {
  const SelectMealSuggestionTile({super.key, required this.name, required this.frequency, required this.onTap});

  final String name;
  final int frequency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.history, color: AppColors.textTertiary, size: AppSizes.iconSm),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(name, style: AppTextStyles.body14, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Text('${frequency}x', style: AppTextStyles.body14Regular.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}
