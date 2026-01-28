import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:diplomka/utils/error.dart';

class GeminiRestClient {
  final Dio _dio = Dio();
  final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"; // TODO: Check if this is the correct endpoint for Gemini
  String? geminiApiKey;

  final String context = 'You are an AI food analyzer. Always respond in JSON format.';

  Future<Map<String, dynamic>> generateResponse({List<File>? imageFiles}) async {
    final List<Map<String, dynamic>> imageContents = (imageFiles ?? []).map((file) {
      final List<int> imageBytes = file.readAsBytesSync();
      final String base64Image = base64Encode(imageBytes);
      return {
        "type": "image_url",
        "image_url": {"url": "database:image/jpeg;base64,$base64Image"}
      };
    }).toList();

    String prompt = "Recognize the food/ingredients in the input photo and give me their names and nutritional values, both for the whole meal and for the individual ingredients. The output must be a text representation in JSON format.";

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
                ...imageContents.map((img) => {"inline_data": {"mime_type": "image/jpeg", "database": img["image_url"]["url"].split(",").last}}).toList(),
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
        print(response.data);
        return response.data;
      } else {
        throw Error.generic();
      }
    } on DioError catch (e) {
      throw Error.fromDioError(e);
    } catch (e) {
      if (e is Error) //
        rethrow;
      throw Error.generic();
    }
  }

  Future<void> fetchGeminiApiKey() async {
    geminiApiKey ??= "YOUR_GEMINI_API_KEY"; // Replace with your actual Gemini API key
  }
}
