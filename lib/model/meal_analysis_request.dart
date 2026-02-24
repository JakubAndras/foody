import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';

enum MealInputSource {
  photo,
  voice,
}

class MealAnalysisRequest {
  const MealAnalysisRequest({
    required this.selectedDate,
    required this.source,
    this.imagePath,
    this.description,
    this.preferredMealName,
    this.scrollToTodayMealsOnStart = false,
  });

  final DateTime selectedDate;
  final MealInputSource source;
  final String? imagePath;
  final String? description;
  final String? preferredMealName;
  final bool scrollToTodayMealsOnStart;

  factory MealAnalysisRequest.photo({
    required DateTime selectedDate,
    required String imagePath,
    String? description,
    String? preferredMealName,
    bool scrollToTodayMealsOnStart = false,
  }) {
    return MealAnalysisRequest(
      selectedDate: selectedDate,
      source: MealInputSource.photo,
      imagePath: imagePath,
      description: description,
      preferredMealName: preferredMealName,
      scrollToTodayMealsOnStart: scrollToTodayMealsOnStart,
    );
  }

  factory MealAnalysisRequest.voice({
    required DateTime selectedDate,
    required String description,
    bool scrollToTodayMealsOnStart = false,
  }) {
    return MealAnalysisRequest(
      selectedDate: selectedDate,
      source: MealInputSource.voice,
      description: description,
      scrollToTodayMealsOnStart: scrollToTodayMealsOnStart,
    );
  }

  String? get trimmedImagePath {
    final path = imagePath?.trim() ?? '';
    return path.isEmpty ? null : path;
  }

  String? get trimmedDescription {
    final text = description?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class MealAnalysisFlowResult {
  const MealAnalysisFlowResult({
    required this.success,
    this.message,
    this.status,
  });

  final bool success;
  final String? message;
  final AiAnalysisStatus? status;

  factory MealAnalysisFlowResult.success({AiAnalysisStatus? status}) {
    return MealAnalysisFlowResult(
      success: true,
      status: status,
    );
  }

  factory MealAnalysisFlowResult.failure({String? message}) {
    return MealAnalysisFlowResult(
      success: false,
      message: message,
    );
  }
}
