import 'package:diplomka/services/ai_feature/ai_service.dart';
import 'package:diplomka/services/ai_feature/gemini_service.dart';
import 'package:diplomka/services/ai_feature/openai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for AI Service Provider Type
enum AiServiceProviderType {
  openAI,
  gemini,
}

/// Spravuje výběr aktivního AI providera.
/// Stav = aktivní `AiServiceProviderType` (default `openAI`).
class AiServiceManagerNotifier extends Notifier<AiServiceProviderType> {
  @override
  AiServiceProviderType build() => AiServiceProviderType.openAI;

  /// Přepne aktivního AI providera.
  void switchService(AiServiceProviderType type) => state = type;

  // RESEARCH-ONLY: provider/model code getters used only by telemetry
  // wiring (MealEntity.aiProvider/aiModel). Research-only.
  /// Stable code identifying the active provider (`openai` or `gemini`).
  String get currentProviderCode => state == AiServiceProviderType.gemini ? 'gemini' : 'openai';

  /// Stable code identifying the active model. Mirrors values configured in REST clients.
  String get currentModelCode => state == AiServiceProviderType.gemini ? 'gemini-default' : 'gpt-5.4';
  // RESEARCH-ONLY: end
}

final aiServiceManagerProvider = NotifierProvider<AiServiceManagerNotifier, AiServiceProviderType>(AiServiceManagerNotifier.new);

/// Vrací aktivní AI službu podle stavu `aiServiceManagerProvider`.
/// Přepnutí providera řeší tento selektor, ne runtime rebind.
final aiServiceProvider = Provider<AiService>((ref) {
  return ref.watch(aiServiceManagerProvider) == AiServiceProviderType.gemini ? ref.watch(geminiServiceProvider) : ref.watch(openAiServiceProvider);
});
