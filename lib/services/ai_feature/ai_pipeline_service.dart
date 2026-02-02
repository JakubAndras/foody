import 'dart:io';

import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/services/ai_feature/ai_service.dart';
import 'package:diplomka/services/ai_feature/openai_service.dart';
import 'package:get/get.dart';

class AiPipelineService extends GetxService {
  static AiPipelineService get to => Get.find();

  static const double minConfidence = 0.45;

  Future<AiAnalysisResult> analyzeMeal({
    List<File>? imageFiles,
    String? description,
  }) async {
    try {
      final AiService service = Get.isRegistered<AiService>() ? Get.find<AiService>() : OpenAiService();
      final response = await service.generateResponse(
        imageFiles: imageFiles,
        textPrompt: description,
      );

      if (response == null || response.valid == false) {
        return AiAnalysisResult.failure(
          message: 'Analysis failed to return a valid result.',
        );
      }

      final confidence = response.answer.confidence;
      if (confidence < minConfidence) {
        return AiAnalysisResult.lowConfidence(
          response: response,
          message: 'Low confidence result. Please review.',
        );
      }

      return AiAnalysisResult.success(response: response);
    } catch (e) {
      return AiAnalysisResult.failure(message: e.toString());
    }
  }
}

enum AiAnalysisStatus {
  success,
  lowConfidence,
  failure,
}

class AiAnalysisResult {
  final AiAnalysisStatus status;
  final AiResponse? response;
  final String? message;

  const AiAnalysisResult._({
    required this.status,
    this.response,
    this.message,
  });

  factory AiAnalysisResult.success({required AiResponse response}) {
    return AiAnalysisResult._(status: AiAnalysisStatus.success, response: response);
  }

  factory AiAnalysisResult.lowConfidence({required AiResponse response, String? message}) {
    return AiAnalysisResult._(
      status: AiAnalysisStatus.lowConfidence,
      response: response,
      message: message,
    );
  }

  factory AiAnalysisResult.failure({String? message}) {
    return AiAnalysisResult._(status: AiAnalysisStatus.failure, message: message);
  }

  bool get isSuccess => status == AiAnalysisStatus.success || status == AiAnalysisStatus.lowConfidence;
}
