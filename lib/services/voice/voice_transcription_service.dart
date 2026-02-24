import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

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
  }) async {
    if (!_initialized) {
      throw StateError('VoiceTranscriptionService must be initialized before listening.');
    }

    try {
      final localeId = await _resolveLocaleId(appLocale);
      await _speechToText.listen(
        onResult: onResult,
        localeId: localeId,
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 4),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
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

  Future<String?> _resolveLocaleId(Locale appLocale) async {
    final locales = await _loadLocales();
    if (locales.isEmpty) {
      final system = await _speechToText.systemLocale();
      return system?.localeId;
    }

    final normalized = <String, LocaleName>{
      for (final locale in locales) _normalizeLocaleId(locale.localeId): locale,
    };

    final preferred = _preferredLocaleCandidates(appLocale);
    for (final candidate in preferred) {
      final match = normalized[_normalizeLocaleId(candidate)];
      if (match != null) {
        return match.localeId;
      }
    }

    final languageCode = appLocale.languageCode.toLowerCase();
    for (final locale in locales) {
      final localeLanguage = _normalizeLocaleId(locale.localeId).split('_').first;
      if (localeLanguage == languageCode) {
        return locale.localeId;
      }
    }

    final system = await _speechToText.systemLocale();
    return system?.localeId ?? locales.first.localeId;
  }

  List<String> _preferredLocaleCandidates(Locale appLocale) {
    final language = appLocale.languageCode.toLowerCase();
    final country = appLocale.countryCode?.toUpperCase();

    final candidates = <String>[];
    if (language == 'cs') {
      candidates.addAll(<String>['cs_CZ', 'cs-CZ']);
    } else if (language == 'en') {
      candidates.addAll(<String>['en_US', 'en-US']);
    }
    if (country != null && country.isNotEmpty) {
      candidates.addAll(<String>['${language}_$country', '$language-$country']);
    }
    return candidates;
  }

  String _normalizeLocaleId(String localeId) {
    return localeId.replaceAll('-', '_').toLowerCase();
  }
}
