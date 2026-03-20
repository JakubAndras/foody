import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/language_settings_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/language_settings.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late final LanguageSettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LanguageSettingsController.to;
  }

  Future<void> _changeAppLanguage(AppLanguage language) async {
    if (_controller.appLanguage.value == language) return;
    await context.setLocale(language.locale);
    _controller.setAppLanguage(language);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _controller.initializeFromContext(context);

    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      child: Obx(() {
        final appLanguage = _controller.appLanguage.value;
        final voicePreference = _controller.voiceLogLanguagePreference.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileTopBar(title: tr(LocaleKeys.language_settings_title), onBack: () => Get.back()),
            const SizedBox(height: AppSpacing.m),
            ProfileCard(
              radius: AppRadii.lg,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.m, AppSpacing.screen, AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(LocaleKeys.language_settings_app_language_title),
                    style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    tr(LocaleKeys.language_settings_app_language_subtitle),
                    style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _SelectionRow(
                    label: tr(LocaleKeys.language_settings_option_english),
                    selected: appLanguage == AppLanguage.english,
                    onTap: () => _changeAppLanguage(AppLanguage.english),
                  ),
                  _SelectionRow(
                    label: tr(LocaleKeys.language_settings_option_czech),
                    selected: appLanguage == AppLanguage.czech,
                    onTap: () => _changeAppLanguage(AppLanguage.czech),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            ProfileCard(
              radius: AppRadii.lg,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.m, AppSpacing.screen, AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(LocaleKeys.language_settings_voice_language_title),
                    style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    tr(LocaleKeys.language_settings_voice_language_subtitle),
                    style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  // _SelectionRow(
                  //   label: tr(LocaleKeys.language_settings_option_follow_app),
                  //   selected: voicePreference == VoiceLogLanguagePreference.followApp,
                  //   onTap: () => _controller.setVoiceLogLanguagePreference(VoiceLogLanguagePreference.followApp),
                  // ),
                  _SelectionRow(
                    label: tr(LocaleKeys.language_settings_option_english),
                    selected: voicePreference == VoiceLogLanguagePreference.english,
                    onTap: () => _controller.setVoiceLogLanguagePreference(VoiceLogLanguagePreference.english),
                  ),
                  _SelectionRow(
                    label: tr(LocaleKeys.language_settings_option_czech),
                    selected: voicePreference == VoiceLogLanguagePreference.czech,
                    onTap: () => _controller.setVoiceLogLanguagePreference(VoiceLogLanguagePreference.czech),
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
