import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:diplomka/app_theme.dart';

class GlassSegmentedTabs extends StatelessWidget {
  const GlassSegmentedTabs({super.key, required this.labels, required this.activeIndex, required this.onTap});

  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const double tabHeight = 36;
    return GlassTabBar(
      tabs: labels.map((l) => GlassTab(label: l)).toList(),
      selectedIndex: activeIndex,
      onTabSelected: onTap,
      height: tabHeight,
      borderRadius: BorderRadius.circular(tabHeight / 2),
      indicatorBorderRadius: BorderRadius.circular(tabHeight / 2),
      labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      selectedLabelStyle: AppTextStyles.body13.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500, height: 1.0),
      unselectedLabelStyle: AppTextStyles.body13.copyWith(color: AppColors.grey4, fontWeight: FontWeight.w500, height: 1.0),
      indicatorColor: AppColors.background,
      backgroundColor: Colors.white,
      useOwnLayer: true,
      settings: AppGlass.standard,
      indicatorSettings: const LiquidGlassSettings(thickness: 10, blur: 0, glassColor: Colors.white, lightIntensity: 0.5),
    );
  }
}
