import 'dart:math' as math;

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/widgets/liquid_glass/liquid_glass_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

class BottomNavBar extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  const BottomNavBar({super.key, required this.body, required this.currentIndex, required this.onTap, required this.onAdd});

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
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surfaceMuted.withValues(alpha: 0.7) : Colors.transparent,
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
      ),
    );
  }

  Widget _buildTabBarContent() {
    return Padding(
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
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAdd,
        customBorder: const CircleBorder(),
        child: Center(
          child: Container(
            width: AppSizes.fabSize - AppSpacing.xxl,
            height: AppSizes.fabSize - AppSpacing.xxl,
            //decoration: BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle, boxShadow: AppShadows.fab),
            child: const Icon(Icons.add, color: AppColors.primary, size: AppSizes.fabIconSize),
          ),
        ),
      ),
    );
  }

  double _computeNavWidth(double availableWidth, double horizontalMargin) {
    final double maxSurfaceWidth = math.max(0.0, availableWidth - (horizontalMargin * 2));
    final double widthWithAction = maxSurfaceWidth - AppSizes.fabSize - AppSpacing.s;
    return widthWithAction >= 180 ? widthWithAction : maxSurfaceWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double sideMargin = AppSpacing.m;
        final double navWidth = _computeNavWidth(constraints.maxWidth, sideMargin);
        final double safeBottom = MediaQuery.paddingOf(context).bottom;
        final double navTop = math.max(0.0, constraints.maxHeight - safeBottom - AppSizes.bottomNavHeight);
        final double actionLeft = math.max(AppSpacing.m, constraints.maxWidth - sideMargin - AppSizes.fabSize);

        return AppLiquidGlassLayer(
          backgroundWidget: body,
          children: [
            AppLiquidGlassPresets.mainTabBarLens.build(
              width: navWidth,
              height: AppSizes.bottomNavHeight,
              position: LiquidGlassOffsetPosition(left: sideMargin, top: navTop),
              child: _buildTabBarContent(),
            ),
            AppLiquidGlassPresets.mainTabActionLens.build(
              width: AppSizes.fabSize,
              height: AppSizes.fabSize,
              position: LiquidGlassOffsetPosition(left: actionLeft, top: navTop),
              child: _buildAddButton(),
            ),
          ],
        );
      },
    );
  }
}
