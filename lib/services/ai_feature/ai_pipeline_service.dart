import 'dart:convert';
import 'dart:io';

import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/model/exercise_ai_analysis.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/network/openai_rest_client.dart';
import 'package:diplomka/services/ai_feature/ai_service.dart';
import 'package:diplomka/services/ai_feature/openai_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:get/get.dart';

class AiPipelineService extends GetxService {
  static AiPipelineService get to => Get.find();

  static const double minMealConfidence = 0.45;
  static const double minExerciseConfidence = 0.35;

  Future<AiAnalysisResult> analyzeMeal({
    List<File>? imageFiles,
    String? description,
  }) async {
    try {
      final AiService service = Get.isRegistered<AiService>() ? Get.find<AiService>() : OpenAiService();
      final mealUserAttributes = _buildMealUserAttributes();
      final response = await service.generateResponse(
        imageFiles: imageFiles,
        textPrompt: description,
        mealUserAttributes: mealUserAttributes,
      );

      if (response == null || response.valid == false) {
        return AiAnalysisResult.failure(
          message: 'Analysis failed to return a valid result.',
        );
      }

      final confidence = response.answer.confidence;
      if (confidence < minMealConfidence) {
        return AiAnalysisResult.lowConfidence(
          response: response,
          message: 'Low confidence result. Please review.',
        );
      }

      return AiAnalysisResult.success(response: response);
    } catch (e) {
      return AiAnalysisResult.failure(message: e.toString());
    }
  }

  Future<AiExerciseAnalysisResult> analyzeExercise({
    required String description,
  }) async {
    final trimmedDescription = description.trim();
    if (trimmedDescription.isEmpty) {
      return AiExerciseAnalysisResult.failure(
        message: 'Exercise description is empty.',
      );
    }

    try {
      final userAttributes = _buildExerciseUserAttributes();
      final data = await OpenaiRestClient().generateExerciseResponse(
        textPrompt: trimmedDescription,
        userAttributes: userAttributes,
      );
      final analysis = _parseExerciseAnalysis(data);
      if (analysis == null || !analysis.valid) {
        return AiExerciseAnalysisResult.failure(
          message: 'Exercise analysis failed to return a valid result.',
        );
      }

      final answer = analysis.answer;
      if (answer.name.isEmpty || !answer.hasUsableCalories) {
        return AiExerciseAnalysisResult.failure(
          message: 'Exercise analysis is missing required fields.',
        );
      }

      if (answer.confidence < minExerciseConfidence) {
        return AiExerciseAnalysisResult.lowConfidence(
          analysis: analysis,
          message: 'Low confidence exercise result. Please review values.',
        );
      }

      return AiExerciseAnalysisResult.success(analysis: analysis);
    } catch (e) {
      return AiExerciseAnalysisResult.failure(message: e.toString());
    }
  }

  ExerciseAiAnalysis? _parseExerciseAnalysis(Map<String, dynamic> data) {
    try {
      final content = data['choices']?[0]?['message']?['content'];
      if (content is! String) return null;
      final jsonString = _extractJsonFromContent(content);
      if (jsonString == null) return null;
      final decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) return null;
      return ExerciseAiAnalysis.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  String? _extractJsonFromContent(String content) {
    final regex = RegExp(r'\{[\s\S]*\}');
    final match = regex.firstMatch(content);
    return match?.group(0);
  }

  Map<String, dynamic> _buildExerciseUserAttributes() {
    if (!Get.isRegistered<SessionManager>()) {
      return <String, dynamic>{
        'sex': null,
        'age_years': null,
        'height_cm': null,
        'weight_kg': null,
      };
    }

    final session = SessionManager.to;
    final ageYears = _resolveAgeYears(session.dateOfBirth.value);
    final sex = session.sex.value?.code;
    final heightCm = session.heightCm.value;
    final weightKg = session.weightKg.value;

    return <String, dynamic>{
      'sex': (sex != null && sex.isNotEmpty) ? sex : null,
      'age_years': ageYears,
      'height_cm': (heightCm != null && heightCm > 0) ? heightCm : null,
      'weight_kg': (weightKg != null && weightKg > 0) ? weightKg : null,
    };
  }

  Map<String, dynamic> _buildMealUserAttributes() {
    if (!Get.isRegistered<SessionManager>()) {
      return <String, dynamic>{
        'diet_type': ProfileDietType.classic.code,
        'diet_custom_preferences': null,
      };
    }

    final session = SessionManager.to;
    final dietType = session.dietType.value ?? ProfileDietType.classic;
    final customPreferences = session.customDietPreferences.value?.trim();

    return <String, dynamic>{
      'diet_type': dietType.code,
      'diet_custom_preferences': (customPreferences != null && customPreferences.isNotEmpty) ? customPreferences : null,
    };
  }

  int? _resolveAgeYears(DateTime? dob) {
    if (dob == null) {
      return null;
    }

    final now = DateTime.now();
    int age = now.year - dob.year;
    final birthdayPassedThisYear = now.month > dob.month || (now.month == dob.month && now.day >= dob.day);
    if (!birthdayPassedThisYear) {
      age -= 1;
    }

    if (age < 0 || age > 120) {
      return null;
    }
    return age;
  }
}

enum AiAnalysisStatus {
  success,
  lowConfidence,
  failure,
}

class AiAnalysisResult {
  final AiAnalysisStatus status;
  final AiResponse? response;
  final String? message;

  const AiAnalysisResult._({
    required this.status,
    this.response,
    this.message,
  });

  factory AiAnalysisResult.success({required AiResponse response}) {
    return AiAnalysisResult._(status: AiAnalysisStatus.success, response: response);
  }

  factory AiAnalysisResult.lowConfidence({required AiResponse response, String? message}) {
    return AiAnalysisResult._(
      status: AiAnalysisStatus.lowConfidence,
      response: response,
      message: message,
    );
  }

  factory AiAnalysisResult.failure({String? message}) {
    return AiAnalysisResult._(status: AiAnalysisStatus.failure, message: message);
  }

  bool get isSuccess => status == AiAnalysisStatus.success || status == AiAnalysisStatus.lowConfidence;
}

enum AiExerciseAnalysisStatus {
  success,
  lowConfidence,
  failure,
}

class AiExerciseAnalysisResult {
  final AiExerciseAnalysisStatus status;
  final ExerciseAiAnalysis? analysis;
  final String? message;

  const AiExerciseAnalysisResult._({
    required this.status,
    this.analysis,
    this.message,
  });

  factory AiExerciseAnalysisResult.success({
    required ExerciseAiAnalysis analysis,
  }) {
    return AiExerciseAnalysisResult._(
      status: AiExerciseAnalysisStatus.success,
      analysis: analysis,
    );
  }

  factory AiExerciseAnalysisResult.lowConfidence({
    required ExerciseAiAnalysis analysis,
    String? message,
  }) {
    return AiExerciseAnalysisResult._(
      status: AiExerciseAnalysisStatus.lowConfidence,
      analysis: analysis,
      message: message,
    );
  }

  factory AiExerciseAnalysisResult.failure({String? message}) {
    return AiExerciseAnalysisResult._(
      status: AiExerciseAnalysisStatus.failure,
      message: message,
    );
  }

  bool get isSuccess => status == AiExerciseAnalysisStatus.success || status == AiExerciseAnalysisStatus.lowConfidence;
}
