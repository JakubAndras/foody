// RESEARCH-ONLY: entire entity. Research-only — captures every AI
// invocation (success, low-confidence, parse failure, network error) so
// long-term testing can analyze AI reliability beyond what survives in the
// Meal/Exercise tables. Drop the entire table before production. See
// RESEARCH_ONLY.md.

import 'package:floor/floor.dart';

@Entity(tableName: 'AiAttempt')
class AiAttemptEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// Wall-clock time of the attempt, in epoch milliseconds.
  final int timestampMs;

  /// What was attempted: `meal`, `exercise`, or `goals`.
  final String kind;

  /// Modality the meal attempt was triggered with (`photo_ai`, `voice_ai`,
  /// `text_ai`, `barcode_ai_fallback`, `fix_with_ai_rerun`). Null for
  /// `exercise` and `goals` kinds.
  final String? modality;

  /// AI provider code (`openai` / `gemini`).
  final String? provider;

  /// AI model code, e.g. `gpt-5.4`.
  final String? model;

  /// Outcome bucket: `success`, `low_confidence`, `invalid_response`, `error`.
  final String status;

  /// Confidence reported by the model when a parsable response was returned.
  final double? confidence;

  /// Truncated diagnostic message for `invalid_response` and `error` rows.
  final String? errorMessage;

  AiAttemptEntity({
    this.id,
    required this.timestampMs,
    required this.kind,
    this.modality,
    this.provider,
    this.model,
    required this.status,
    this.confidence,
    this.errorMessage,
  });
}
