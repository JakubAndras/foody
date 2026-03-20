import 'package:diplomka/model/language_settings.dart';
import 'package:diplomka/services/language_settings_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSettingsController extends GetxController {
  LanguageSettingsController({
    required this.languageSettingsService,
  });

  static LanguageSettingsController get to => Get.find();

  final LanguageSettingsService languageSettingsService;

  final Rx<AppLanguage> appLanguage = AppLanguage.english.obs;
  final Rx<VoiceLogLanguagePreference> voiceLogLanguagePreference = VoiceLogLanguagePreference.followApp.obs;

  void initializeFromContext(BuildContext context) {
    final currentLanguage = AppLanguageX.fromLanguageCode(context.locale.languageCode);
    appLanguage.value = currentLanguage;
    voiceLogLanguagePreference.value = languageSettingsService.voiceLogLanguagePreference.value;
  }

  void setAppLanguage(AppLanguage language) {
    if (appLanguage.value == language) return;
    appLanguage.value = language;
  }

  Future<void> setVoiceLogLanguagePreference(VoiceLogLanguagePreference preference) async {
    if (voiceLogLanguagePreference.value == preference) return;
    voiceLogLanguagePreference.value = preference;
    await languageSettingsService.setVoiceLogLanguagePreference(preference);
  }

  AppLanguage get effectiveVoiceLogLanguage {
    final preference = voiceLogLanguagePreference.value;
    switch (preference) {
      case VoiceLogLanguagePreference.followApp:
        return appLanguage.value;
      case VoiceLogLanguagePreference.english:
        return AppLanguage.english;
      case VoiceLogLanguagePreference.czech:
        return AppLanguage.czech;
    }
  }
}
