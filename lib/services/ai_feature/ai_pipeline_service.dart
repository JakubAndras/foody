import 'dart:convert';
import 'dart:io';

import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/model/exercise_ai_analysis.dart';
import 'package:diplomka/model/nutrition_goals.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/network/openai_rest_client.dart';
import 'package:diplomka/services/ai_feature/ai_attempt_log_service.dart';
import 'package:diplomka/services/ai_feature/ai_service.dart';
import 'package:diplomka/services/ai_feature/ai_service_manager.dart';
import 'package:diplomka/services/ai_feature/openai_service.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/utils/app_limits.dart';
import 'package:diplomka/utils/prompt_sanitizer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AiPipelineService extends GetxService {
  static AiPipelineService get to => Get.find();

  static const double minMealConfidence = 0.50;
  static const double minExerciseConfidence = 0.50;

  Future<AiAnalysisResult> analyzeMeal({
    List<File>? imageFiles,
    String? description,
    // RESEARCH-ONLY: modality code is research-only. Used purely to log the
    // attempt into AiAttempt. Drop with telemetry. See RESEARCH_ONLY.md.
    String? modality,
  }) async {
    try {
      final sanitizedDescription = description != null ? PromptSanitizer.sanitize(description, maxLength: PromptSanitizer.maxDescriptionLength) : null;
      if (sanitizedDescription != null && PromptSanitizer.containsSuspiciousPatterns(sanitizedDescription)) {
        print('[AiPipeline] INJECTION DETECTED in meal description: "${sanitizedDescription.substring(0, sanitizedDescription.length.clamp(0, 80))}..."');
      }
      final AiService service = Get.isRegistered<AiService>() ? Get.find<AiService>() : OpenAiService();
      final mealUserAttributes = _buildMealUserAttributes();
      final response = await service.generateResponse(
        imageFiles: imageFiles,
        textPrompt: sanitizedDescription,
        mealUserAttributes: mealUserAttributes,
      );

      if (response == null || response.valid == false) {
        // RESEARCH-ONLY: research-only attempt log
        _logMealAttempt(
          modality: modality,
          status: AiAttemptStatus.invalidResponse,
          confidence: response?.answer.confidence,
          errorMessage: response == null ? 'null_response' : 'valid_false',
        );
        return AiAnalysisResult.failure(
          message: tr(LocaleKeys.error_ai_no_result),
        );
      }

      final confidence = response.answer.confidence;
      if (confidence < minMealConfidence) {
        // RESEARCH-ONLY: research-only attempt log
        _logMealAttempt(
          modality: modality,
          status: AiAttemptStatus.lowConfidence,
          confidence: confidence,
        );
        return AiAnalysisResult.lowConfidence(
          response: response,
          message: tr(LocaleKeys.error_ai_low_confidence),
        );
      }

      // RESEARCH-ONLY: research-only attempt log
      _logMealAttempt(
        modality: modality,
        status: AiAttemptStatus.success,
        confidence: confidence,
      );
      return AiAnalysisResult.success(response: response);
    } catch (e) {
      // RESEARCH-ONLY: research-only attempt log
      _logMealAttempt(
        modality: modality,
        status: AiAttemptStatus.error,
        errorMessage: e.toString(),
      );
      return AiAnalysisResult.failure(message: e.toString());
    }
  }

  // RESEARCH-ONLY: research-only helper. Drop with telemetry.
  void _logMealAttempt({
    required String? modality,
    required AiAttemptStatus status,
    double? confidence,
    String? errorMessage,
  }) {
    if (!Get.isRegistered<AiAttemptLogService>()) return;
    final manager = Get.isRegistered<AiServiceManager>() ? AiServiceManager.to : null;
    AiAttemptLogService.to.log(
      kind: AiAttemptKind.meal,
      status: status,
      modality: modality,
      provider: manager?.currentProviderCode,
      model: manager?.currentModelCode,
      confidence: confidence,
      errorMessage: errorMessage,
    );
  }

  Future<AiExerciseAnalysisResult> analyzeExercise({
    required String description,
  }) async {
    final trimmedDescription = PromptSanitizer.sanitize(description, maxLength: PromptSanitizer.maxDescriptionLength);
    if (PromptSanitizer.containsSuspiciousPatterns(trimmedDescription)) {
      print('[AiPipeline] INJECTION DETECTED in exercise description: "${trimmedDescription.substring(0, trimmedDescription.length.clamp(0, 80))}..."');
    }
    if (trimmedDescription.isEmpty) {
      return AiExerciseAnalysisResult.failure(
        message: tr(LocaleKeys.error_ai_exercise_empty),
      );
    }

    try {
      final userAttributes = _buildExerciseUserAttributes();
      final data = await OpenaiRestClient().generateExerciseResponse(
        textPrompt: trimmedDescription,
        userAttributes: userAttributes,
      );
      final analysis = _parseExerciseAnalysis(data);
      if (analysis == null) {
        // RESEARCH-ONLY: research-only attempt log
        _logExerciseAttempt(status: AiAttemptStatus.invalidResponse, errorMessage: 'parse_failed');
        return AiExerciseAnalysisResult.failure(
          message: tr(LocaleKeys.error_ai_exercise_no_result),
        );
      }

      final answer = analysis.answer;

      // Hard failure: AI returned valid=false AND (no name OR confidence too low)
      if (!analysis.valid && (answer.name.isEmpty || answer.confidence < minExerciseConfidence)) {
        // RESEARCH-ONLY: research-only attempt log
        _logExerciseAttempt(
          status: AiAttemptStatus.invalidResponse,
          confidence: answer.confidence,
          errorMessage: 'valid_false_or_no_name',
        );
        return AiExerciseAnalysisResult.failure(
          message: tr(LocaleKeys.error_ai_exercise_no_result),
        );
      }

      // Hard failure: no name at all
      if (answer.name.isEmpty) {
        // RESEARCH-ONLY: research-only attempt log
        _logExerciseAttempt(
          status: AiAttemptStatus.invalidResponse,
          confidence: answer.confidence,
          errorMessage: 'missing_name',
        );
        return AiExerciseAnalysisResult.failure(
          message: tr(LocaleKeys.error_ai_exercise_missing),
        );
      }

      // Low confidence: either AI flagged invalid, or confidence below threshold, or missing calories
      if (!analysis.valid || answer.confidence < minExerciseConfidence || !answer.hasUsableCalories) {
        // RESEARCH-ONLY: research-only attempt log
        _logExerciseAttempt(
          status: AiAttemptStatus.lowConfidence,
          confidence: answer.confidence,
        );
        return AiExerciseAnalysisResult.lowConfidence(
          analysis: analysis,
          message: tr(LocaleKeys.error_ai_exercise_low_confidence),
        );
      }

      // RESEARCH-ONLY: research-only attempt log
      _logExerciseAttempt(
        status: AiAttemptStatus.success,
        confidence: answer.confidence,
      );
      return AiExerciseAnalysisResult.success(analysis: analysis);
    } catch (e) {
      // RESEARCH-ONLY: research-only attempt log
      _logExerciseAttempt(status: AiAttemptStatus.error, errorMessage: e.toString());
      return AiExerciseAnalysisResult.failure(message: e.toString());
    }
  }

  // RESEARCH-ONLY: research-only helper. Drop with telemetry.
  void _logExerciseAttempt({
    required AiAttemptStatus status,
    double? confidence,
    String? errorMessage,
  }) {
    if (!Get.isRegistered<AiAttemptLogService>()) return;
    final manager = Get.isRegistered<AiServiceManager>() ? AiServiceManager.to : null;
    AiAttemptLogService.to.log(
      kind: AiAttemptKind.exercise,
      status: status,
      modality: 'voice_ai',
      provider: manager?.currentProviderCode,
      model: manager?.currentModelCode,
      confidence: confidence,
      errorMessage: errorMessage,
    );
  }

  Future<NutritionGoals?> generateNutritionGoals() async {
    try {
      final userProfile = _buildGoalsUserProfile();
      final data = await OpenaiRestClient().generateGoalsResponse(userProfile: userProfile);
      final goals = _parseNutritionGoals(data);
      // RESEARCH-ONLY: research-only attempt log
      _logGoalsAttempt(
        status: goals == null ? AiAttemptStatus.invalidResponse : AiAttemptStatus.success,
        errorMessage: goals == null ? 'parse_failed' : null,
      );
      return goals;
    } catch (e) {
      // RESEARCH-ONLY: research-only attempt log
      _logGoalsAttempt(status: AiAttemptStatus.error, errorMessage: e.toString());
      return null;
    }
  }

  // RESEARCH-ONLY: research-only helper. Drop with telemetry.
  void _logGoalsAttempt({required AiAttemptStatus status, String? errorMessage}) {
    if (!Get.isRegistered<AiAttemptLogService>()) return;
    final manager = Get.isRegistered<AiServiceManager>() ? AiServiceManager.to : null;
    AiAttemptLogService.to.log(
      kind: AiAttemptKind.goals,
      status: status,
      provider: manager?.currentProviderCode,
      model: manager?.currentModelCode,
      errorMessage: errorMessage,
    );
  }

  NutritionGoals? _parseNutritionGoals(Map<String, dynamic> data) {
    try {
      final content = data['choices']?[0]?['message']?['content'];
      if (content is! String) return null;
      final jsonString = _extractJsonFromContent(content);
      if (jsonString == null) return null;
      final decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) return null;

      final calories = (decoded['calories'] as num?)?.toDouble();
      final protein = (decoded['protein'] as num?)?.toDouble();
      final carbs = (decoded['carbs'] as num?)?.toDouble();
      final fat = (decoded['fat'] as num?)?.toDouble();

      if (calories == null || protein == null || carbs == null || fat == null) return null;
      if (calories <= 0 || protein <= 0 || carbs <= 0 || fat <= 0) return null;

      return NutritionGoals(
        calorieGoal: calories.clamp(1, AppLimits.goalMaxCalories.toDouble()),
        proteinGoal: protein.clamp(1, AppLimits.goalMaxMacro.toDouble()),
        carbsGoal: carbs.clamp(1, AppLimits.goalMaxMacro.toDouble()),
        fatGoal: fat.clamp(1, AppLimits.goalMaxMacro.toDouble()),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _buildGoalsUserProfile() {
    if (!Get.isRegistered<SessionManager>()) return <String, dynamic>{};

    final session = SessionManager.to;
    final ageYears = _resolveAgeYears(session.dateOfBirth.value);
    final sex = session.sex.value?.code;
    final heightCm = session.heightCm.value;
    final weightKg = session.weightKg.value;
    final goalWeightKg = session.goalWeightKg.value;
    final goal = session.goal.value?.code;
    final dietType = (session.dietType.value ?? ProfileDietType.classic).code;
    final rawDietPreferences = session.customDietPreferences.value?.trim();
    String? customDietPreferences;
    if (rawDietPreferences != null && rawDietPreferences.isNotEmpty) {
      customDietPreferences = PromptSanitizer.sanitize(rawDietPreferences, maxLength: PromptSanitizer.maxDietPreferencesLength);
      if (PromptSanitizer.containsSuspiciousPatterns(customDietPreferences)) {
        print('[AiPipeline] INJECTION DETECTED in goals diet preferences: "${customDietPreferences.substring(0, customDietPreferences.length.clamp(0, 80))}..."');
      }
      customDietPreferences = PromptSanitizer.wrapUserInput(customDietPreferences);
    }
    final weightChangeRate = session.weightChangeRateKgPerWeek.value;

    return <String, dynamic>{
      'sex': (sex != null && sex.isNotEmpty) ? sex : null,
      'age_years': ageYears,
      'height_cm': (heightCm != null && heightCm > 0) ? heightCm : null,
      'weight_kg': (weightKg != null && weightKg > 0) ? weightKg : null,
      'goal_weight_kg': (goalWeightKg != null && goalWeightKg > 0) ? goalWeightKg : null,
      'goal': goal,
      'diet_type': dietType,
      'custom_diet_preferences': (customDietPreferences != null && customDietPreferences.isNotEmpty) ? customDietPreferences : null,
      'weight_change_rate_kg_per_week': weightChangeRate,
    };
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
    final rawPreferences = session.customDietPreferences.value?.trim();
    String? customPreferences;
    if (rawPreferences != null && rawPreferences.isNotEmpty) {
      customPreferences = PromptSanitizer.sanitize(rawPreferences, maxLength: PromptSanitizer.maxDietPreferencesLength);
      if (PromptSanitizer.containsSuspiciousPatterns(customPreferences)) {
        print('[AiPipeline] INJECTION DETECTED in meal diet preferences: "${customPreferences.substring(0, customPreferences.length.clamp(0, 80))}..."');
      }
      customPreferences = PromptSanitizer.wrapUserInput(customPreferences);
    }

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
