import 'dart:core';
import 'dart:convert';

class Prompt {
  String get analyzeMeal => jsonEncode(analyzeMealJson);

  static const Map<String, dynamic> analyzeMealJson = {
    "task":
        "Identify the food and ingredients in the input photo and, as output, provide their names and nutritional values for both the entire dish and the individual ingredients. The output must be a text representation in JSON format.",
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
      }
    }
  };
}
