// RESEARCH-ONLY: entire service. Research-only — wraps AiAttemptDao to log
// every AI invocation outcome. Drop along with the entity. See
// RESEARCH_ONLY.md.

import 'package:diplomka/database/app_database.dart';
import 'package:diplomka/database/dao/ai_attempt_dao.dart';
import 'package:diplomka/database/entities/ai_attempt_entity.dart';
import 'package:get/get.dart';

enum AiAttemptKind { meal, exercise, goals, query, queryScope, injectionScreen }

enum AiAttemptStatus { success, lowConfidence, invalidResponse, error, injectionRejected, injectionDetected }

class AiAttemptLogService extends GetxService {
  static AiAttemptLogService get to => Get.find();

  AiAttemptLogService({required AppDatabase database}) : _dao = database.aiAttemptDao;

  final AiAttemptDao _dao;

  /// Best-effort logging — never throws into the AI flow.
  Future<void> log({
    required AiAttemptKind kind,
    required AiAttemptStatus status,
    String? modality,
    String? provider,
    String? model,
    double? confidence,
    String? errorMessage,
    DateTime? timestamp,
    int? promptTokens,
    int? completionTokens,
    int? cachedTokens,
    double? costUsd,
  }) async {
    try {
      await _dao.insertAttempt(
        AiAttemptEntity(
          timestampMs: (timestamp ?? DateTime.now()).millisecondsSinceEpoch,
          kind: _kindCode(kind),
          modality: modality,
          provider: provider,
          model: model,
          status: _statusCode(status),
          confidence: confidence,
          errorMessage: _truncate(errorMessage),
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          cachedTokens: cachedTokens,
          costUsd: costUsd,
        ),
      );
    } catch (_) {
      // Telemetry must never affect user-facing behaviour.
    }
  }

  Future<List<AiAttemptEntity>> getAttempts({DateTime? start, DateTime? end}) {
    if (start == null || end == null) return _dao.findAllAttempts();
    return _dao.findAttemptsInRange(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch);
  }

  static String _kindCode(AiAttemptKind k) {
    switch (k) {
      case AiAttemptKind.meal:
        return 'meal';
      case AiAttemptKind.exercise:
        return 'exercise';
      case AiAttemptKind.goals:
        return 'goals';
      case AiAttemptKind.query:
        return 'query';
      case AiAttemptKind.queryScope:
        return 'query_scope';
      case AiAttemptKind.injectionScreen:
        return 'injection_screen';
    }
  }

  static String _statusCode(AiAttemptStatus s) {
    switch (s) {
      case AiAttemptStatus.success:
        return 'success';
      case AiAttemptStatus.lowConfidence:
        return 'low_confidence';
      case AiAttemptStatus.invalidResponse:
        return 'invalid_response';
      case AiAttemptStatus.error:
        return 'error';
      case AiAttemptStatus.injectionRejected:
        return 'injection_rejected';
      case AiAttemptStatus.injectionDetected:
        return 'injection_detected';
    }
  }

  static const int _maxErrorMessageLength = 500;

  static String? _truncate(String? message) {
    if (message == null) return null;
    if (message.length <= _maxErrorMessageLength) return message;
    return '${message.substring(0, _maxErrorMessageLength)}…';
  }
}
