import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/language_settings_controller.dart';
import 'package:diplomka/model/language_settings.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LanguageSettingsController.to;
    controller.initializeFromContext(context);

    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      child: Obx(() {
        final appLanguage = controller.appLanguage.value;
        final voicePreference = controller.voiceLogLanguagePreference.value;
        final effectiveVoiceLanguage = controller.effectiveVoiceLogLanguage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileTopBar(title: easy.tr('language_settings.title'), onBack: () => Get.back()),
            // const SizedBox(height: AppSpacing.m),
            // ProfileCard(
            //   radius: AppRadii.lg,
            //   shadow: AppShadows.cardSubtle,
            //   padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.m, AppSpacing.screen, AppSpacing.s),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         easy.tr('language_settings.app_language_title'),
            //         style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600),
            //       ),
            //       const SizedBox(height: AppSpacing.xs),
            //       Text(
            //         easy.tr('language_settings.app_language_subtitle'),
            //         style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
            //       ),
            //       const SizedBox(height: AppSpacing.s),
            //       _SelectionRow(
            //         label: easy.tr('language_settings.option_english'),
            //         selected: appLanguage == AppLanguage.english,
            //         onTap: () => controller.setAppLanguage(context, AppLanguage.english),
            //       ),
            //       _SelectionRow(
            //         label: easy.tr('language_settings.option_czech'),
            //         selected: appLanguage == AppLanguage.czech,
            //         onTap: () => controller.setAppLanguage(context, AppLanguage.czech),
            //         showDivider: false,
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: AppSpacing.m),
            ProfileCard(
              radius: AppRadii.lg,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.m, AppSpacing.screen, AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    easy.tr('language_settings.voice_language_title'),
                    style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    easy.tr('language_settings.voice_language_subtitle'),
                    style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  // _SelectionRow(
                  //   label: easy.tr('language_settings.option_follow_app'),
                  //   selected: voicePreference == VoiceLogLanguagePreference.followApp,
                  //   onTap: () => controller.setVoiceLogLanguagePreference(VoiceLogLanguagePreference.followApp),
                  // ),
                  _SelectionRow(
                    label: easy.tr('language_settings.option_english'),
                    selected: voicePreference == VoiceLogLanguagePreference.english,
                    onTap: () => controller.setVoiceLogLanguagePreference(VoiceLogLanguagePreference.english),
                  ),
                  _SelectionRow(
                    label: easy.tr('language_settings.option_czech'),
                    selected: voicePreference == VoiceLogLanguagePreference.czech,
                    onTap: () => controller.setVoiceLogLanguagePreference(VoiceLogLanguagePreference.czech),
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  String _labelForAppLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return easy.tr('language_settings.option_english');
      case AppLanguage.czech:
        return easy.tr('language_settings.option_czech');
    }
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.showDivider = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: SizedBox(
              height: AppSizes.listRowHeight,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selected ? AppColors.primary : AppColors.textTertiary,
                    size: AppSizes.iconMd,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
      ],
    );
  }
}
