class ExerciseAiAnalysis {
  const ExerciseAiAnalysis({
    required this.valid,
    required this.answer,
  });

  final bool valid;
  final ExerciseAiAnswer answer;

  factory ExerciseAiAnalysis.fromJson(Map<String, dynamic> json) {
    return ExerciseAiAnalysis(
      valid: json['valid'] == true,
      answer: ExerciseAiAnswer.fromJson(
        (json['answer'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }
}

class ExerciseAiAnswer {
  const ExerciseAiAnswer({
    required this.name,
    required this.confidence,
    this.durationMinutes,
    this.caloriesTotal,
    this.caloriesPerMinute,
  });

  final String name;
  final double confidence;
  final int? durationMinutes;
  final int? caloriesTotal;
  final double? caloriesPerMinute;

  bool get hasUsableCalories => caloriesTotal != null || (durationMinutes != null && caloriesPerMinute != null);

  factory ExerciseAiAnswer.fromJson(Map<String, dynamic> json) {
    return ExerciseAiAnswer(
      name: (json['name'] as String? ?? '').trim(),
      confidence: _toDouble(json['confidence']) ?? 0,
      durationMinutes: _toInt(json['duration_minutes']),
      caloriesTotal: _toInt(json['calories_total']),
      caloriesPerMinute: _toDouble(json['calories_per_minute']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.trim()) ?? double.tryParse(value.trim())?.round();
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }
}
