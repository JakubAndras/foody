import 'package:diplomka/model/language_settings.dart';
import 'package:diplomka/services/language_settings_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable stav nastavení jazyka.
class LanguageSettingsState {
  const LanguageSettingsState({this.appLanguage = AppLanguage.english, this.voiceLogLanguagePreference = VoiceLogLanguagePreference.followApp});

  final AppLanguage appLanguage;
  final VoiceLogLanguagePreference voiceLogLanguagePreference;

  AppLanguage get effectiveVoiceLogLanguage {
    switch (voiceLogLanguagePreference) {
      case VoiceLogLanguagePreference.followApp:
        return appLanguage;
      case VoiceLogLanguagePreference.english:
        return AppLanguage.english;
      case VoiceLogLanguagePreference.czech:
        return AppLanguage.czech;
    }
  }

  LanguageSettingsState copyWith({AppLanguage? appLanguage, VoiceLogLanguagePreference? voiceLogLanguagePreference}) {
    return LanguageSettingsState(appLanguage: appLanguage ?? this.appLanguage, voiceLogLanguagePreference: voiceLogLanguagePreference ?? this.voiceLogLanguagePreference);
  }
}

class LanguageSettingsNotifier extends Notifier<LanguageSettingsState> {
  @override
  LanguageSettingsState build() => const LanguageSettingsState();

  /// Načte aktuální jazyk aplikace z předaného kódu jazyka a uloženou preferenci
  /// hlasového logu. Notifier nezná `BuildContext` — kód jazyka poskytuje UI vrstva.
  Future<void> initialize(String languageCode) async {
    final currentLanguage = AppLanguageX.fromLanguageCode(languageCode);
    final preference = await ref.read(languageSettingsServiceProvider).load();
    state = state.copyWith(appLanguage: currentLanguage, voiceLogLanguagePreference: preference);
  }

  void setAppLanguage(AppLanguage language) {
    if (state.appLanguage == language) return;
    state = state.copyWith(appLanguage: language);
  }

  Future<void> setVoiceLogLanguagePreference(VoiceLogLanguagePreference preference) async {
    if (state.voiceLogLanguagePreference == preference) return;
    await ref.read(languageSettingsServiceProvider).setVoiceLogLanguagePreference(preference);
    state = state.copyWith(voiceLogLanguagePreference: preference);
  }

  AppLanguage get effectiveVoiceLogLanguage => state.effectiveVoiceLogLanguage;
}

final languageSettingsProvider = NotifierProvider<LanguageSettingsNotifier, LanguageSettingsState>(LanguageSettingsNotifier.new);
