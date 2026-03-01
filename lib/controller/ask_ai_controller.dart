import 'dart:convert';

import 'package:diplomka/model/ask_ai_query_response.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/network/openai_rest_client.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AskAiController extends GetxController {
  static AskAiController get to => Get.find();

  final RxBool isLoading = false.obs;
  final Rxn<AskAiQueryResponse> response = Rxn<AskAiQueryResponse>();
  final RxnString errorMessage = RxnString();

  static const int _maxDaysDetailed = 60;

  Future<AskAiQueryResponse?> submitQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    isLoading.value = true;
    errorMessage.value = null;
    response.value = null;

    try {
      final records = await DayRecordRepository.to.getAllDayRecords();

      if (records.isEmpty) {
        errorMessage.value = 'You don\'t have any nutrition data logged yet. Start logging meals to use Ask AI.';
        return null;
      }

      final nutritionContext = _buildNutritionContext(records);
      final profileContext = _buildUserProfileContext();

      final data = await OpenaiRestClient().generateQueryResponse(
        query: trimmed,
        nutritionContext: nutritionContext,
        userProfileContext: profileContext,
      );

      final parsed = _parseQueryResponse(data);
      if (parsed == null) {
        errorMessage.value = 'Failed to parse AI response. Please try again.';
        return null;
      }

      response.value = parsed;
      return parsed;
    } catch (e) {
      debugPrint('AskAiController.submitQuery error: $e');
      errorMessage.value = 'Failed to get AI response. Please check your connection and try again.';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  AskAiQueryResponse? _parseQueryResponse(Map<String, dynamic> data) {
    try {
      final content = data['choices']?[0]?['message']?['content'];
      if (content is! String) return null;
      final jsonString = _extractJson(content);
      if (jsonString == null) return null;
      final decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) return null;
      return AskAiQueryResponse.fromJson(decoded);
    } catch (e) {
      debugPrint('AskAiController._parseQueryResponse error: $e');
      return null;
    }
  }

  String? _extractJson(String content) {
    final regex = RegExp(r'\{[\s\S]*\}');
    final match = regex.firstMatch(content);
    return match?.group(0);
  }

  String _buildNutritionContext(List<DayRecord> records) {
    final sorted = List<DayRecord>.from(records)..sort((a, b) => b.date.compareTo(a.date));
    final toEncode = sorted.take(_maxDaysDetailed).map((r) => _dayRecordToCompactMap(r)).toList();
    return jsonEncode(toEncode);
  }

  Map<String, dynamic> _dayRecordToCompactMap(DayRecord r) {
    return {
      'date': '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}',
      'calories': r.totalCalories.round(),
      'protein': r.totalProteins.round(),
      'carbs': r.totalCarbs.round(),
      'fat': r.totalFats.round(),
      'goals': {
        'cal': r.calorieGoal.round(),
        'prot': r.proteinGoal.round(),
        'carbs': r.carbsGoal.round(),
        'fat': r.fatGoal.round(),
      },
      'meals': r.meals.map((m) => {
        'name': m.name,
        'cal': m.totalCalories.round(),
        'ingredients': m.ingredients.map((i) => i.name).toList(),
      }).toList(),
      if (r.exercises.isNotEmpty)
        'exercises': r.exercises.map((e) => {
          'name': e.name,
          'cal_burned': e.caloriesBurned.round(),
          if (e.durationMinutes != null && e.durationMinutes! > 0) 'min': e.durationMinutes,
        }).toList(),
    };
  }

  String _buildUserProfileContext() {
    if (!Get.isRegistered<SessionManager>()) return '';

    final session = SessionManager.to;
    final parts = <String, dynamic>{};

    final dietType = session.dietType.value;
    if (dietType != null) parts['diet_type'] = dietType.code;

    final customDiet = session.customDietPreferences.value?.trim();
    if (customDiet != null && customDiet.isNotEmpty) parts['diet_preferences'] = customDiet;

    final weight = session.weightKg.value;
    if (weight != null && weight > 0) parts['weight_kg'] = weight;

    final height = session.heightCm.value;
    if (height != null && height > 0) parts['height_cm'] = height;

    final goal = session.goal.value;
    if (goal != null) parts['goal'] = goal.code;

    return parts.isNotEmpty ? jsonEncode(parts) : '';
  }
}
