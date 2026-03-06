import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Pure content widget — just the tab items row. No glass, no layout.
class BottomNavBarContent extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBarContent({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.glassBorder, width: AppSizes.glassBorderWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        child: Row(
          children: [
            _buildNavItem(icon: Icons.home_rounded, label: tr(LocaleKeys.nav_home), index: 0),
            const SizedBox(width: AppSpacing.s),
            _buildNavItem(icon: Icons.bar_chart_rounded, label: tr(LocaleKeys.nav_progress), index: 1),
            const SizedBox(width: AppSpacing.s),
            _buildNavItem(icon: Icons.person_outline_rounded, label: tr(LocaleKeys.nav_profile), index: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final bool isSelected = currentIndex == index;
    final Color iconColor = isSelected ? AppColors.textPrimary : AppColors.textTertiary;
    final Color textColor = isSelected ? AppColors.textPrimary : AppColors.textTertiary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(AppRadii.lg2),
          child: Container(
            height: AppSizes.navItemHeight,
            decoration: BoxDecoration(color: isSelected ? AppColors.black.withValues(alpha: 0.15) : Colors.transparent, borderRadius: BorderRadius.circular(AppRadii.lg2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: AppSizes.iconTabBar, color: iconColor),
                Text(
                  label,
                  style: AppTextStyles.label11.copyWith(color: textColor, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The FAB / add button content. No glass, no layout.
class BottomNavActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const BottomNavActionButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.glassBorder, width: AppSizes.glassBorderWidth),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Center(
          child: SizedBox(
            width: AppSizes.fabSize - AppSpacing.xxl,
            height: AppSizes.fabSize - AppSpacing.xxl,
            child: const Icon(Icons.add, color: AppColors.primary, size: AppSizes.fabIconSize),
          ),
        ),
      ),
    );
  }
}
