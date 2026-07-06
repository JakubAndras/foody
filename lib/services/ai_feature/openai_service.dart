import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/network/openai_rest_client.dart';
import 'package:diplomka/services/ai_feature/ai_service.dart';
import 'package:diplomka/utils/openai_usage.dart';

class OpenAiService implements AiService {
  OpenAiService(this._ref);

  final Ref _ref;

  OpenaiRestClient get restClient => _ref.read(openaiRestClientProvider);

  // RESEARCH-ONLY: side-channel for the last call's token usage.
  OpenAiUsage? lastCallUsage;

  @override
  Future<AiResponse?> generateResponse({
    List<File>? imageFiles,
    String? textPrompt,
    Map<String, dynamic>? mealUserAttributes,
  }) async {
    lastCallUsage = null;
    try {
      final data = await restClient.generateResponse(
        imageFiles: imageFiles,
        textPrompt: textPrompt,
        mealUserAttributes: mealUserAttributes,
      );
      lastCallUsage = OpenAiUsage.fromResponse(data);
      return responseContentParser(data);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  String? extractJsonFromContent(String content) {
    final regex = RegExp(r'\{[\s\S]*\}');
    final match = regex.firstMatch(content);
    return match?.group(0);
  }

  AiResponse? responseContentParser(Map<String, dynamic> data) {
    try {
      final content = data["choices"][0]["message"]["content"];
      final jsonString = extractJsonFromContent(content);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString);
        return AiResponse.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final openAiServiceProvider = Provider<OpenAiService>((ref) => OpenAiService(ref));
