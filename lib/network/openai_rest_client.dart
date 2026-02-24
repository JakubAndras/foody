import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:diplomka/utils/error.dart';
import 'package:diplomka/utils/prompt.dart';

class OpenaiRestClient {
  final Dio _dio = Dio();
  final String apiUrl = "https://api.openai.com/v1/chat/completions";
  String? chatGptApiKey = dotenv.env['OPENAI_API_KEY'];

  final String mealContext = 'You are an AI food analyzer. Never include anything outside of the JSON response.';
  final String exerciseContext = 'You are an AI exercise analyzer. Never include anything outside of the JSON response.';

  final String mealPrompt = Prompt().analyzeMeal;
  final String exercisePrompt = Prompt().analyzeExercise;

  Future<Map<String, dynamic>> generateResponse({List<File>? imageFiles, String? textPrompt}) async {
    final List<Map<String, dynamic>> imageContents = (imageFiles ?? []).map((file) {
      final List<int> imageBytes = file.readAsBytesSync();
      final String base64Image = base64Encode(imageBytes);
      return {
        "type": "image_url",
        "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
      };
    }).toList();

    try {
      await fetchChatGptApiKey();
      if (chatGptApiKey == null) {
        throw Error.generic(message: "Failed to fetch the ChatGPT key.");
      }
      return _postChatCompletion(
        context: mealContext,
        prompt: mealPrompt,
        textPrompt: textPrompt,
        imageContents: imageContents,
      );
    } on DioError catch (e) {
      throw Error.fromDioError(e);
    } catch (e) {
      if (e is Error) {
        rethrow;
      }
      throw Error.generic();
    }
  }

  Future<Map<String, dynamic>> generateExerciseResponse({
    required String textPrompt,
  }) async {
    try {
      await fetchChatGptApiKey();
      if (chatGptApiKey == null) {
        throw Error.generic(message: "Failed to fetch the ChatGPT key.");
      }

      return _postChatCompletion(
        context: exerciseContext,
        prompt: exercisePrompt,
        textPrompt: textPrompt,
        imageContents: const <Map<String, dynamic>>[],
      );
    } on DioError catch (e) {
      throw Error.fromDioError(e);
    } catch (e) {
      if (e is Error) {
        rethrow;
      }
      throw Error.generic();
    }
  }

  Future<Map<String, dynamic>> _postChatCompletion({
    required String context,
    required String prompt,
    required String? textPrompt,
    required List<Map<String, dynamic>> imageContents,
  }) async {
    final response = await _dio.post(
      apiUrl,
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $chatGptApiKey",
        },
        receiveTimeout: 30000,
      ),
      data: {
        "model": "gpt-4o",
        "messages": [
          {"role": "system", "content": context},
          {
            "role": "user",
            "content": [
              {"type": "text", "text": prompt},
              if (textPrompt != null && textPrompt.trim().isNotEmpty) {"type": "text", "text": "User description: ${textPrompt.trim()}"},
              ...imageContents
            ],
          }
        ]
      },
    );

    if (response.statusCode == 200) {
      debugPrint(response.data.toString());
      return response.data;
    }
    throw Error.generic();
  }

  Future<void> fetchChatGptApiKey() async {
    chatGptApiKey ??= dotenv.env['OPENAI_API_KEY'];
  }
}
