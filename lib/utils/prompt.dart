import 'dart:core';
import 'dart:convert';

class Prompt {
  String get analyzeMeal => jsonEncode(analyzeMealJson);
  String get analyzeExercise => jsonEncode(analyzeExerciseJson);
  String get analyzeQuery => jsonEncode(analyzeQueryJson);

  static const Map<String, dynamic> analyzeMealJson = {
    "task":
        "Identify the meal and ingredients from available user inputs. If a meal photo is provided, use it as the primary signal and use text as optional context. If no photo is provided, infer the meal from text description only. Return names and nutritional values for the whole dish and for individual ingredients. The output must be JSON text only.",
    "expected_output": {
      "format": "json",
      "schema": {
        "valid": "boolean",
        "answer": {
          "name": "string",
          "confidence": "double - between 0 and 1",
          "nutritional_values": {"calories": "int", "proteins": "double", "fats": "double", "carbs": "double"},
          "ingredients": [
            {
              "name": "string",
              "confidence": "double - between 0 and 1",
              "quantity": "string",
              "nutritional_values": {"calories": "int", "proteins": "double", "fats": "double", "carbs": "double"}
            }
          ]
        }
      },
      "rules": [
        "Return only JSON.",
        "When only text is available, infer a realistic dish from the text.",
        "When both image and text are available, prioritize image evidence and use text to disambiguate."
      ]
    }
  };

  static const Map<String, dynamic> analyzeQueryJson = {
    "task":
        "You are a personal nutrition data analyst. The user asks a natural-language question about their nutrition, meals, exercises, or dietary habits. You are given their logged data (daily summaries with meals, ingredients, exercises, and goals) and their profile. Analyze the data to answer the question accurately. Return a structured JSON response.",
    "expected_output": {
      "format": "json",
      "schema": {
        "response_text": "string — a clear, concise narrative answer to the user's question (2-4 sentences)",
        "insight_type": "string — one of: violations, achieved, tracked",
        "summary_value": "int — the single most relevant metric (e.g. count of days, average value)",
        "summary_label": "string — short label for the metric (e.g. 'Violations found', 'Days achieved', 'Days tracked')",
        "affected_days": [
          {"year": "int", "month": "int", "day": "int"}
        ],
        "period_label": "string — human-readable period label (e.g. 'March 2026', 'Last 7 days')"
      },
      "insight_type_rules": {
        "violations": "Use when the question is about exceeding limits, breaking dietary restrictions, or negative patterns",
        "achieved": "Use when the question is about meeting goals, positive achievements, or targets hit",
        "tracked": "Use when the question is about general tracking, counting occurrences, or neutral data queries"
      },
      "rules": [
        "Return only JSON.",
        "Base your answer strictly on the provided data. Do not invent data points.",
        "affected_days must only contain dates that exist in the provided data and are relevant to the answer.",
        "summary_value should be a meaningful integer (count, rounded average, etc.).",
        "If the data is insufficient to answer, set response_text to explain what data is missing, summary_value to 0, and affected_days to empty array.",
        "Keep response_text concise and informative — no filler phrases.",
        "period_label should reflect the actual date range of the data you analyzed."
      ]
    }
  };

  static const Map<String, dynamic> analyzeExerciseJson = {
    "task":
        "Read the user's text description of an exercise and extract a structured exercise log candidate. Never invent impossible values. Prefer realistic estimates when values are implied.",
    "expected_output": {
      "format": "json",
      "schema": {
        "valid": "boolean",
        "answer": {
          "name": "string",
          "confidence": "double - between 0 and 1",
          "duration_minutes": "int or null",
          "calories_total": "int or null",
          "calories_per_minute": "double or null"
        }
      },
      "rules": [
        "Return only JSON.",
        "If user profile context is provided (sex, age_years, height_cm, weight_kg), use it when estimating calories.",
        "When valid=true, calories must be usable: provide either calories_total, or both duration_minutes and calories_per_minute.",
        "If calories cannot be estimated with reasonable confidence, return valid=false.",
        "If duration is unclear, keep duration_minutes null instead of guessing aggressively."
      ]
    }
  };
}
