import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/glass_toggle_row.dart';
import 'package:diplomka/widgets/liquid_glass/glass_segmented_tabs.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  int _themeIndexFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 0;
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
    }
  }

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
          Text(tr(LocaleKeys.preferences_appearance), style: AppTextStyles.body15),
          const SizedBox(height: AppSpacing.xs),
          Text(tr(LocaleKeys.preferences_appearance_hint), style: AppTextStyles.body13),
          const SizedBox(height: AppSpacing.m),
          Obx(
            () => GlassSegmentedTabs(
              labels: [tr(LocaleKeys.preferences_system), tr(LocaleKeys.preferences_light), tr(LocaleKeys.preferences_dark)],
              activeIndex: _themeIndexFromMode(SessionManager.to.themeModeIndex.value),
              onTap: (index) {
                final mode = [ThemeMode.system, ThemeMode.light, ThemeMode.dark][index];
                SessionManager.to.setThemeMode(mode);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ProfileCard(
            radius: AppRadii.l,
            shadow: AppShadows.screenCard,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
            child: Column(
              children: [
                // TODO: Live Activity — requires paid Apple Developer account + ActivityKit implementation (see plan: live-activity-ios-lock-screen-dynamic-island.md)
                // GlassToggleRow(title: tr(LocaleKeys.preferences_live_activity), subtitle: tr(LocaleKeys.preferences_live_activity_desc), isOn: false),
                Obx(
                  () => GlassToggleRow(
                    title: tr(LocaleKeys.preferences_burned_calories),
                    subtitle: tr(LocaleKeys.preferences_burned_calories_desc),
                    isOn: SessionManager.to.burnedCaloriesEnabled.value,
                    onChanged: (val) => SessionManager.to.setBurnedCaloriesEnabled(val),
                  ),
                ),
                Obx(
                  () => GlassToggleRow(
                    title: tr(LocaleKeys.preferences_rollover_calories),
                    subtitle: tr(LocaleKeys.preferences_rollover_calories_desc),
                    isOn: SessionManager.to.rolloverCaloriesEnabled.value,
                    onChanged: (val) => SessionManager.to.setRolloverCaloriesEnabled(val),
                  ),
                ),
                Obx(
                  () => GlassToggleRow(
                    title: tr(LocaleKeys.preferences_auto_adjust),
                    subtitle: tr(LocaleKeys.preferences_auto_adjust_desc),
                    isOn: SessionManager.to.autoAdjustMacrosEnabled.value,
                    onChanged: (val) => SessionManager.to.setAutoAdjustMacrosEnabled(val),
                  ),
                ),
                Obx(
                  () => GlassToggleRow(
                    title: tr(LocaleKeys.preferences_save_photos_gallery),
                    subtitle: tr(LocaleKeys.preferences_save_photos_gallery_desc),
                    isOn: SessionManager.to.savePhotosToGallery.value,
                    onChanged: (val) => SessionManager.to.setSavePhotosToGallery(val),
                    showDivider: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
