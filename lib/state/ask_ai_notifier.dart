import 'dart:convert';

import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ask_ai_query_response.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/network/openai_rest_client.dart';
import 'package:diplomka/services/ai_feature/ai_attempt_log_service.dart';
import 'package:diplomka/services/day_record_repository.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/utils/ai_cost_calculator.dart';
import 'package:diplomka/utils/ai_model_constants.dart';
import 'package:diplomka/utils/error.dart' as app_error;
import 'package:diplomka/utils/openai_usage.dart';
import 'package:diplomka/utils/prompt_sanitizer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sentinel pro `copyWith`, aby šlo nullovatelné pole explicitně nastavit na `null`.
const Object _undefined = Object();

/// Immutable stav obrazovky Ask AI.
/// `AsyncValue` sjednocuje původní `isLoading` + `response` + `errorMessage`
/// do jednoho pole (`loading` / `error` / `data`).
@immutable
class AskAiState {
  const AskAiState({
    this.lastQuery,
    this.result = const AsyncData<AskAiQueryResponse?>(null),
  });

  final String? lastQuery;
  final AsyncValue<AskAiQueryResponse?> result;

  AskAiState copyWith({
    Object? lastQuery = _undefined,
    AsyncValue<AskAiQueryResponse?>? result,
  }) {
    return AskAiState(
      lastQuery: lastQuery == _undefined ? this.lastQuery : lastQuery as String?,
      result: result ?? this.result,
    );
  }
}

/// neukazuje dialog. Vystaví stav, UI reaguje přes `ref.watch`/`ref.listen`.
class AskAiNotifier extends Notifier<AskAiState> {
  static const int _detailThresholdDays = 14;

  @override
  AskAiState build() => const AskAiState();

  void clearResponse() {
    state = const AskAiState();
  }

  /// Odešle dotaz na Ask AI. `languageCode` předává volající (UI) z `context.locale`;
  /// při null se použije fallback `en`.
  Future<void> submitQuery(String query, {String? languageCode}) async {
    final trimmed = PromptSanitizer.sanitize(query);
    if (trimmed.isEmpty) return;

    state = state.copyWith(result: const AsyncLoading<AskAiQueryResponse?>());

    final classification = PromptSanitizer.classifyInput(trimmed);
    if (classification == InjectionClassification.explicitAttack) {
      debugPrint('[AskAi] EXPLICIT INJECTION REJECTED in query: "${trimmed.substring(0, trimmed.length.clamp(0, 80))}..."');
      _emitError(tr(LocaleKeys.error_ai_input_rejected));
      return;
    }
    if (classification == InjectionClassification.ambiguous) {
      debugPrint('[AskAi] AMBIGUOUS PATTERN — LLM pre-screening query');
      final isInjection = await PromptSanitizer.preScreenWithLlm(ref.read(openaiRestClientProvider), trimmed);
      if (isInjection) {
        debugPrint('[AskAi] LLM PRE-SCREEN REJECTED query');
        _emitError(tr(LocaleKeys.error_ai_input_rejected));
        return;
      }
    }

    try {
      final records = await ref.read(dayRecordRepositoryProvider).getAllDayRecords();

      if (records.isEmpty) {
        _emitError(tr(LocaleKeys.ask_ai_no_data));
        return;
      }

      final sorted = List<DayRecord>.from(records)..sort((a, b) => b.date.compareTo(a.date));
      final client = ref.read(openaiRestClientProvider);

      // Pass 1: estimate the date range the question needs
      final dateRange = await _estimateScope(client, trimmed, sorted);

      // Pass 2: filter records to the estimated range and send them
      final selectedRecords = sorted.where((r) {
        final d = DateTime(r.date.year, r.date.month, r.date.day);
        return !d.isBefore(dateRange.$1) && !d.isAfter(dateRange.$2);
      }).toList();

      if (selectedRecords.isEmpty) {
        _emitError(tr(LocaleKeys.ask_ai_no_data));
        return;
      }

      final nutritionContext = _buildNutritionContext(selectedRecords);
      final profileContext = _buildUserProfileContext();
      final resolvedLanguage = languageCode ?? 'en';

      final data = await client.generateQueryResponse(
        query: trimmed,
        nutritionContext: nutritionContext,
        userProfileContext: profileContext,
        languageCode: resolvedLanguage,
      );
      _logAiAttempt(AiAttemptKind.query, data);

      final parsed = _parseQueryResponse(data);
      if (parsed == null) {
        _emitError(tr(LocaleKeys.ask_ai_parse_error));
        return;
      }

      state = state.copyWith(lastQuery: trimmed, result: AsyncData(parsed));
    } on app_error.Error catch (e) {
      debugPrint('AskAiNotifier.submitQuery error: $e');
      if (e.errorType == app_error.ErrorType.noInternetConnection) {
        _emitError(tr(LocaleKeys.error_no_internet));
      } else if (e.errorType == app_error.ErrorType.timeout) {
        _emitError(tr(LocaleKeys.error_timeout));
      } else {
        _emitError(tr(LocaleKeys.ask_ai_fetch_error));
      }
    } catch (e) {
      debugPrint('AskAiNotifier.submitQuery error: $e');
      _emitError(tr(LocaleKeys.ask_ai_fetch_error));
    }
  }

  /// Uloží uživatelsky čitelnou chybovou zprávu jako `AsyncError`.
  void _emitError(String message) {
    state = state.copyWith(result: AsyncError<AskAiQueryResponse?>(message, StackTrace.current));
  }

  /// Returns (from, to) date range for the query. Falls back to last 30 days.
  Future<(DateTime, DateTime)> _estimateScope(OpenaiRestClient client, String query, List<DayRecord> sorted) async {
    final now = DateTime.now();
    final todayDt = DateTime(now.year, now.month, now.day);
    final earliestDt = sorted.isNotEmpty ? DateTime(sorted.last.date.year, sorted.last.date.month, sorted.last.date.day) : todayDt;

    try {
      final metadata = jsonEncode({
        'today': _formatDate(todayDt),
        'earliest_record': _formatDate(earliestDt),
        'total_days_available': sorted.length,
      });

      final data = await client.estimateQueryScope(query: query, dataMetadata: metadata);
      _logAiAttempt(AiAttemptKind.queryScope, data);
      final content = data['choices']?[0]?['message']?['content'];
      if (content is String) {
        final jsonStr = _extractJson(content);
        if (jsonStr != null) {
          final decoded = json.decode(jsonStr);
          if (decoded is Map<String, dynamic>) {
            final from = DateTime.tryParse(decoded['date_from'] ?? '');
            final to = DateTime.tryParse(decoded['date_to'] ?? '');
            if (from != null && to != null) {
              return (
                from.isBefore(earliestDt) ? earliestDt : from,
                to.isAfter(todayDt) ? todayDt : to,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('AskAiNotifier._estimateScope fallback: $e');
    }
    // Fallback: last 30 days
    final fallbackFrom = todayDt.subtract(const Duration(days: 30));
    return (fallbackFrom.isBefore(earliestDt) ? earliestDt : fallbackFrom, todayDt);
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
      debugPrint('AskAiNotifier._parseQueryResponse error: $e');
      return null;
    }
  }

  String? _extractJson(String content) {
    // Strip markdown code fences if present (e.g. ```json ... ```)
    final cleaned = content.replaceAll(RegExp(r'```\w*\s*'), '').replaceAll(RegExp(r'```\s*$'), '');
    final regex = RegExp(r'\{[\s\S]*\}');
    final match = regex.firstMatch(cleaned);
    return match?.group(0);
  }

  String _buildNutritionContext(List<DayRecord> records) {
    final now = DateTime.now();
    final today = _formatDate(now);
    final toEncode = records.asMap().entries.map((entry) {
      final isRecent = entry.key < _detailThresholdDays;
      return isRecent ? _dayRecordToDetailMap(entry.value) : _dayRecordToSummaryMap(entry.value);
    }).toList();
    return jsonEncode({'today': today, 'records': toEncode});
  }

  /// Full detail for recent days: meals, ingredients, exercises
  Map<String, dynamic> _dayRecordToDetailMap(DayRecord r) {
    return {
      'date': _formatDate(r.date),
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

  /// Compact summary for older days: daily totals only
  Map<String, dynamic> _dayRecordToSummaryMap(DayRecord r) {
    return {
      'date': _formatDate(r.date),
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
      if (r.exercises.isNotEmpty) 'exercise_cal': r.exercises.fold<int>(0, (sum, e) => sum + e.caloriesBurned.round()),
    };
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // RESEARCH-ONLY: log Ask AI API calls for token/cost telemetry.
  void _logAiAttempt(AiAttemptKind kind, Map<String, dynamic> data) {
    final usage = OpenAiUsage.fromResponse(data);
    final cost = (usage != null) ? AiCostCalculator.calculateCostUsd(model: aiModelMain, promptTokens: usage.promptTokens, completionTokens: usage.completionTokens, cachedTokens: usage.cachedTokens) : null;
    ref.read(aiAttemptLogServiceProvider).log(
      kind: kind,
      status: AiAttemptStatus.success,
      provider: 'openai',
      model: aiModelMain,
      promptTokens: usage?.promptTokens,
      completionTokens: usage?.completionTokens,
      cachedTokens: usage?.cachedTokens,
      costUsd: cost,
    );
  }

  String _buildUserProfileContext() {
    final session = ref.read(sessionProvider);
    final parts = <String, dynamic>{};

    final dietType = session.dietType;
    if (dietType != null) parts['diet_type'] = dietType.code;

    final customDiet = session.customDietPreferences?.trim();
    if (customDiet != null && customDiet.isNotEmpty) parts['diet_preferences'] = customDiet;

    final weight = session.weightKg;
    if (weight != null && weight > 0) parts['weight_kg'] = weight;

    final height = session.heightCm;
    if (height != null && height > 0) parts['height_cm'] = height;

    final goal = session.goal;
    if (goal != null) parts['goal'] = goal.code;

    return parts.isNotEmpty ? jsonEncode(parts) : '';
  }
}

final askAiProvider = NotifierProvider<AskAiNotifier, AskAiState>(AskAiNotifier.new);
