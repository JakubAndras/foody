import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/utils/error.dart';
import 'package:diplomka/utils/prompt_sanitizer.dart';

class GeminiRestClient {
  final Dio _dio = Dio();
  final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
  String? geminiApiKey = dotenv.env['GEMINI_API_KEY'];

  final String context = 'You are an AI food analyzer. Always respond in JSON format. ${PromptSanitizer.antiInjectionDirective}';

  Future<Map<String, dynamic>> generateResponse({
    List<File>? imageFiles,
    String? textPrompt,
    Map<String, dynamic>? mealUserAttributes,
  }) async {
    final List<Map<String, dynamic>> imageContents = (imageFiles ?? []).map((file) {
      final List<int> imageBytes = file.readAsBytesSync();
      final String base64Image = base64Encode(imageBytes);
      return {
        "type": "image_url",
        "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
      };
    }).toList();

    String prompt =
        "Recognize the food/ingredients in the input photo and give me their names and nutritional values, both for the whole meal and for the individual ingredients. The output must be a text representation in JSON format.";
    if (textPrompt != null && textPrompt.trim().isNotEmpty) {
      prompt = '$prompt\\nUser description: ${PromptSanitizer.wrapUserInput(textPrompt.trim())}';
    }
    if (mealUserAttributes != null && mealUserAttributes.isNotEmpty) {
      prompt = '$prompt\\nUser dietary context: ${jsonEncode(mealUserAttributes)}';
      prompt = '$prompt\\nRespect this dietary context when identifying the meal and ingredients.';
    }

    try {
      await fetchGeminiApiKey();
      if (geminiApiKey == null) {
        throw Exception("Failed to fetch the Gemini API key.");
      }

      final response = await _dio.post(
        apiUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "x-goog-api-key": geminiApiKey, // Gemini uses x-goog-api-key header for API key
          },
          receiveTimeout: 30000,
        ),
        data: {
          "contents": [
            {
              "parts": [
                {"text": prompt},
                ...imageContents.map((img) => {
                      "inline_data": {"mime_type": "image/jpeg", "data": img["image_url"]["url"].split(",").last}
                    }),
              ]
            }
          ],
          // It's good practice to specify generation config if needed
          // "generationConfig": {
          //   "responseMimeType": "application/json",
          // }
        },
      );

      if (response.statusCode == 200) {
        print(response.data.toString());
        return response.data;
      } else {
        throw Error.generic();
      }
    } on DioError catch (e) {
      throw Error.fromDioError(e);
    } catch (e) {
      if (e is Error) {
        rethrow;
      }
      throw Error.generic();
    }
  }

  Future<void> fetchGeminiApiKey() async {
    geminiApiKey ??= dotenv.env['GEMINI_API_KEY'];
  }
}

final geminiRestClientProvider = Provider<GeminiRestClient>((ref) => GeminiRestClient());
