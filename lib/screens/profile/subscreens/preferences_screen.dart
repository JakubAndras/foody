import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
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
          ProfileTopBar(title: tr(LocaleKeys.preferences_title), onBack: () => Get.back()),
          const SizedBox(height: AppSpacing.m),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.m, AppSpacing.screen, AppSpacing.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(LocaleKeys.preferences_appearance), style: AppTextStyles.body15),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  tr(LocaleKeys.preferences_appearance_hint),
                  style: AppTextStyles.body13,
                ),
                const SizedBox(height: AppSpacing.m),
                const _AppearanceSegmented(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
            child: Column(
              children: [
                _ToggleRow(
                  title: tr(LocaleKeys.preferences_live_activity),
                  subtitle: tr(LocaleKeys.preferences_live_activity_desc),
                  isOn: false,
                ),
                _ToggleRow(
                  title: tr(LocaleKeys.preferences_burned_calories),
                  subtitle: tr(LocaleKeys.preferences_burned_calories_desc),
                  isOn: true,
                ),
                _ToggleRow(
                  title: tr(LocaleKeys.preferences_rollover_calories),
                  subtitle: tr(LocaleKeys.preferences_rollover_calories_desc),
                  isOn: false,
                ),
                _ToggleRow(
                  title: tr(LocaleKeys.preferences_auto_adjust),
                  subtitle: tr(LocaleKeys.preferences_auto_adjust_desc),
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
        children: [
          _SegmentItem(label: tr(LocaleKeys.preferences_system), icon: Icons.computer, isActive: false),
          const SizedBox(width: AppSpacing.s),
          _SegmentItem(label: tr(LocaleKeys.preferences_light), icon: Icons.light_mode, isActive: true),
          const SizedBox(width: AppSpacing.s),
          _SegmentItem(label: tr(LocaleKeys.preferences_dark), icon: Icons.dark_mode, isActive: false),
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
