import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAdd,
  });

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;
    final Color iconColor = isSelected ? AppColors.textPrimary : AppColors.textTertiary;
    final Color textColor = isSelected ? AppColors.textPrimary : AppColors.textTertiary;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(AppRadii.lg2),
        child: Container(
          height: AppSizes.navItemHeight,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceMuted : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.lg2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.iconMd, color: iconColor),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                style: AppTextStyles.label10.copyWith(color: textColor, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: AppSizes.fabSize,
        height: AppSizes.fabSize,
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          shape: BoxShape.circle,
          boxShadow: AppShadows.fab,
        ),
        child: const Icon(Icons.add, color: AppColors.onPrimary, size: AppSizes.fabIconSize),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: AppSizes.bottomNavHeight,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: AppShadows.navBar,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
                    const SizedBox(width: AppSpacing.sm),
                    _buildNavItem(icon: Icons.bar_chart_rounded, label: 'Progress', index: 1),
                    const SizedBox(width: AppSpacing.sm),
                    _buildNavItem(icon: Icons.person_outline_rounded, label: 'Profile', index: 2),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildAddButton(),
        ],
      ),
    );
  }
}
