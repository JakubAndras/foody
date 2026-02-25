import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  czech,
}

extension AppLanguageX on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.czech:
        return 'cs';
    }
  }

  Locale get locale => Locale(code);

  static AppLanguage fromLanguageCode(String languageCode) {
    final normalized = languageCode.toLowerCase();
    if (normalized == 'cs') {
      return AppLanguage.czech;
    }
    return AppLanguage.english;
  }
}

enum VoiceLogLanguagePreference {
  followApp,
  english,
  czech,
}

const List<String> supportedVoiceLanguageCodes = <String>['cs', 'en'];

extension VoiceLogLanguagePreferenceX on VoiceLogLanguagePreference {
  String get code {
    switch (this) {
      case VoiceLogLanguagePreference.followApp:
        return 'follow_app';
      case VoiceLogLanguagePreference.english:
        return 'en';
      case VoiceLogLanguagePreference.czech:
        return 'cs';
    }
  }

  static VoiceLogLanguagePreference fromCode(String? code) {
    switch (code) {
      case 'en':
        return VoiceLogLanguagePreference.english;
      case 'cs':
        return VoiceLogLanguagePreference.czech;
      case 'follow_app':
      default:
        return VoiceLogLanguagePreference.followApp;
    }
  }
}
