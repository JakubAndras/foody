// RESEARCH-ONLY: entire file. Research-only — remove before production.
// See RESEARCH_ONLY.md for full rip-out instructions.

/// Identifies how a meal record was originally created in the app.
///
/// Persisted on `MealEntity.inputSource` to enable longitudinal analysis of
/// AI accuracy and user-modality preferences during long-term user testing.
enum MealEntrySource {
  photoAi,
  voiceAi,
  textAi,
  barcode,
  barcodeAiFallback,
  manual,
  fixWithAiRerun,
}

extension MealEntrySourceCodec on MealEntrySource {
  String get code {
    switch (this) {
      case MealEntrySource.photoAi:
        return 'photo_ai';
      case MealEntrySource.voiceAi:
        return 'voice_ai';
      case MealEntrySource.textAi:
        return 'text_ai';
      case MealEntrySource.barcode:
        return 'barcode';
      case MealEntrySource.barcodeAiFallback:
        return 'barcode_ai_fallback';
      case MealEntrySource.manual:
        return 'manual';
      case MealEntrySource.fixWithAiRerun:
        return 'fix_with_ai_rerun';
    }
  }

  bool get isAiAssisted {
    switch (this) {
      case MealEntrySource.photoAi:
      case MealEntrySource.voiceAi:
      case MealEntrySource.textAi:
      case MealEntrySource.barcodeAiFallback:
      case MealEntrySource.fixWithAiRerun:
        return true;
      case MealEntrySource.barcode:
      case MealEntrySource.manual:
        return false;
    }
  }
}

bool isAiAssistedSourceCode(String? code) {
  if (code == null) return false;
  for (final s in MealEntrySource.values) {
    if (s.code == code) return s.isAiAssisted;
  }
  return false;
}
