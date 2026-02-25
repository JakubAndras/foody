import 'package:diplomka/model/language_settings.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:get/get.dart';

const String voiceLogLanguagePreferenceKey = 'voiceLogLanguagePreferenceKey';

class LanguageSettingsService extends GetxService {
  static LanguageSettingsService get to => Get.find();

  final Rx<VoiceLogLanguagePreference> voiceLogLanguagePreference = VoiceLogLanguagePreference.followApp.obs;

  Future<void> load() async {
    final storedCode = await SharedPreferencesService.to.getString(key: voiceLogLanguagePreferenceKey);
    voiceLogLanguagePreference.value = VoiceLogLanguagePreferenceX.fromCode(storedCode);
  }

  Future<void> setVoiceLogLanguagePreference(VoiceLogLanguagePreference preference) async {
    voiceLogLanguagePreference.value = preference;
    await SharedPreferencesService.to.setString(
      key: voiceLogLanguagePreferenceKey,
      value: preference.code,
    );
  }

  String resolveVoiceLogLanguageCode({required String appLanguageCode}) {
    final appLanguage = AppLanguageX.fromLanguageCode(appLanguageCode);
    final preference = voiceLogLanguagePreference.value;

    switch (preference) {
      case VoiceLogLanguagePreference.english:
        return AppLanguage.english.code;
      case VoiceLogLanguagePreference.czech:
        return AppLanguage.czech.code;
      case VoiceLogLanguagePreference.followApp:
        return appLanguage.code;
    }
  }
}
