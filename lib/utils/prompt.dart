import 'dart:core';
import 'dart:convert';

class Prompt {
  String get analyzeMeal => jsonEncode(analyzeMealJson);
  String get analyzeExercise => jsonEncode(analyzeExerciseJson);
  String get analyzeQuery => jsonEncode(analyzeQueryJson);
  String get estimateQueryScope => jsonEncode(estimateQueryScopeJson);
  String get generateNutritionGoals => jsonEncode(generateNutritionGoalsJson);

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
        "The meal name must be at most 30 characters. Use the marketing or brand name of the product when recognizable.",
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
        "period_label should reflect the actual date range of the data you analyzed.",
        "Respond in the same language the user used in their question.",
        "If the user asks about nutrients not present in the data (e.g. fiber, sodium, sugar), explain that this nutrient is not currently tracked in the app.",
        "If the question is not related to nutrition, meals, exercises, or dietary habits, politely explain that you can only answer nutrition-related questions."
      ]
    }
  };

  static const Map<String, dynamic> estimateQueryScopeJson = {
    "task":
        "You are a query scope estimator for a nutrition tracking app. Given a user's question, today's date, and metadata about available data, determine the exact date range needed to answer the question. Return only a JSON object with from/to dates.",
    "expected_output": {
      "format": "json",
      "schema": {
        "date_from": "string — start date in YYYY-MM-DD format (inclusive)",
        "date_to": "string — end date in YYYY-MM-DD format (inclusive)"
      },
      "rules": [
        "Return only JSON.",
        "Use the provided today date to resolve relative references like 'today', 'yesterday', 'last week', 'last month', 'last Christmas'.",
        "For a specific day (e.g. 'last Christmas', 'yesterday'), date_from and date_to should be the same date.",
        "For a range (e.g. 'this week', 'January'), set from/to to cover the full range.",
        "For 'all time', 'ever', or general trends, use the earliest_record as date_from and today as date_to.",
        "For vague questions without a time reference, use the last 30 days.",
        "Never set date_from earlier than the earliest_record date.",
        "Never set date_to later than today."
      ]
    }
  };

  static const Map<String, dynamic> generateNutritionGoalsJson = {
    "task":
        "Generate personalized daily nutrition goals (calories, protein, carbs, fat) based on the user's profile. Use established nutrition science (Mifflin-St Jeor for BMR, appropriate activity multipliers, and evidence-based macro splits). Return only JSON.",
    "expected_output": {
      "format": "json",
      "schema": {
        "calories": "int — total daily calorie target",
        "protein": "int — grams of protein per day",
        "carbs": "int — grams of carbohydrates per day",
        "fat": "int — grams of fat per day"
      },
      "rules": [
        "Return only JSON.",
        "Use Mifflin-St Jeor equation for BMR calculation.",
        "Apply activity multiplier: sedentary=1.2, light=1.375, moderate=1.55, active=1.725.",
        "For weight loss goal, create a deficit of 300-500 kcal/day depending on the desired rate.",
        "For weight gain goal, create a surplus of 250-500 kcal/day depending on the desired rate.",
        "Protein: 1.6-2.2 g/kg for active individuals, 1.2-1.6 g/kg for sedentary.",
        "Fat: 25-35% of total calories.",
        "Carbs: remaining calories after protein and fat.",
        "Round all values to whole numbers.",
        "If insufficient data is provided, use reasonable defaults (e.g. moderate activity, 30 years old).",
        "Respect dietary preferences (vegan/vegetarian may need adjusted protein sources but same macro targets)."
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
