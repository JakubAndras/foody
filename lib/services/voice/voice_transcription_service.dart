import 'package:flutter/material.dart';
import 'package:diplomka/model/language_settings.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceTranscriptionService {
  VoiceTranscriptionService({SpeechToText? speechToText}) : _speechToText = speechToText ?? SpeechToText();

  final SpeechToText _speechToText;
  bool _initialized = false;
  List<LocaleName>? _cachedLocales;

  bool get isListening => _speechToText.isListening;
  bool get isAvailable => _speechToText.isAvailable;

  Future<bool> initialize({
    required void Function(SpeechRecognitionError error) onError,
    required void Function(String status) onStatus,
  }) async {
    try {
      final initialized = await _speechToText.initialize(
        onError: onError,
        onStatus: onStatus,
        debugLogging: false,
        options: <SpeechConfigOption>[
          SpeechToText.androidIntentLookup,
        ],
      );
      _initialized = initialized;
      return initialized && _speechToText.isAvailable;
    } catch (_) {
      _initialized = false;
      return false;
    }
  }

  Future<void> startListening({
    required void Function(SpeechRecognitionResult result) onResult,
    required Locale appLocale,
    String? preferredLanguageCode,
  }) async {
    if (!_initialized) {
      throw StateError('VoiceTranscriptionService must be initialized before listening.');
    }

    try {
      final localeId = await _resolveLocaleId(
        appLocale,
        preferredLanguageCode: preferredLanguageCode,
      );
      await _speechToText.listen(
        onResult: onResult,
        localeId: localeId,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 8),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
          autoPunctuation: true,
        ),
      );
    } catch (_) {
      throw StateError('Failed to start speech recognition.');
    }
  }

  Future<void> stopListening() async {
    if (!_initialized) return;
    try {
      await _speechToText.stop();
    } catch (_) {
      throw StateError('Failed to stop speech recognition.');
    }
  }

  Future<void> cancelListening() async {
    if (!_initialized) return;
    try {
      await _speechToText.cancel();
    } catch (_) {
      throw StateError('Failed to cancel speech recognition.');
    }
  }

  Future<List<LocaleName>> _loadLocales() async {
    if (_cachedLocales != null) return _cachedLocales!;
    try {
      _cachedLocales = await _speechToText.locales();
    } catch (_) {
      _cachedLocales = const <LocaleName>[];
    }
    return _cachedLocales!;
  }

  Future<String?> _resolveLocaleId(
    Locale appLocale, {
    String? preferredLanguageCode,
  }) async {
    final locales = await _loadLocales();
    if (locales.isEmpty) {
      final system = await _speechToText.systemLocale();
      return system?.localeId;
    }

    final normalizedLocales = <String, LocaleName>{
      for (final locale in locales) _normalizeLocaleId(locale.localeId): locale,
    };

    final systemLocale = await _speechToText.systemLocale();
    final languagePriority = _buildLanguagePriority(
      preferredLanguageCode: preferredLanguageCode,
      appLocaleLanguage: appLocale.languageCode,
      systemLocaleId: systemLocale?.localeId,
    );

    for (final languageCode in languagePriority) {
      for (final candidate in _preferredLocaleCandidatesForLanguage(languageCode)) {
        final match = normalizedLocales[_normalizeLocaleId(candidate)];
        if (match != null) {
          return match.localeId;
        }
      }
    }

    for (final locale in locales) {
      final localeLanguage = _extractLanguageCode(locale.localeId);
      if (supportedVoiceLanguageCodes.contains(localeLanguage)) {
        return locale.localeId;
      }
    }

    return systemLocale?.localeId ?? locales.first.localeId;
  }

  List<String> _buildLanguagePriority({
    required String? preferredLanguageCode,
    required String appLocaleLanguage,
    required String? systemLocaleId,
  }) {
    final preferredLanguage = preferredLanguageCode?.toLowerCase();
    final appLanguage = appLocaleLanguage.toLowerCase();
    final systemLanguage = systemLocaleId == null ? null : _extractLanguageCode(systemLocaleId);

    final result = <String>[];

    void addIfSupported(String? code) {
      if (code == null) return;
      if (!supportedVoiceLanguageCodes.contains(code)) return;
      if (!result.contains(code)) {
        result.add(code);
      }
    }

    addIfSupported(preferredLanguage);
    addIfSupported(systemLanguage);
    addIfSupported(appLanguage);

    for (final code in supportedVoiceLanguageCodes) {
      addIfSupported(code);
    }

    return result;
  }

  List<String> _preferredLocaleCandidatesForLanguage(String languageCode) {
    final language = languageCode.toLowerCase();
    if (language == 'cs') {
      return <String>['cs_CZ', 'cs-CZ', 'cs'];
    }
    if (language == 'en') {
      return <String>['en_US', 'en-US', 'en_GB', 'en-GB', 'en'];
    }
    return <String>[language];
  }

  String _extractLanguageCode(String localeId) {
    return _normalizeLocaleId(localeId).split('_').first;
  }

  String _normalizeLocaleId(String localeId) {
    return localeId.replaceAll('-', '_').toLowerCase();
  }
}
