import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/session_manager.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
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
                Text(tr(LocaleKeys.preferences_appearance_hint), style: AppTextStyles.body13),
                const SizedBox(height: AppSpacing.m),
                _AppearanceSegmented(
                  labels: [tr(LocaleKeys.preferences_system), tr(LocaleKeys.preferences_light), tr(LocaleKeys.preferences_dark)],
                  selectedIndex: 1,
                  onChanged: (_) {},
                ),
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
                _ToggleRow(title: tr(LocaleKeys.preferences_live_activity), subtitle: tr(LocaleKeys.preferences_live_activity_desc), isOn: false),
                _ToggleRow(title: tr(LocaleKeys.preferences_burned_calories), subtitle: tr(LocaleKeys.preferences_burned_calories_desc), isOn: true),
                _ToggleRow(title: tr(LocaleKeys.preferences_rollover_calories), subtitle: tr(LocaleKeys.preferences_rollover_calories_desc), isOn: false),
                _ToggleRow(title: tr(LocaleKeys.preferences_auto_adjust), subtitle: tr(LocaleKeys.preferences_auto_adjust_desc), isOn: true, showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
            child: Obx(
              () => _ToggleRow(
                title: tr(LocaleKeys.preferences_save_photos_gallery),
                subtitle: tr(LocaleKeys.preferences_save_photos_gallery_desc),
                isOn: SessionManager.to.savePhotosToGallery.value,
                onTap: () => SessionManager.to.setSavePhotosToGallery(!SessionManager.to.savePhotosToGallery.value),
                showDivider: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSegmented extends StatelessWidget {
  const _AppearanceSegmented({required this.labels, required this.selectedIndex, required this.onChanged});

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassSegmentedControl(segments: labels, selectedIndex: selectedIndex, onSegmentSelected: onChanged, useOwnLayer: true);
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.title, required this.subtitle, required this.isOn, this.onTap, this.showDivider = true});

  final String title;
  final String subtitle;
  final bool isOn;
  final VoidCallback? onTap;
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
              ProfileToggle(isOn: isOn, onTap: onTap),
            ],
          ),
        ),
        if (showDivider) Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
      ],
    );
  }
}
