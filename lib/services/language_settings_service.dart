import 'package:diplomka/model/language_settings.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String voiceLogLanguagePreferenceKey = 'voiceLogLanguagePreferenceKey';

class LanguageSettingsService {
  LanguageSettingsService(this._ref);

  final Ref _ref;

  Future<VoiceLogLanguagePreference> load() async {
    final storedCode = await _ref.read(sharedPreferencesServiceProvider).getString(key: voiceLogLanguagePreferenceKey);
    return VoiceLogLanguagePreferenceX.fromCode(storedCode);
  }

  Future<void> setVoiceLogLanguagePreference(VoiceLogLanguagePreference preference) async {
    await _ref.read(sharedPreferencesServiceProvider).setString(
          key: voiceLogLanguagePreferenceKey,
          value: preference.code,
        );
  }

  String resolveVoiceLogLanguageCode({
    required String appLanguageCode,
    required VoiceLogLanguagePreference preference,
  }) {
    final appLanguage = AppLanguageX.fromLanguageCode(appLanguageCode);

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

final languageSettingsServiceProvider = Provider<LanguageSettingsService>((ref) => LanguageSettingsService(ref));
