import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/network/openai_rest_client.dart';
import 'package:diplomka/services/ai_feature/ai_service.dart';

class OpenAiService implements AiService {
  final restClient = OpenaiRestClient();

  @override
  Future<AiResponse?> generateResponse({List<File>? imageFiles, String? textPrompt}) async {
    try {
      final data = await restClient.generateResponse(
        imageFiles: imageFiles,
        textPrompt: textPrompt,
      );
      return responseContentParser(data);
    } catch (e) {
      debugPrint(e.toString());
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
