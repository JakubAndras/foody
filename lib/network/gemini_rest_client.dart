import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/network/backend_config.dart';
import 'package:diplomka/services/device/device_identity_service.dart';
import 'package:diplomka/utils/error.dart';
import 'package:diplomka/utils/prompt_sanitizer.dart';

class GeminiRestClient {
  /// [backendConfig] a [deviceId] jsou volitelné se bezpečnými defaulty, aby
  /// přímá konstrukce (např. v testech) nic nerozbila. Provider ale vždy
  /// injektuje reálné hodnoty. Prázdné/nenastavené `BACKEND_BASE_URL` znamená
  /// nezměněné přímé volání Gemini (fallback).
  GeminiRestClient({BackendConfig? backendConfig, String? deviceId})
      : _backendConfig = backendConfig ?? BackendConfig(),
        _deviceId = deviceId ?? '';

  final BackendConfig _backendConfig;
  final String _deviceId;

  final Dio _dio = Dio();
  final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
  String? geminiApiKey = dotenv.env['GEMINI_API_KEY'];

  final String context = 'You are an AI food analyzer. Always respond in JSON format. ${PromptSanitizer.antiInjectionDirective}';

  /// Cílová URL pro daný [endpoint] label. Přes backend proxy když je
  /// nastavené `BACKEND_BASE_URL`, jinak přímo na Gemini.
  String _endpointUrl(String endpoint) => _backendConfig.isConfigured ? '${_backendConfig.baseUrl}/v1/ai/gemini/generate?endpoint=$endpoint' : apiUrl;

  /// Hlavičky requestu. Přes backend proxy se posílá app token + device id
  /// (backend injektuje Google klíč), jinak přesně původní přímé volání
  /// s `x-goog-api-key` (fallback).
  Map<String, String> _requestHeaders() {
    if (_backendConfig.isConfigured) {
      return {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${_backendConfig.appToken}",
        "X-Device-Id": _deviceId,
      };
    }
    return {
      "Content-Type": "application/json",
      "x-goog-api-key": geminiApiKey ?? '', // Gemini uses x-goog-api-key header for API key
    };
  }

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
        _endpointUrl("meal"),
        options: Options(
          headers: _requestHeaders(),
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
        debugPrint(response.data.toString());
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

final geminiRestClientProvider = Provider<GeminiRestClient>(
  (ref) => GeminiRestClient(
    backendConfig: ref.watch(backendConfigProvider),
    deviceId: ref.watch(deviceIdentityServiceProvider).deviceId,
  ),
);
