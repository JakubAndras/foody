import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:diplomka/app_theme.dart';

class GlassSegmentedTabs extends StatelessWidget {
  const GlassSegmentedTabs({super.key, required this.labels, required this.activeIndex, required this.onTap, this.embedded = false});

  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onTap;
  /// When true, uses colors suited for embedding inside a card (e.g. Progress screen).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    const double tabHeight = 36;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassTabBar(
      tabs: labels.map((l) => GlassTab(label: l)).toList(),
      selectedIndex: activeIndex,
      onTabSelected: onTap,
      height: tabHeight,
      borderRadius: BorderRadius.circular(tabHeight / 2),
      indicatorBorderRadius: BorderRadius.circular(tabHeight / 2),
      labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      selectedLabelStyle: AppTextStyles.body13.copyWith(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500, height: 1.0),
      unselectedLabelStyle: AppTextStyles.body13.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w500, height: 1.0),
      indicatorColor: isDark ? (embedded ? const Color(0xFF2C2C2E) : const Color(0xFF3A3A3C)) : AppColors.background,
      backgroundColor: isDark ? (embedded ? Colors.transparent : const Color(0xFF1C1C1E)) : Colors.white,
      useOwnLayer: true,
      settings: isDark ? const LiquidGlassSettings(thickness: 0, blur: 0, glassColor: Colors.transparent, lightIntensity: 0) : AppGlass.standard,
      indicatorSettings: isDark
          ? const LiquidGlassSettings(thickness: 0, blur: 0, glassColor: Colors.transparent, lightIntensity: 0)
          : const LiquidGlassSettings(thickness: 10, blur: 0, glassColor: Colors.white, lightIntensity: 0.5),
    );
  }
}
