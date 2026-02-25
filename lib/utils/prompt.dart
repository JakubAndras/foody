import 'dart:core';
import 'dart:convert';

class Prompt {
  String get analyzeMeal => jsonEncode(analyzeMealJson);
  String get analyzeExercise => jsonEncode(analyzeExerciseJson);

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
