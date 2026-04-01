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
  final String queryContext = 'You are a personal nutrition data analyst. Analyze the user\'s logged nutrition data to answer their question. Never include anything outside of the JSON response.';
  final String goalsContext = 'You are a certified sports nutritionist. Generate personalized daily nutrition goals based on the user\'s profile. Never include anything outside of the JSON response.';

  final String mealPrompt = Prompt().analyzeMeal;
  final String exercisePrompt = Prompt().analyzeExercise;
  final String queryPrompt = Prompt().analyzeQuery;
  final String estimateScopePrompt = Prompt().estimateQueryScope;
  final String goalsPrompt = Prompt().generateNutritionGoals;

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
        additionalTextContent: [
          if (mealUserAttributes != null && mealUserAttributes.isNotEmpty) ...[
            'User dietary context: ${jsonEncode(mealUserAttributes)}',
            'Respect this dietary context when identifying the meal and ingredients.',
          ],
        ],
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
    Map<String, dynamic>? userAttributes,
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
        additionalTextContent: [if (userAttributes != null && userAttributes.isNotEmpty) 'User profile context for calorie estimation: ${jsonEncode(userAttributes)}'],
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

  Future<Map<String, dynamic>> estimateQueryScope({
    required String query,
    required String dataMetadata,
  }) async {
    try {
      await fetchChatGptApiKey();
      if (chatGptApiKey == null) {
        throw Error.generic(message: "Failed to fetch the ChatGPT key.");
      }

      return _postChatCompletion(
        context: queryContext,
        prompt: estimateScopePrompt,
        textPrompt: query,
        imageContents: const <Map<String, dynamic>>[],
        additionalTextContent: [
          'Available data metadata:\n$dataMetadata',
        ],
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

  Future<Map<String, dynamic>> generateQueryResponse({
    required String query,
    required String nutritionContext,
    String? userProfileContext,
    String? languageCode,
  }) async {
    try {
      await fetchChatGptApiKey();
      if (chatGptApiKey == null) {
        throw Error.generic(message: "Failed to fetch the ChatGPT key.");
      }

      return _postChatCompletion(
        context: queryContext,
        prompt: queryPrompt,
        textPrompt: query,
        imageContents: const <Map<String, dynamic>>[],
        additionalTextContent: [
          'User nutrition data:\n$nutritionContext',
          if (userProfileContext != null && userProfileContext.isNotEmpty) 'User profile context: $userProfileContext',
          if (languageCode != null) 'Respond in language: $languageCode',
        ],
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

  Future<Map<String, dynamic>> generateGoalsResponse({
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      await fetchChatGptApiKey();
      if (chatGptApiKey == null) {
        throw Error.generic(message: "Failed to fetch the ChatGPT key.");
      }

      return _postChatCompletion(
        context: goalsContext,
        prompt: goalsPrompt,
        textPrompt: null,
        imageContents: const <Map<String, dynamic>>[],
        additionalTextContent: [
          'User profile: ${jsonEncode(userProfile)}',
        ],
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
    List<String> additionalTextContent = const <String>[],
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
        "model": "gpt-5.2",
        "messages": [
          {"role": "system", "content": context},
          {
            "role": "user",
            "content": [
              {"type": "text", "text": prompt},
              ...additionalTextContent.map((text) => {"type": "text", "text": text}),
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
