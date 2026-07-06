import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/network/gemini_rest_client.dart';
import 'package:diplomka/services/ai_feature/ai_service.dart';

class GeminiService implements AiService {
  GeminiService(this._ref);

  final Ref _ref;

  GeminiRestClient get restClient => _ref.read(geminiRestClientProvider);

  @override
  Future<AiResponse?> generateResponse({
    List<File>? imageFiles,
    String? textPrompt,
    Map<String, dynamic>? mealUserAttributes,
  }) async {
    try {
      final data = await restClient.generateResponse(
        imageFiles: imageFiles,
        textPrompt: textPrompt,
        mealUserAttributes: mealUserAttributes,
      );
      return responseContentParser(data);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  String? extractJsonFromContent(String content) {
    // This regex might need adjustment if Gemini wraps JSON in a different way or not at all.
    final regex = RegExp(r'\{[\s\S]*?\}');
    final match = regex.firstMatch(content);
    return match?.group(0);
  }

  AiResponse? responseContentParser(Map<String, dynamic> data) {
    try {
      // IMPORTANT: Adjust this parsing logic based on the actual Gemini API response structure.
      // The path to content and JSON extraction might be different.
      // For example, it might be in `candidates[0].content.parts[0].text`
      // And it might already be JSON, or JSON within a string.
      final content = data["candidates"][0]["content"]["parts"][0]["text"];
      final jsonString = extractJsonFromContent(content);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString);
        return AiResponse.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      print('Error parsing Gemini response: $e');
      return null;
    }
  }
}

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService(ref));
