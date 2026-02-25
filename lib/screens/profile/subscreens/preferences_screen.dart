import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/screens/profile/subscreens/language_screen.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: 'Preferences', onBack: () => Get.back()),
          const SizedBox(height: AppSpacing.m),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.m, AppSpacing.screen, AppSpacing.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Appearance', style: AppTextStyles.body15),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Choose light, dark, or system appearance',
                  style: AppTextStyles.body13,
                ),
                SizedBox(height: AppSpacing.m),
                _AppearanceSegmented(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
            child: Column(
              children: const [
                _ToggleRow(
                  title: 'Live activity',
                  subtitle: 'Show your daily calories and macros on your lock screen and dynamic island',
                  isOn: false,
                ),
                _ToggleRow(
                  title: 'Add burned calories',
                  subtitle: 'Add burned calories back to daily goal',
                  isOn: true,
                ),
                _ToggleRow(
                  title: 'Rollover calories',
                  subtitle: "Add up to 500 left over calories from yesterday into today's daily goal",
                  isOn: false,
                ),
                _ToggleRow(
                  title: 'Auto adjust macros',
                  subtitle: 'When editing calories or macronutrients, automatically adjust the other values proportionally',
                  isOn: true,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSegmented extends StatelessWidget {
  const _AppearanceSegmented();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.control,
      ),
      child: Row(
        children: const [
          _SegmentItem(label: 'System', icon: Icons.computer, isActive: false),
          SizedBox(width: AppSpacing.s),
          _SegmentItem(label: 'Light', icon: Icons.light_mode, isActive: true),
          SizedBox(width: AppSpacing.s),
          _SegmentItem(label: 'Dark', icon: Icons.dark_mode, isActive: false),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({required this.label, required this.icon, required this.isActive});

  final String label;
  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = AppTextStyles.body13.copyWith(
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
      color: isActive ? AppColors.onPrimary : AppColors.textSecondaryAlt,
    );

    return Expanded(
      child: Container(
        height: AppSizes.segmentedHeight,
        decoration: BoxDecoration(
          gradient: isActive ? AppGradients.primary : null,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          color: isActive ? null : Colors.transparent,
          boxShadow: isActive ? AppShadows.control : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSizes.iconXs, color: isActive ? AppColors.onPrimary : AppColors.textSecondaryAlt),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: labelStyle),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.isOn,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final bool isOn;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(subtitle, style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              ProfileToggle(isOn: isOn),
            ],
          ),
        ),
        if (showDivider) Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
      ],
    );
  }
}
